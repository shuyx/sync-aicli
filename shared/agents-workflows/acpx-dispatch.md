---
description: 多 Agent 任务拆解与并行派发流程 (/acpx-dispatch workflow)
---

# /acpx-dispatch

将用户的复杂任务拆解为子任务，并行派发给多个 Agent（Claude Code / OpenCode / Codex），完成后通过 Telegram 回调汇报。

> **前置条件**：`acpx` 和 `cc-connect` 已安装且 daemon 运行中
> **触发方式**：`/acpx-dispatch` + 任务描述，或用户说"拆分任务给多个Agent"/"多Agent并行"/"蜂群模式"
> **参考 Skill**：先读取 `~/.gemini/antigravity/skills/acpx/SKILL.md` 了解参数规则和已知问题

## Step 1: 任务分析与 Agent 分工

**分析用户需求**，确定：
- 总共需要输出哪些文件/成果？
- 每个成果的复杂度如何？
- 哪些素材需要子 Agent 先阅读？
- 哪些文件之间有写冲突风险？（不能派给同一实例）

**确定分工**：

| Agent | 适合 | 并发上限 |
|-------|------|---------|
| Claude Code | 长文撰写、代码重构、复杂逻辑 | ≤5 |
| OpenCode | 单文件生成、模板填充 | ≤3 |
| Codex | 代码生成、测试修复 | ≤5 |

**输出**：向用户简述分工方案，确认后继续。

## Step 2: 编写 Prompt 文件

为每个子 Agent 编写独立的 Prompt 文件（`.md`），存放在工作目录下以 `_prompt_` 开头命名。

**每个 Prompt 必须包含**：
1. 头部元信息（派发方式 + 工作目录）
2. 背景段（一段话）
3. 关键约束（❌✅⚠️ 强调）
4. 任务描述：输出路径 + 内容结构 + 参考素材路径
5. 回调命令（统一用 `gemini-openclaw`）

**回调模板**（每个 Prompt 末尾必须有）：
```markdown
## 完成后（必须执行）
\```bash
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
📝 [Agent名] 任务完成汇报
✅ [文件名] — 已完成（简述）
📂 输出位置：[路径]
CCEOF
\```

如果 cc-connect 失败，请在输出文件末尾追加：
`<!-- cc-connect-callback-failed -->`
```

> 💡 参考样板：`~/.gemini/antigravity/skills/acpx/examples/README.md`

## Step 3: 创建 Session 并派发

// turbo-all

对每个子 Agent 依次执行：

```bash
# 1. 确保 session 存在（幂等）
acpx --cwd "<工作目录>" <agent> sessions ensure --name <session-name>

# 2. 并行派发（--no-wait 是并行关键）
# Claude / OpenCode / Codex 加 --approve-all
acpx --cwd "<工作目录>" --approve-all <agent> -s <session-name> --no-wait \
  -f <prompt文件路径>

# Gemini 不加 --approve-all
acpx --cwd "<工作目录>" gemini -s <session-name> --no-wait \
  -f <prompt文件路径>
```

## Step 4: 发送调度汇总通知

// turbo

派发完成后，调度器主动发一条汇总到 Telegram：

```bash
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
🚀 多 Agent 编排已启动
📌 Claude Code → [子任务列表]
📌 OpenCode → [子任务列表]
⏳ 各 Agent 完成后会自动在群里汇报
CCEOF
```

## Step 5: 监控与收尾

**监控**（可选，按需执行）：
```bash
acpx <agent> -s <session-name> status
```

**任务完成后，必须清理 session**：
```bash
acpx <agent> sessions close <session-name>
```

**验证清理**：
```bash
acpx claude sessions    # 确认标记为 [closed]
acpx opencode sessions
```

> 💡 即使忘记手动清理，cron 每小时自动清扫超过 1 小时的 idle session
