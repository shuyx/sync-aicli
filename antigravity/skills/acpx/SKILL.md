---
name: acpx
description: |
  多 Agent 编排调度器。通过 Agent Client Protocol (ACP) 实现 Agent-to-Agent 结构化通信。
  支持向 Codex、Claude Code、Gemini、OpenCode、Pi 等 Agent 派发任务，
  持久化 Session、并行命名 Session、队列排队、协作取消、崩溃自动续接。
  触发条件：用户提到"派任务给 Codex/Claude"、"多 Agent 并行"、"编排 Agent"、
  "acpx"、"ACP 协议"、"Agent 协作"等关键词。
---

# acpx — 多 Agent 编排调度器

> 通过 ACP（Agent Client Protocol）让 AI Agent 之间结构化通信，取代 PTY 终端刮取。
> GitHub: [openclaw/acpx](https://github.com/openclaw/acpx) | 协议: [agentclientprotocol.com](https://agentclientprotocol.com)

## 安装

```bash
npm install -g acpx@latest
```

---

## ⚠️ 参数位置铁律（必须遵守）

acpx 参数分为**全局选项**和 **Agent 选项**，位置严格区分：

```
acpx [全局选项] <agent名> [agent选项] [prompt 或子命令]
      ↑ 放前面              ↑ 放后面
```

### 全局选项（agent 名前面）

| 选项 | 说明 |
|------|------|
| `--cwd <path>` | 指定工作目录 |
| `--approve-all` | 自动批准所有权限请求（Gemini 不支持） |
| `--approve-reads` | 只自动批准读操作（默认） |
| `--timeout <sec>` | 超时 |
| `--format <text/json/quiet>` | 输出格式 |

### Agent 选项（agent 名后面）

| 选项 | 说明 |
|------|------|
| `-s, --session <name>` | 使用命名 session |
| `--no-wait` | 入队后立即返回（并行关键） |
| `-f, --file <path>` | 从文件读取 prompt |

### ✅ 正确

```bash
acpx --cwd /path --approve-all claude -s my-task --no-wait -f prompt.md
```

### ❌ 错误（会报 unknown option）

```bash
acpx claude --approve-all -s my-task --cwd /path
```

---

## 完整任务派发 SOP（四步走）

当用户要求你把任务分配给多个 Agent 执行时，按以下流程操作：

### Step 1：任务拆解与 Agent 分工

根据任务特点选择 Agent：

| Agent | 擅长 | 适合分配 |
|-------|------|---------|
| **Claude Code** | 长文撰写、精细编辑、复杂逻辑 | 文档写作、代码重构、方案设计 |
| **Codex** | 代码生成、自动化测试 | 后端开发、测试修复、脚本编写 |
| **OpenCode** | 快速文件操作、轻量任务 | 文档模板填充、批量处理、简单编辑 |
| **Gemini** | 调研搜索、综合分析 | 信息收集、对比报告 |

**分工原则**：
- 文件有写冲突风险的任务不能派给同一 session
- 重量级任务（多文件写作）给 Claude Code
- 轻量级单文件任务给 OpenCode 或 Codex
- 调研类不涉及文件操作的给 Gemini

### Step 2：编写 Prompt 文件

**不要把长 Prompt 内联到命令行**，而是写成 `.md` 文件后用 `-f` 加载。

Prompt 文件结构模板：

```markdown
## 背景
[项目背景，一段即可]

## 关键约束（必须严格遵守）
1. ❌ 禁止做什么
2. ✅ 必须做什么
3. ⚠️ 注意什么

## 任务 [N]：[任务名]
**输出路径**：`具体/文件/路径.md`（明确是新建还是覆盖）

**内容结构**：
1. 第一节 — 简要说明
2. 第二节 — 简要说明
...

**参考素材**（请先阅读）：
- `路径/到/参考文件1.md`
- `路径/到/参考文件2.md`

## 完成后
[cc-connect 回调命令，见 Step 4]
```

**Prompt 工程要点**：
- 输出路径必须写**绝对路径或明确相对路径**
- 参考素材要让 Agent 先读再写，避免凭空编造
- 约束条件放最前面，用 ❌/✅/⚠️ 强调
- 一个 Prompt 文件可包含多个任务（同一 Agent 的）

### Step 3：创建 Session + 并行派发

```bash
# 1. 确保 Session 存在（ensure 幂等：已存在则复用，不存在则创建）
acpx --cwd "/workspace" claude sessions ensure --name task-claude
acpx --cwd "/workspace" opencode sessions ensure --name task-opencode

# 2. 并行派发（--no-wait 是并行的关键）
acpx --cwd "/workspace" --approve-all claude -s task-claude --no-wait \
  -f path/to/_prompt_claude.md

acpx --cwd "/workspace" --approve-all opencode -s task-opencode --no-wait \
  -f path/to/_prompt_opencode.md
```

**注意事项**：
- 优先使用 `sessions ensure` 而非 `sessions new`（幂等、可重入）
- OpenCode 首次创建 session 会触发 `bun install`，出现 JSON parse 警告属正常
- Gemini 不支持 `--approve-all`，派发时去掉该参数
- `--no-wait` 让命令入队后立即返回，实现真正并行

### Step 4：配置 Telegram 回调

> ⚠️ **关键规则**：所有子 Agent 的回调**统一使用 `gemini-openclaw` project**。
> 因为子 Agent 对应的 project（如 `claudecode-openclaw`）在 daemon 重启后
> Telegram session 会丢失，导致回调 `no active session` 失败。
> 调度器（Antigravity）的 `gemini-openclaw` session 总是活跃的。

在每个 Prompt 文件末尾注入 cc-connect 回调命令：

```markdown
## 完成后（必须执行）
所有任务完成后，执行以下 bash 命令向 Telegram 群组汇报：
\```bash
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
📝 [Agent名] 任务完成汇报
✅ 文件A — 已完成（简述变更）
✅ 文件B — 已完成（简述变更）
📂 输出位置：xxx
CCEOF
\```

如果 cc-connect 命令执行失败，请在最后一个输出文件末尾追加一行：
`<!-- cc-connect-callback-failed -->`
```

**回调 project 统一规则**：

| 发送方 | 使用的 cc-connect project | 原因 |
|--------|--------------------------|------|
| 调度器（Antigravity） | `gemini-openclaw` | 自身 project，session 始终活跃 |
| 所有子 Agent（Claude/Codex/OpenCode） | `gemini-openclaw` | 统一走调度器通道，避免 session 失效 |

调度器在派发完成后，也应主动发一条汇总通知：

```bash
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
🚀 多 Agent 编排已启动
📌 Claude Code → 子任务A, B
📌 OpenCode → 子任务C
⏳ 各 Agent 完成后会自动在群里汇报
CCEOF
```

### Step 5：任务收尾清理

任务全部完成后，**必须关闭 session**，避免 `~/.acpx/sessions/` 堆积垃圾：

```bash
# 关闭已完成的 session
acpx claude sessions close task-claude
acpx opencode sessions close task-opencode

# 验证清理结果
acpx claude sessions    # 确认标记为 [closed]
acpx opencode sessions
```

---

## 监控与管理

```bash
# 查看 session 状态
acpx claude -s task-name status
acpx opencode -s task-name status

# 查看对话历史
acpx claude -s task-name sessions history

# 取消正在执行的任务
acpx claude -s task-name cancel

# 关闭 session
acpx claude -s task-name sessions close

# 列出所有 session
acpx claude sessions
```

---

## 核心概念

- **Prompt（默认）**：持久化 Session 内的多轮对话
- **Exec**：一次性任务，不保存 Session
- **Named Session（`-s`）**：同一目录下的并行工作流
- **Queue**：队列排队，`--no-wait` 火烧发
- **Cancel**：协作式取消正在执行的任务

## 内置 Agent 注册表

| 命令 | Agent | 前置要求 |
|------|-------|---------|\
| `acpx codex` | Codex CLI | `npm i -g @openai/codex` |
| `acpx claude` | Claude Code | `npm i -g @anthropic-ai/claude-code` |
| `acpx gemini` | Gemini CLI | `npm i -g @google/gemini-cli` |
| `acpx opencode` | OpenCode | 需安装 opencode |
| `acpx pi` | Pi Agent | 自动通过 npx 下载 |

---

## 已知问题与解决方案

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| `unknown option '--approve-all'` | 全局参数放到了 agent 名后面 | 移到 agent 名前面 |
| `unknown option '--cwd'` | 同上 | 同上 |
| `No acpx session found` | 没有先创建 session | 先 `acpx <agent> sessions ensure --name xxx` |
| OpenCode `Failed to parse JSON` | bun install 的 stdout 干扰 | 忽略，不影响功能 |
| Gemini `--approve-all` 不支持 | Gemini CLI 未实现该 ACP 特性 | 不加该参数 |
| `cc-connect send` 报 `project "" not found` | 没指定 `--project` | 必须加 `--project <name>` |
| `cc-connect send` 报 `no active session` | daemon 重启后 Telegram session 丢失 | 子 Agent 统一用 `gemini-openclaw` project 回调；或在 Telegram 群里 @ 对应 bot 重新激活 |
| 子 Agent 回调卡在权限请求 | `--approve-all` 未完全覆盖 bash 执行权限 | Prompt 中加 fallback 标记（`<!-- cc-connect-callback-failed -->`） |

---

## 配置文件

```bash
acpx config init  # 创建 ~/.acpx/config.json 模板
acpx config show  # 显示合并后的配置
```

优先级：CLI flags > `.acpxrc.json`（项目）> `~/.acpx/config.json`（全局）

---

## 注意事项

- acpx 处于 **alpha 阶段**，CLI 接口可能变化
- Session 状态存储在 `~/.acpx/sessions/`
- 崩溃后自动检测死进程并重连
- 默认 Agent 是 `codex`（省略 agent 名时）
