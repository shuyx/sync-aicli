---
name: resume-work
description: A context-restoration skill that automatically reads the master index and the latest dated record from the Obsidian Openclaw vault to instantly rebuild the AI's working context across different PCs.
---

# `resume-work` 跨端上下文一键恢复协议

## 触发条件
当用户在任何新电脑或新终端中输入 `/resume` 或提到“恢复上下文”、“继续进度”时，立即且静默地执行本工作流。

## 工作流 (The Workflow)

你必须严格按以下步骤操作，不得遗漏，且在完成前**不要打断用户**：

### 1. 挂载世界观 (Load Master Index)
1. 使用工具读取底层架构协议文件：`/Users/mac-minishu/Obsidian/kevinob/Openclaw/00-AI助理工作域核心指南.md`
2. 吸收里面的协作方法论（不要输出内容）。

### 2. 检索并加载最近的记忆胶囊 (Retrieve Latest Record)
1. 使用工具列出目录内容：`/Users/mac-minishu/Obsidian/kevinob/Openclaw/records/`
2. 找到按日期命名的最新的一份 Markdown 记录文件（例如 `20260309-sync-aicli-architecture-and-fixes.md`）。
3. 使用工具完整读取该文件的内容。

### 3. 构建汇报与输出 (Report & Stand-up)
在掌握了最新的遗留上下文后，请向用户作一次简明扼要的 Stand-up（站会）式总结，必须包含以下三个板块：
- **前情提要**：用一两句话总结上一班解决了什么问题或卡在了哪里。
- **待办清单 (Action Items)**：从最新记录的「下一步」中提炼出接下来我们要攻克的任务。
- **开工确认**：用友好、专业的语气询问用户：“我已完全同步进度，首个任务我们要现在开始吗？”

## 规范与约束
- **极度静默**：在读取文件和列出目录的过程中，尽量保持思考但不输出多余的中间状态，给用户展现“瞬间了解一切”的专家感。
- **只取最新**：绝不去读过期的旧记录，只认 `records/` 下日期最新、且与当前任务强相关的最后一份记录。
