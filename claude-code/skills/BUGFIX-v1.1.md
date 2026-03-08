# Markdown to PDF Skill - v1.1 修复说明

**更新日期**: 2026-02-02  
**版本**: 1.0 → 1.1  
**修复项**: 2

---

## 🐛 修复内容

### 修复 1: 移除 PDF 底部的页脚地址显示

#### 问题
每页底部显示文档的原始文件路径（如 `file:///path/to/document.html`）

#### 解决方案
1. **CSS 修改**:
   - 添加 `@bottom-center { display: none; }` 隐藏页脚
   - 添加 `padding: 0;` 到 `@page` 规则

2. **Chrome 参数修改**:
   - 添加 `--hide-scrollbars` 参数
   - 确保 `--print-to-pdf-no-header` 正确工作

#### 修改文件
- ✅ `md-to-pdf-quickstart.sh` (第 130-157 行)
- ✅ `markdown-to-pdf-skill.md` (第 375+ 行的 Python 脚本)

#### 验证
运行转换后检查 PDF：页脚应该完全清空。

---

### 修复 2: 使目录链接可在 PDF 中跳转

#### 问题
生成的目录是静态链接，点击后无法在 PDF 中跳转到对应章节。

#### 根本原因
Markdown 的 `toc` 扩展生成的链接指向 HTML 锚点（如 `#heading-1`），但对应的标题元素没有 `id` 属性，导致链接无效。

#### 解决方案
添加 Python 正则表达式处理，为所有标题自动生成对应的 `id` 属性：

```python
import re

# 为所有 h1-h6 标题添加 ID
html_body = re.sub(
    r'<h([1-6])>([^<]+)</h([1-6])>',
    lambda m: f'<h{m.group(1)} id="{re.sub(r"[^a-z0-9]", "-", m.group(2).lower())}">{m.group(2)}</h{m.group(3)}>',
    html_body
)
```

**工作原理**:
- 匹配所有 `<h1>...<h1>` 到 `<h6>...<h6>` 标签
- 提取标题文本
- 生成 ID：将文本转小写，删除特殊字符，用 `-` 代替空格
- 示例：`<h2>第一章 介绍</h2>` → `<h2 id="第一章-介绍">第一章 介绍</h2>`

#### 修改文件
- ✅ `md-to-pdf-quickstart.sh` (第 65-77 行)
- ✅ `markdown-to-pdf-skill.md` (第 375+ 行的 Python 脚本)

#### 验证
1. 生成 PDF 后用 PDF 阅读器打开
2. 按 Cmd+Home 打开导航面板（如果有目录）
3. 点击目录中的链接，应能跳转到对应章节
4. 如果 PDF 没有内建导航面板，也可以尝试：
   - 按 Ctrl+Click (Mac: Cmd+Click) 点击目录中的链接
   - 在 PDF 中直接 Cmd+Click 链接

---

## 📝 更新清单

### 脚本更新 (`md-to-pdf-quickstart.sh`)

**第 65-77 行** - 添加 ID 生成代码：
```python
# 修复：为所有标题添加 ID（支持 PDF 目录链接）
html_body = re.sub(
    r'<h([1-6])>([^<]+)</h([1-6])>',
    lambda m: f'<h{m.group(1)} id="{re.sub(r"[^a-z0-9]", "-", m.group(2).lower())}">{m.group(2)}</h{m.group(3)}>',
    html_body
)
```

**第 130-157 行** - CSS 更新：
```css
@page { 
    size: A4; 
    margin: 20mm;
    padding: 0;
}
@bottom-center { display: none; }
@page :first { margin-top: 20mm; }
```

**第 181 行** - Chrome 参数更新：
```bash
"$CHROME" \
    --headless \
    --disable-gpu \
    --print-to-pdf="$OUTPUT_PDF" \
    --print-to-pdf-no-header \
    --hide-scrollbars \
    "file://$TEMP_HTML"
```

### 文档更新 (`markdown-to-pdf-skill.md`)

- 第 375+ 行：Python 脚本中添加 `import re` 和 ID 生成代码
- CSS 样式规则中添加页脚隐藏和链接样式

---

## ✅ 测试建议

### 测试 1: 验证无页脚

```bash
# 创建测试文件
cat > test.md << 'EOF'
# 测试文档

这是第一章。

## 第 1.1 节

内容...

## 第 1.2 节

更多内容...

# 第二章

第二章开始。
EOF

# 转换
bash md-to-pdf-quickstart.sh test.md

# 用 PDF 阅读器打开 test.pdf，检查底部是否无页脚
```

### 测试 2: 验证目录链接

```bash
# 如果 Markdown 文件包含目录（toc），生成的 PDF 应能跳转
# 或者手动在 Markdown 中添加目录：

cat > test_with_toc.md << 'EOF'
[TOC]

# 第一章

## 第 1.1 节

## 第 1.2 节

# 第二章

## 第 2.1 节
EOF

# 转换后在 PDF 中点击目录链接，应能跳转
```

---

## 🔄 更新方式

### 方式 1: 替换文件（推荐）

最新版本已包含所有修复：
```bash
# 最新版本已在 ~/.claude/skills/ 中更新
bash ~/.claude/skills/md-to-pdf-quickstart.sh your_file.md
```

### 方式 2: 手动更新旧版本

如果你有旧版本的脚本，可手动应用上述修改。

---

## 🆕 新功能说明

### 自动 ID 生成

现在所有标题自动获得 ID：

| 标题 | 生成的 ID |
|------|----------|
| `# Introduction` | `id="introduction"` |
| `## Key Features` | `id="key-features"` |
| `### 核心技术` | `id="核心技术"` |
| `#### API Reference` | `id="api-reference"` |

### 页脚隐藏

CSS 规则 `@bottom-center { display: none; }` 完全隐藏页脚。

---

## ⚠️ 已知限制

1. **PDF 目录导航面板**
   - Chrome 生成的 PDF 可能不包含自动生成的导航面板（bookmarks）
   - 但内部链接（点击链接跳转）功能完整

2. **Markdown toc 扩展**
   - 需要在 Markdown 中显式使用 `[TOC]` 来生成目录
   - 或使用 `---` 分隔符来确保分页

3. **特殊字符处理**
   - 中文标题会直接用于 ID（如 `id="核心技术"` 而非转换为 pinyin）
   - 这在大多数 PDF 阅读器中正常工作

---

## 📌 推荐实践

### 为了获得最佳效果：

1. **在 Markdown 中添加目录**:
   ```markdown
   # 我的文档
   
   [TOC]
   
   ## 第一章
   ...
   ```

2. **使用清晰的标题结构**:
   ```markdown
   # 一级标题
   ## 二级标题
   ### 三级标题
   ```

3. **避免在标题中使用特殊字符**:
   ```markdown
   ✅ # Chapter 1: Introduction
   ❌ # Chapter 1: Int@roduction!
   ```

---

## 🔗 相关链接

- 完整 Skill 文档: `markdown-to-pdf-skill.md`
- 快速参考: `MD-TO-PDF-QUICK-REFERENCE.txt`
- 使用指南: `HOW-TO-USE-THIS-SKILL.md`

---

## 版本历史

| 版本 | 日期 | 更改 |
|------|------|------|
| 1.0 | 2026-02-02 | 初版发布 |
| 1.1 | 2026-02-02 | ✅ 移除页脚 + ✅ 修复目录链接 |

---

**🎉 所有修复已应用，现在享受改进的 Markdown to PDF 体验！**
