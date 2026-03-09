---
name: cc-connect
description: 通过 cc-connect 管理本地 AI Agent 与 Telegram 的双向通信。支持四个独立 Bot（Claude Code / Gemini / Codex / OpenCode）的 daemon 管理、主动消息推送、群组异步通知、任务完成回调。触发条件：用户提到"cc-connect"、"Telegram bot"、"异步通知"、"群组汇报"、"发 Telegram"、"Agent组会"等关键词。
---

# cc-connect Skill

通过 cc-connect 桥接本地 AI Agent 与 Telegram，实现远程对话和异步任务通知。

## 架构总览

```
本地 Mac（Mac Mini / MacBook）
├── cc-connect daemon（launchd 常驻进程）
│   ├── Project: claudecode-openclaw → @claudeyx_bot
│   ├── Project: gemini-openclaw    → @geminiyx_bot
│   ├── Project: codex-openclaw     → @codexyx_bot
│   └── Project: opencode-openclaw  → @opencodeyx2026_bot
│
├── Antigravity（VS Code，主工作面）
│   └── 可通过 cc-connect send 推送消息到任意 bot
│
└── Telegram
    ├── 各 bot 私聊：远程和对应 agent 对话
    └── "Agent组会"群组：异步任务汇报
```

## 核心概念

### 每个 Agent 必须使用独立的 Bot Token
Telegram 的 `getUpdates` 长轮询机制**不允许同一个 token 被多个 cc-connect project 共用**。
否则会出现：`Conflict: terminated by other getUpdates request`

### Token 管理
所有 Bot Token 存储在 `secrets.env` 中：
```bash
SECRET_CC_BOT_CLAUDECODE="..."
SECRET_CC_BOT_GEMINI="..."
SECRET_CC_BOT_CODEX="..."
SECRET_CC_BOT_OPENCODE="..."
```

### 配置文件位置
`~/.cc-connect/config.toml`

## Daemon 管理

```bash
# 首次安装（指定配置目录）
cc-connect daemon install --work-dir ~/.cc-connect

# 日常管理
cc-connect daemon start       # 启动
cc-connect daemon stop        # 停止
cc-connect daemon restart     # 重启
cc-connect daemon status      # 查看状态
cc-connect daemon logs -f     # 实时日志
cc-connect daemon uninstall   # 卸载
```

- macOS 使用 `launchd`，重启后自动恢复
- 如果 `restart` 报 I/O error，用 `stop → uninstall → install → start` 顺序重装

## 主动推送消息（异步通知核心）

```bash
# 通过指定 project 的 bot 发送消息
cc-connect send --project gemini-openclaw -m "✅ 任务完成：xxx"
cc-connect send --project claudecode-openclaw -m "⚠️ 子任务 2 遇到问题"

# 多行消息
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
📊 Agent组会汇报
子任务 1：完成 ✅
子任务 2：进行中 🔄
子任务 3：等待依赖 ⏳
CCEOF
```

### 消息发送目标
- `cc-connect send` 发送到**最近活跃的 session**
- 如果要发到群组，需要先在群里 @ 对应 bot 激活 session
- **重启 daemon 后 session 丢失**，需要重新在群里 @ bot 激活

## 异步任务通知流程

### 方式 1：Antigravity 主动推送（推荐）
```
Antigravity（VS Code）拆分任务 → 派发给各 Agent
   ↓
任务完成后，Antigravity 调用：
cc-connect send --project gemini-openclaw -m "📊 任务汇总：..."
   ↓
"Agent组会"群收到汇报
```

### 方式 2：acpx 子任务末尾 hook
在 acpx 派发的子任务 prompt 末尾注入：
```
任务完成后执行：cc-connect send --project [bot] -m "✅ [子任务名] 完成：[摘要]"
```
各 agent 执行完毕自动回调。

## Session 管理（在 Telegram 中）

```
/new [name]    — 新建 session
/list          — 列出所有 session
/switch <id>   — 切换 session
/stop          — 停止当前执行
/current       — 查看当前 session
/history [n]   — 查看最近 n 条消息
/help          — 显示所有命令
```

## 群组使用

1. 创建 Telegram 群组
2. 把所有 bot 拉入群组
3. 在群里 @ 每个 bot 发一条消息（激活 session）
4. 之后 `cc-connect send` 就能推送到群里

### 群组 bind 功能（多 bot 绑定）
```
/bind                 — 查看当前绑定
/bind claudecode      — 绑定 claudecode project
/bind -claudecode     — 取消绑定
```

## 重要注意事项

- `@geminiyx_bot`（Telegram）和 Antigravity（VS Code）上下文**不共享**——它们是独立的 Gemini session
- 异步汇报最可靠的方式是 Antigravity 用 `cc-connect send` 主动推送（有完整上下文）
- OpenCode 可能存在 session JSON 解析兼容性问题，遇到异常时先尝试 `/new` 创建新 session

## 定时任务（Cron）

```bash
# 添加定时任务
cc-connect cron add --cron "0 6 * * *" --prompt "任务描述" --desc "标签"

# 管理
cc-connect cron list
cc-connect cron del <job-id>
```

环境变量 `CC_PROJECT` 和 `CC_SESSION_KEY` 已预设，无需指定 `--project` 或 `--session-key`。
