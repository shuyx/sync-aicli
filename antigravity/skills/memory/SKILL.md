---
name: memory
description: |
  Openclaw 记忆系统的读写管理 Skill。支持自动写入结构化记忆条目、关键词检索、
  分类浏览和索引重建。与 /resume workflow 和 sync-aicli 完全兼容。
  触发条件：用户说"记住xxx"、"remember xxx"、"保存到记忆"、"查记忆"、
  "recall xxx"、"整理记忆"、"memory"等关键词。
---

# Memory — 结构化记忆管理 Skill

> 基于 `Openclaw/records/` 的结构化 Markdown 记忆系统,
> 支持写入、检索、分类浏览和索引重建。

## 路径适配

不同机器上 Obsidian Vault 路径不同，操作前必须先探测有效路径：

```bash
# 探测逻辑（与 /resume workflow 一致）
if [ -d "$HOME/Obsidian/kevinob/Openclaw/records" ]; then
    RECORDS_DIR="$HOME/Obsidian/kevinob/Openclaw/records"
elif [ -d "$HOME/documents/kevinob/Openclaw/records" ]; then
    RECORDS_DIR="$HOME/documents/kevinob/Openclaw/records"
fi
```

## 触发场景与行为

### 1. 写入（"记住 xxx" / "remember xxx" / "保存到记忆"）

当用户请求记住某条信息时：

1. **判断分类 `type`**：
   - 排错经验 / Bug / 故障 → `debug`
   - 架构设计 / 技术选型 / 系统方案 → `architecture`
   - 项目进展 / 里程碑 / 计划 → `project`
   - 调研分析 / 市场研究 / 技术评估 → `research`
   - 其他 / 简短备忘 → `quicknote`（默认）

2. **生成文件**：

   ```bash
   bash ~/.gemini/antigravity/skills/memory/scripts/memory_write.sh \
     --type <type> \
     --title "记忆标题" \
     --content "具体内容..." \
     --tags "tag1,tag2"
   ```

   或直接使用 `write_to_file` 工具写入 `{RECORDS_DIR}/{type}/YYYYMMDD-标题.md`，
   文件必须包含标准 frontmatter：

   ```yaml
   ---
   type: quicknote
   tags: [标签1, 标签2]
   created: 2026-03-10T19:53:00+08:00
   source: conversation
   importance: medium
   ---
   ```

3. **确认反馈**：告知用户已保存到 `records/{type}/` 下，给出文件名。

### 2. 检索（"查记忆 xxx" / "recall xxx"）

当用户查询记忆时：

1. **关键词搜索**：使用 `grep_search` 递归搜索整个 records 目录（含子目录）

   ```bash
   bash ~/.gemini/antigravity/skills/memory/scripts/memory_search.sh --query "关键词"
   ```

   或直接使用 `grep_search` 工具：
   - SearchPath: `{RECORDS_DIR}`
   - Query: 用户的关键词
   - MatchPerLine: true

2. **按分类浏览**：如果用户指定类别（如"查看调试记忆"），只搜索对应子目录。

3. **返回结果**：列出匹配的文件名 + 匹配行内容 + 文件路径，让用户选择深入查看。

### 3. 对话开始自动扫描（可选）

当对话涉及复杂任务时，主动扫描 records 目录找到最近 5 条记忆条目：

```bash
find {RECORDS_DIR} -name "*.md" -not -name "00-*" -not -name "_index*" -not -name ".last_resume" \
  -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -5
```

**注意**：不要在每次简单对话中都触发扫描，只在任务复杂度较高或用户明确要求时使用。

### 4. 索引重建（"整理记忆"）

当用户要求整理时，重建 `_index.md`：

1. 递归扫描所有子目录
2. 提取每个文件的 frontmatter（type, tags, created）
3. 按分类和日期排序生成目录
4. 写入 `{RECORDS_DIR}/_index.md`

## 与 /resume 的协作

- `/resume` 读取最新记忆胶囊做 Stand-up 汇报
- `memory` Skill 负责写入和检索
- 两者共享同一个 `RECORDS_DIR`，通过文件系统天然同步
- `/resume` 已适配递归扫描子目录

## 与 sync-aicli 的协作

- `push.sh` 将 `Openclaw/records/` 整体同步到 sync-aicli 仓库
- 子目录结构会被完整保留
- `.lancedb/`（未来向量索引）应加入 `.gitignore` 避免同步二进制文件

## 记忆条目模板

```markdown
---
type: quicknote
tags: [标签]
created: YYYY-MM-DDTHH:MM:SS+08:00
source: conversation
importance: medium
---

# 标题

## 核心内容
[具体记忆内容]

## 上下文
[可选的背景信息]
```

## 分类速查

| type | 关键词线索 | 子目录 |
|------|-----------|--------|
| `debug` | 排错、Bug、报错、修复、SOP、故障 | `debug/` |
| `architecture` | 架构、设计、选型、方案、迁移、系统 | `architecture/` |
| `project` | 项目、进展、里程碑、计划、商业、申报 | `project/` |
| `research` | 调研、分析、评估、报告、市场、搜索 | `research/` |
| `quicknote` | 记住、备忘、提醒、TODO、其他 | `quicknote/` |
