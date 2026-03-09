---
name: flomo
description: 将内容美观格式化后发送到 Flomo。支持单条和多条拆分发送，自动添加 tags，使用 Flomo 最佳排版规范（纯文本+emoji层级+#tags）。触发条件：用户说"发 flomo"、"写 flomo"、"flomo 里记一下"，或使用 /flomo 命令。
---

# Flomo Skill 使用指南

## 核心结论：Flomo API 格式规范

**经过实测确认**，Flomo API 的格式规则如下：

1. **换行**：`\n` 会被自动转为 HTML `<p>` 段落，正常显示
2. **Markdown 不渲染**：`**粗体**`、`## 标题`、`- 列表` 等 Markdown 语法**不会被渲染**，原样显示为纯文字
3. **HTML 标签不渲染**：`<strong>`、`<em>`、`<ul>` 等 HTML 标签在 Flomo 中**无效或显示异常**
4. **#tag 有效**：`#标签名` 在 content 中会被识别为 Flomo tag，同步出现在 tags 列表中
5. **emoji 有效**：Emoji 在 Flomo 中完美显示，是替代标题格式的最佳视觉工具

## Flomo 最佳排版规范

Flomo 是极简卡片笔记，最适合**短小精悍的闪念笔记**，而不是长篇文章。排版原则：

### 结构模板（单条笔记）
```
[emoji] 主标题

核心观点或内容段落一

核心观点或内容段落二（如有）

---（可用此作为视觉分隔线）

→ 来源/行动项（可选）

#标签1 #标签2
```

### Emoji 层级规范
| 用途 | 推荐 Emoji |
|---|---|
| 核心洞察/金句 | 💡 |
| 技术/工程知识 | ⚙️ |
| 行动项/待办 | 🎯 |
| 警告/注意 | ⚠️ |
| 资源/参考 | 📚 |
| 对话/讨论记录 | 💬 |
| 数据/结论 | 📊 |
| 项目/工作 | 🔧 |

### 内容长度规范
- **理想长度**：一条笔记 100-300 字（Flomo 卡片设计适合碎片知识，过长需拆分）
- **拆分原则**：超过 2-3 段落的内容，按"主题 + 内容"拆成多条
- **不要堆标签**：每条 1-3 个 tag 最佳

## 使用步骤

### Step 1：确认 Flomo API 配置
从 `secrets.env` 读取 `SECRET_FLOMO_API_URL`：
```bash
source ~/Obsidian/kevinob/Openclaw/secrets.env
FLOMO_URL="${SECRET_FLOMO_API_URL}"
```

### Step 2：格式化内容
按照排版规范将用户内容转换为 Flomo 友好格式：
- 用 emoji 替代 Markdown 标题
- 去除所有 `**` `#` `---` 等 Markdown 语法（除了 #tag）
- 保留 `\n` 换行
- 在末尾添加 #tags

### Step 3：发送 API 请求
```bash
curl -s -X POST "${FLOMO_URL}" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"${CONTENT}\"}"
```

### Step 4：确认发送结果
- 返回 `"code":0` 表示成功
- 返回 `"message":"已记录"` 表示成功写入
- 如有错误，检查 content 中是否有未转义的双引号 `"`（需转为 `\"`）

## 示例：好的 Flomo 笔记

```
💡 AI Workflow 的核心杠杆点

Workflow 的质量上界取决于写它的人的领域认知深度——不是 AI 能力，是人的专业深度。

AI 提供执行力，你提供判断力。

→ 持续优化 workflow = 把新学到的最佳实践写进去

#AI工具链 #Workflow架构
```

## 注意事项

- content 中的双引号 `"` 必须转义为 `\"`，否则 JSON 格式错误
- content 中的单引号 `'` 无需转义
- 换行用 `\n`（JSON 字符串字面量）
- 每条笔记长度建议控制在 500 字以内（Flomo PRO 无限制，但过长影响阅读体验）
