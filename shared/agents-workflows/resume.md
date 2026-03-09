---
description: 一键恢复跨端上下文，自动读取 Openclaw/records 中的最新记忆胶囊并汇报进度
---

# /resume 跨端上下文恢复（增量式）

// turbo-all

## 重要：路径适配

不同机器上 Obsidian Vault 路径不同，你必须先确定当前机器的正确路径：
- **mac-minishu** → `/Users/mac-minishu/Obsidian/kevinob`
- **yuanxin** → `/Users/yuanxin/documents/kevinob`

请先用工具检测 `~/Obsidian/kevinob/Openclaw/records/` 是否存在，如果不存在则尝试 `~/documents/kevinob/Openclaw/records/`。确定有效路径后，将其记为 `VAULT_PATH`，后续步骤均使用此路径。将 `{VAULT_PATH}/Openclaw/records/` 记为 `RECORDS_DIR`。

## 核心机制：高水位标记（High Watermark）

在 `RECORDS_DIR` 下维护一个隐藏文件 `.last_resume`，记录上一次 resume 时已阅读过的最新胶囊文件名。每次 resume 只读取**水位线之后的增量胶囊**，避免重复消费。

## 执行步骤

### Step 1: 探测水位标记

```bash
cat {RECORDS_DIR}/.last_resume 2>/dev/null
```

- 如果文件**存在且有内容** → 进入 **热恢复**（Step 2A）
- 如果文件**不存在或为空** → 进入 **冷启动**（Step 2B）

---

### Step 2A: 热恢复流程（增量读取）

1. 从 `.last_resume` 中读取上次水位线文件名，记为 `WATERMARK`。

2. 列出 `RECORDS_DIR`，筛选出所有**排序在 WATERMARK 之后**的胶囊文件（排除 `00-` 开头的总纲和 `.last_resume` 本身）：

```bash
ls -1 {RECORDS_DIR} | grep -v '^00-' | grep -v '^\.' | sort | awk -v wm="$WATERMARK" '$0 > wm'
```

3. 根据增量结果：
   - **有新增胶囊**：逐篇读取所有增量胶囊（不要跳过任何一篇），然后进入 Step 3 的 Stand-up 汇报。
   - **无新增胶囊**：直接告知用户"自上次 resume 以来无新增胶囊，上次进度保持不变"，并询问用户是否需要强制冷启动全量阅读。

---

### Step 2B: 冷启动流程（首次 / 换机器 / 水位丢失）

1. 读取总纲索引文件，吸收系统架构全貌（**不要输出此步内容**）：

```
读取文件：{RECORDS_DIR}/00-AI助理工作域核心指南.md
```

2. 列出 `RECORDS_DIR`，按排序取**最新的 1 篇**记忆胶囊（排除 `00-` 开头的总纲文件），完整阅读其内容。

---

### Step 3: 更新水位标记

无论走的是哪条通道，在阅读完成后，将本轮读取到的**最新胶囊文件名**写入水位标记：

```bash
echo "最新胶囊文件名" > {RECORDS_DIR}/.last_resume
```

---

### Step 4: Stand-up 汇报

向用户做一次简明扼要的 Stand-up（站会）式汇报，包含：

- **恢复模式**：标注是「冷启动」还是「热恢复（增量 N 篇）」
- **前情提要**：用一两句话总结上一次解决了什么问题或卡在了哪里
- **新增内容摘要**（热恢复时）：逐篇列出增量胶囊的标题和一句话摘要
- **待办清单 (Action Items)**：从最新记录的「下一步」中提炼出接下来要攻克的任务
- **开工确认**：用友好专业的语气询问用户："我已完全同步进度，首个任务我们要现在开始吗？"
