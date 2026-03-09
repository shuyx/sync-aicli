---
description: 将内容格式化并发送到 Flomo 笔记应用 (/flomo workflow)
---

# /flomo

将用户提供的内容，按照 Flomo 最佳排版规范格式化并发送到 Flomo。
可以单条发送，也可以自动拆分成多条卡片。

> **前置条件**：`secrets.env` 中已配置 `SECRET_FLOMO_API_URL`
> **触发方式**：`/flomo` + 要记录的内容，或用户说"发 flomo"/"flomo 里记一下"

// turbo-all

## Step 1: 加载配置与理解内容

**读取 API 配置**：
```bash
source ~/Obsidian/kevinob/Openclaw/secrets.env
# 使用 $SECRET_FLOMO_API_URL
```

**理解用户意图**：
- 用户要记录什么核心主题？
- 适合一条还是多条发送？（超过 2-3 段落 → 拆分为多条）
- 需要打哪些 tags？

## Step 2: 按 Flomo 排版规范格式化内容

**强制遵守以下规则**（基于实测确认）：

| 规则 | 说明 |
|---|---|
| ❌ Markdown 不渲染 | `**粗体**`、`# 标题`、`- 列表` 原样显示，禁止使用 |
| ❌ HTML 标签无效 | `<strong>` 等 HTML 标签显示异常，禁止使用 |
| ✅ Emoji 完美显示 | 用 emoji 替代标题层级（💡⚙️🎯⚠️📚💬📊🔧） |
| ✅ \n 换行有效 | 段落间用 \n\n（转为 HTML `<p>` 段落展示） |
| ✅ #tag 有效 | 末尾加 `#标签名`，自动归档到 Flomo tag 系统 |

**标准排版模板**：
```
[emoji] 主标题

核心内容段落

补充内容（可选）

→ 来源/行动项（可选）

#标签1 #标签2
```

## Step 3: 调用 Flomo API 发送

对于每一条笔记，执行：
```bash
curl -s -X POST "${SECRET_FLOMO_API_URL}" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"[格式化后的内容，注意 \" 转义为 \\\"，换行用 \\n\"}"
```

**注意**：content 中的双引号 `"` 必须转义为 `\"`。

## Step 4: 确认并汇报

- 返回 `"code":0` 且 `"message":"已记录"` = 发送成功
- 告知用户：发送了几条、打了哪些 tags、每条的摘要
- 如果发送失败，检查双引号转义问题并重试
