---
name: deep-search
description: |
  多源深度搜索，整合 Brave + Exa + Tavily 三引擎，生成结构化调研报告。
  触发条件：用户说"深度搜索"、"deep search"、"帮我深入查"、"全面调研"、"多源搜索"、
  或 Brave 单源结果不够深入时。
  支持同步（短查询）和异步 dispatch 模式（长查询，写 .md 报告文件）。
---

# Deep Search — Antigravity 多源深度搜索

基于 Brave + Exa + Tavily 三引擎编排，输出结构化 Markdown 调研报告。

## 触发场景

- "帮我深度搜索 xxx"
- "全面调研 xxx"
- "用多个搜索引擎查 xxx"
- Brave 单源结果太浅，需要交叉验证时

## 工作流

```
1. Brave Search MCP  → 广度优先，获取概览 + 主要来源链接
2. Exa MCP           → 语义精准搜索，找相关性高的深度页面
3. Tavily MCP        → 内容提取，爬取关键 URL 的正文
4. 整合 → 写入结构化 Markdown 报告（含引用）
```

## 同步模式（短查询，<60s）

直接执行三源搜索并在对话中返回综合结论。

```
用法：请求中包含「深度搜索」即可，我会自动编排三引擎。
```

## Dispatch 模式（长查询，异步写文件）

```bash
bash /Users/mac-minishu/.gemini/antigravity/skills/deep-search/scripts/search.sh \
  --prompt "你的研究问题" \
  --output "/tmp/deep-search-results/$(date +%Y%m%d-%H%M%S).md" \
  --task-name "my-research"
```

输出报告路径：`/tmp/deep-search-results/<task-name>.md`

## 执行参数

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `--prompt` | ✅ | — | 研究问题 |
| `--output` | ❌ | `/tmp/deep-search-results/<timestamp>.md` | 报告保存路径 |
| `--task-name` | ❌ | `search-<timestamp>` | 任务标识符 |
| `--max-results` | ❌ | `5` | 每引擎最大结果数 |

## 报告格式

```markdown
# 深度搜索报告：<query>
生成时间：<timestamp>

## 执行摘要
...核心结论...

## Brave Search 结果
...

## Exa 语义搜索结果
...

## Tavily 内容提取
...

## 综合分析
...

## 参考来源
1. [title](url) - Brave
2. [title](url) - Exa
...
```

## Perplexica 增强（可选）

如果本地 Perplexica 在运行（http://localhost:3001），可附加一轮 academic 模式搜索。
触发：用户明确要求「学术深度搜索」。
