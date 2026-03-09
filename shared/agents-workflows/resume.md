---
description: 一键恢复跨端上下文，自动读取 Openclaw/records 中的最新记忆胶囊并汇报进度
---

# /resume 跨端上下文恢复

// turbo-all

## 重要：路径适配

不同机器上 Obsidian Vault 路径不同，你必须先确定当前机器的正确路径：
- **mac-minishu** → `/Users/mac-minishu/Obsidian/kevinob`
- **yuanxin** → `/Users/yuanxin/documents/kevinob`

请先用工具检测 `~/Obsidian/kevinob/Openclaw/records/` 是否存在，如果不存在则尝试 `~/documents/kevinob/Openclaw/records/`。确定有效路径后，将其记为 `VAULT_PATH`，后续步骤均使用此路径。

## 执行步骤

1. 读取总纲索引文件，吸收系统架构全貌（不要输出此步内容）：

```
读取文件：{VAULT_PATH}/Openclaw/records/00-AI助理工作域核心指南.md
```

2. 列出 records 目录，找到日期最新的记忆胶囊文件：

```
列出目录：{VAULT_PATH}/Openclaw/records/
```

3. 读取日期最新的那份记忆胶囊（排除 00- 开头的总纲文件），完整阅读其内容。

4. 向用户做一次简明扼要的 Stand-up（站会）式汇报，包含：
   - **前情提要**：用一两句话总结上一次解决了什么问题或卡在了哪里
   - **待办清单 (Action Items)**：从最新记录的「下一步」中提炼出接下来要攻克的任务
   - **开工确认**：用友好专业的语气询问用户："我已完全同步进度，首个任务我们要现在开始吗？"
