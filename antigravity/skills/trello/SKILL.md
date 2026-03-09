---
name: trello
description: |
  通过 Trello REST API 对看板、列表、卡片、成员进行精细操控。
  支持创建/更新/归档卡片、移动卡片到不同列表、添加标签/成员/截止日期、
  查询所有看板/卡片状态、批量操作等。
  触发条件：用户提到"Trello"、"看板"、"卡片"、"任务管理"、"移动卡"、
  "创建卡片"、"归档"、"trello 操作"等关键词。
---

# Trello Skill — 精细化看板操控

> 通过 Trello REST API (`https://api.trello.com/1`) 对 Trello 进行全方位程序化控制。

## 凭证配置

凭证从 `~/Obsidian/kevinob/Openclaw/secrets.env` 读取：

```bash
# 在脚本中加载
source ~/Obsidian/kevinob/Openclaw/secrets.env
TRELLO_KEY="$SECRET_TRELLO_API_KEY"
TRELLO_TOKEN="$SECRET_TRELLO_TOKEN"
BASE="https://api.trello.com/1"
```

| 参数 | 值来源 |
|------|--------|
| **API Key** | `SECRET_TRELLO_API_KEY` |
| **Token** | `SECRET_TRELLO_TOKEN` |
| **Base URL** | `https://api.trello.com/1` |

---

## 使用方法

### 方式 1：调用封装脚本（推荐）

```bash
bash ~/.gemini/antigravity/skills/trello/scripts/trello.sh <命令> [参数...]
```

### 方式 2：直接 curl（快速单次操作）

```bash
source ~/Obsidian/kevinob/Openclaw/secrets.env
curl -s "https://api.trello.com/1/<endpoint>?key=$SECRET_TRELLO_API_KEY&token=$SECRET_TRELLO_TOKEN" | python3 -m json.tool
```

---

## 完整命令速查

### 📋 看板 (Board)

| 命令 | 说明 | 示例 |
|------|------|------|
| `boards` | 列出我的所有看板 | `trello.sh boards` |
| `board-lists <boardId>` | 列出看板的所有列表 | `trello.sh board-lists abc123` |
| `board-cards <boardId>` | 列出看板的所有卡片 | `trello.sh board-cards abc123` |
| `board-members <boardId>` | 列出看板成员 | `trello.sh board-members abc123` |

### 📁 列表 (List)

| 命令 | 说明 | 示例 |
|------|------|------|
| `list-cards <listId>` | 查看列表下的所有卡片 | `trello.sh list-cards abc123` |
| `create-list <boardId> <name>` | 在看板中创建列表 | `trello.sh create-list abc123 "待办"` |
| `archive-list <listId>` | 归档列表 | `trello.sh archive-list abc123` |

### 🃏 卡片 (Card)

| 命令 | 说明 | 示例 |
|------|------|------|
| `create-card <listId> <name> [desc]` | 创建卡片 | `trello.sh create-card abc123 "修复 Bug" "详细描述"` |
| `get-card <cardId>` | 查看卡片详情 | `trello.sh get-card abc123` |
| `move-card <cardId> <listId>` | 移动卡片到指定列表 | `trello.sh move-card abc123 xyz456` |
| `update-card-name <cardId> <name>` | 更新卡片标题 | `trello.sh update-card-name abc123 "新标题"` |
| `update-card-desc <cardId> <desc>` | 更新卡片描述 | `trello.sh update-card-desc abc123 "新描述"` |
| `set-due <cardId> <ISO日期>` | 设置截止日期 | `trello.sh set-due abc123 "2026-03-31T18:00:00.000Z"` |
| `complete-due <cardId>` | 标记截止日期为已完成 | `trello.sh complete-due abc123` |
| `archive-card <cardId>` | 归档卡片 | `trello.sh archive-card abc123` |
| `delete-card <cardId>` | 永久删除卡片 | `trello.sh delete-card abc123` |
| `add-comment <cardId> <text>` | 给卡片添加评论 | `trello.sh add-comment abc123 "进度更新"` |
| `card-comments <cardId>` | 查看卡片评论 | `trello.sh card-comments abc123` |

### 🏷️ 标签 (Label)

| 命令 | 说明 | 示例 |
|------|------|------|
| `board-labels <boardId>` | 列出看板所有标签 | `trello.sh board-labels abc123` |
| `add-label <cardId> <labelId>` | 给卡片添加标签 | `trello.sh add-label abc123 lbl456` |
| `remove-label <cardId> <labelId>` | 从卡片移除标签 | `trello.sh remove-label abc123 lbl456` |
| `create-label <boardId> <name> <color>` | 创建新标签 | `trello.sh create-label abc123 "紧急" red` |

**可用颜色**: `red` `orange` `yellow` `green` `blue` `purple` `pink` `sky` `lime` `null`（无色）

### 👤 成员 (Member)

| 命令 | 说明 | 示例 |
|------|------|------|
| `me` | 查看当前用户信息 | `trello.sh me` |
| `my-cards` | 列出分配给我的所有卡片 | `trello.sh my-cards` |
| `assign-member <cardId> <memberId>` | 将成员分配到卡片 | `trello.sh assign-member abc123 mem456` |
| `remove-member <cardId> <memberId>` | 从卡片移除成员 | `trello.sh remove-member abc123 mem456` |

### 🔍 搜索

| 命令 | 说明 | 示例 |
|------|------|------|
| `search <query>` | 全局搜索卡片/看板 | `trello.sh search "Bug修复"` |

---

## 典型工作流

### 流程 1：查看项目全貌
```bash
# 1. 列出所有看板，找到目标看板 ID
trello.sh boards

# 2. 查看看板的所有列表
trello.sh board-lists <boardId>

# 3. 查看某列表下的所有卡片
trello.sh list-cards <listId>
```

### 流程 2：创建并配置一张新卡片
```bash
# 1. 在"待处理"列表下创建卡片
CARD_ID=$(trello.sh create-card <listId> "实现 XX 功能" "具体描述" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

# 2. 设置截止日期
trello.sh set-due $CARD_ID "2026-03-31T18:00:00.000Z"

# 3. 添加标签
trello.sh add-label $CARD_ID <labelId>
```

### 流程 3：批量移动卡片（日常看板流转）
```bash
# 把"完成"的卡片移动到"已完成"列表
trello.sh move-card <cardId> <doneListId>
```

---

## 常见 ID 获取方式

1. **从 Trello 网页 URL 获取**：`https://trello.com/b/<boardShortLink>/xxx` 中的 shortLink
2. **从 API 返回 JSON 中的 `id` 字段获取**
3. **使用 `boards` 命令列出所有看板 ID**

---

## 依赖

- `curl`（系统自带）
- `python3`（用于 JSON 格式化，可选）
- `jq`（可选，更强的 JSON 处理：`brew install jq`）
