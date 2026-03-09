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

## 核心概念

- **Prompt（默认）**：持久化 Session 内的多轮对话
- **Exec**：一次性任务，不保存 Session
- **Named Session（`-s`）**：同一目录下的并行工作流
- **Queue**：队列排队，`--no-wait` 火烧发
- **Cancel**：协作式取消正在执行的任务

---

## 内置 Agent 注册表

| 命令 | Agent | 前置要求 |
|------|-------|---------|
| `acpx codex` | Codex CLI | `npm i -g @openai/codex` |
| `acpx claude` | Claude Code | `npm i -g @anthropic-ai/claude-code` |
| `acpx gemini` | Gemini CLI | `npm i -g @google/gemini-cli` |
| `acpx opencode` | OpenCode | 需安装 opencode |
| `acpx pi` | Pi Agent | 自动通过 npx 下载 |

未注册名称 → 作为原始命令执行；`--agent` 可指定自定义 ACP 服务器。

---

## 常用命令速查

### 基本任务派发

```bash
# 给 Codex 派任务（持久 Session）
acpx codex "修复 flaky test"

# 给 Claude Code 派任务
acpx claude "重构 auth 模块"

# 一次性任务（不保存 Session）
acpx codex exec "总结这个仓库的用途"
```

### 并行编排（核心用法）

```bash
# 创建命名 Session
acpx codex sessions new --name backend
acpx codex sessions new --name docs

# 并行派发
acpx codex -s backend "修 API 分页 Bug"
acpx codex -s docs "写这次发布的 changelog"
```

### 多 Agent 并行（Antigravity 调度模式）

```bash
# Antigravity 作为调度器，同时派给多个 Agent
acpx codex -s task1 "子任务A: 修测试" --no-wait
acpx claude -s task2 "子任务B: 重构模块" --no-wait
acpx gemini -s task3 "子任务C: 更新文档" --no-wait

# 各自独立执行，互不阻塞
```

### 队列排队

```bash
# 第一个任务还在跑，第二个自动排队
acpx codex "跑全部测试，分析失败原因"
acpx codex --no-wait "测试跑完后，总结根因和下一步"
```

### Session 管理

```bash
acpx codex sessions          # 列出所有 session
acpx codex sessions show     # 查看当前 session 详情
acpx codex sessions history  # 查看对话历史
acpx codex sessions close    # 关闭当前 session
acpx codex status            # 查看进程状态
```

### 取消和模式切换

```bash
acpx codex cancel                    # 协作式取消正在执行的任务
acpx codex set-mode plan             # 切换为 plan 模式
acpx codex set approval_policy conservative  # 设置审批策略
```

---

## 输出格式

```bash
# 默认：人类可读流式输出
acpx codex "review this PR"

# JSON：NDJSON 事件流，适合自动化
acpx --format json codex exec "review" > events.ndjson

# Quiet：只输出最终结果
acpx --format quiet codex "3 行总结"
```

---

## 全局选项

| 选项 | 说明 |
|------|------|
| `--cwd <path>` | 指定工作目录 |
| `--approve-all` | 自动批准所有权限请求 |
| `--approve-reads` | 只自动批准读操作（默认）|
| `--deny-all` | 拒绝所有权限请求 |
| `--timeout <sec>` | 超时 |
| `--ttl <sec>` | 队列所有者存活时间（默认 300s）|
| `--no-wait` | 入队后立即返回 |
| `--format <text/json/quiet>` | 输出格式 |
| `--verbose` | 调试模式 |
| `--agent <cmd>` | 自定义 ACP 服务器命令 |

---

## 配置文件

```bash
acpx config init  # 创建 ~/.acpx/config.json 模板
acpx config show  # 显示合并后的配置
```

优先级：CLI flags > `.acpxrc.json`（项目）> `~/.acpx/config.json`（全局）

---

## 典型工作流

### 1. Antigravity 调度器模式

```
你 → Telegram → cc-connect → Gemini（调度者）
                                  ├── acpx codex -s t1 "子任务A" --no-wait
                                  ├── acpx claude -s t2 "子任务B" --no-wait
                                  └── acpx gemini -s t3 "子任务C" --no-wait
```

### 2. PR Review 协作

```bash
acpx --cwd ~/repos/shop --approve-all codex -s pr-842 \
  "Review PR #842 for regressions and propose minimal patch"
```

### 3. 自动化脚本集成

```bash
result=$(acpx --format quiet codex exec "summarize repo in 3 lines")
echo "$result" | cc-connect send --stdin
```

---

## 注意事项

- acpx 处于 **alpha 阶段**，CLI 接口可能变化
- Session 状态存储在 `~/.acpx/sessions/`
- 崩溃后自动检测死进程并重连
- 默认 Agent 是 `codex`（省略 agent 名时）
