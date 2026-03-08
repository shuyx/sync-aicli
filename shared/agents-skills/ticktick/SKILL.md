---
name: ticktick
description: |
  滴答清单 (TickTick) API 集成。管理任务、项目和列表。
  使用此技能来创建、更新、完成或组织滴答清单中的任务和项目。
metadata:
  author: Piggy CDO
  version: "1.0"
  source: 历史脚本恢复
---

# 滴答清单 (TickTick) API 集成

> 状态：✅ 已恢复 | Token 有效期：已验证

## 快速开始

### 环境变量

```bash
# Token 已配置
export TICKTICK_TOKEN="dp_eb7e1bfb96154171a2742eeb4613475f"
```

### 列出所有项目

```bash
curl -s -H "Authorization: Bearer $TICKTICK_TOKEN" \
  "https://dida365.com/open/v1/project" | jq
```

## API 参考

### Base URL

```
https://dida365.com/open/v1
```

### 常用端点

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/project` | 列出所有项目 |
| GET | `/project/{projectId}/data` | 获取项目详情（含任务） |
| POST | `/task` | 创建任务 |
| POST | `/project/{projectId}/task/{taskId}/complete` | 完成任务 |

### 创建任务

```bash
curl -X POST "https://dida365.com/open/v1/task" \
  -H "Authorization: Bearer $TICKTICK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试任务",
    "projectId": "你的项目ID",
    "priority": 3,
    "isAllDay": true
  }'
```

### 任务字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `title` | string | 任务标题 |
| `projectId` | string | 项目 ID |
| `content` | string | 任务描述 |
| `priority` | int | 优先级：0=无, 1=低, 3=中, 5=高 |
| `status` | int | 状态：0=进行中, 2=已完成 |
| `dueDate` | string | 截止日期 (ISO 8601) |

## Python 示例

```python
import requests

TOKEN = "dp_eb7e1bfb96154171a2742eeb4613475f"
API_BASE = "https://dida365.com/open/v1"

headers = {"Authorization": f"Bearer {TOKEN}"}

# 列出项目
projects = requests.get(f"{API_BASE}/project", headers=headers).json()

# 创建任务
task = {
    "title": "新任务",
    "projectId": projects[0]["id"],
    "priority": 3
}
result = requests.post(f"{API_BASE}/task", json=task, headers=headers)
```

## 故障排除

- **401 错误**：Token 可能已过期，需从滴答清单 App 重新获取
- **无权限**：检查 Token 是否对应正确的账户

## 相关文件

- 原始脚本：`~/openclaw/scripts/list_ticktick_projects.py`
- Token 来源：历史备份恢复
