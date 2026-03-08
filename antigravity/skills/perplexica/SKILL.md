---
name: perplexica
description: |
  通过本地部署的 Perplexica (AI 搜索引擎) 进行深度网络搜索。
  支持 web/academic/discussions 三种搜索源和 speed/balanced/quality 三种模式。
  返回 AI 总结 + 来源引用。适合深度调研、学术搜索和知识补充。
  触发条件：用户提到"深度搜索"、"学术搜索"、"Perplexica"、"带来源搜索"、
  "搜索论文"、"全网搜索"等关键词，或当 search_web 结果不够深度时。
---

# Perplexica — AI 搜索引擎 Skill

> 本地部署的开源 AI 搜索引擎，等价于自托管版 Perplexity。

## 服务地址

- **URL**: `http://localhost:3001`
- **API**: `POST /api/search`
- **Docker**: `Openclaw/Perplexica/docker-compose.yaml`

## 何时使用

| 场景 | 用 search_web | 用 Perplexica |
|------|:---:|:---:|
| 快速事实查证 | ✅ | |
| 需要来源引用的深度调研 | | ✅ |
| 学术论文搜索 | | ✅ (`academic` 源) |
| 论坛/讨论社区搜索 | | ✅ (`discussions` 源) |
| KCB Skill 中补充知识空白 | | ✅ (`quality` 模式) |
| 批量多 query 调研 | | ✅ (脚本自动化) |

## 使用方法

### 方式 1: 脚本调用

```bash
bash ~/.gemini/antigravity/skills/perplexica/scripts/perplexica_search.sh \
  "谐波减速器在机器人中的应用" \
  balanced \
  web
```

参数:
- `$1`: 搜索查询 (必需)
- `$2`: 模式 — `speed` | `balanced` | `quality` (默认 balanced)
- `$3`: 搜索源 — `web` | `academic` | `discussions` (默认 web，可逗号分隔多个)

### 方式 2: 直接 curl 调用

```bash
# 1. 获取 provider 信息
curl -s http://localhost:3001/api/providers

# 2. 执行搜索
curl -s -X POST http://localhost:3001/api/search \
  -H "Content-Type: application/json" \
  -d '{
    "chatModel": {"providerId": "<PROVIDER_ID>", "key": "<MODEL_KEY>"},
    "embeddingModel": {"providerId": "<EMBED_PROVIDER_ID>", "key": "<EMBED_KEY>"},
    "optimizationMode": "balanced",
    "sources": ["web"],
    "query": "你的搜索问题",
    "stream": false
  }'
```

### 方式 3: 在 KCB Skill 中联动

当 KCB 的 Phase 2 深读过程中发现知识缺口时:

```bash
# 用 quality 模式 + academic 源搜索补充
bash ~/.gemini/antigravity/skills/perplexica/scripts/perplexica_search.sh \
  "具身智能 VLA 模型的 sim-to-real 迁移最新进展" \
  quality \
  "web,academic"
```

## API 参考

### POST /api/search

**请求参数**:
- `chatModel.providerId` — Provider UUID (从 `/api/providers` 获取)
- `chatModel.key` — 模型 key (如 `models/gemini-2.5-flash-lite`)
- `embeddingModel.providerId` — Embedding provider UUID
- `embeddingModel.key` — Embedding 模型 key
- `optimizationMode` — `speed` | `balanced` | `quality`
- `sources` — `["web"]` | `["academic"]` | `["discussions"]` 或组合
- `query` — 搜索查询文本
- `stream` — `true` 启用流式响应
- `systemInstructions` — 可选，自定义指令
- `history` — 可选，对话历史

**响应格式**:
```json
{
  "message": "AI 生成的总结答案...",
  "sources": [
    {
      "content": "来源摘要片段",
      "metadata": {
        "title": "网页标题",
        "url": "https://..."
      }
    }
  ]
}
```

## 运维

### 启动服务
```bash
cd ~/Obsidian/kevinob/Openclaw/Perplexica && docker compose up -d
```

### 停止服务
```bash
cd ~/Obsidian/kevinob/Openclaw/Perplexica && docker compose down
```

### 检查状态
```bash
docker compose -f ~/Obsidian/kevinob/Openclaw/Perplexica/docker-compose.yaml ps
```

### 配置管理
通过浏览器 `http://localhost:3001` 设置页面管理 LLM provider 和 API key。
