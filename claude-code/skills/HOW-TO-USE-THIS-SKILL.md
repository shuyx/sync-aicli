# 如何使用 Markdown 到 PDF Skill

## 概述

这是一个完整的、可复用的技能（Skill），用于将 Markdown 文档转换为高质量的 PDF 文件。包含详细文档、自动化脚本和多种实现方式。

---

## 文件结构说明

```
~/.claude/skills/
├── markdown-to-pdf-skill.md          ← 完整 Skill 文档（核心）
├── md-to-pdf-quickstart.sh           ← 一键自动化脚本（推荐）
├── MD-TO-PDF-QUICK-REFERENCE.txt     ← 快速参考卡片
├── README.md                          ← 导航和索引
└── HOW-TO-USE-THIS-SKILL.md          ← 本文件
```

---

## 三种使用方式

### 方式 1：使用一键脚本（⭐ 推荐，最简单）

**适合**: 快速转换单个或多个 Markdown 文件到 PDF

```bash
# 转换单个文件
bash ~/.claude/skills/md-to-pdf-quickstart.sh report.md

# 指定输出名
bash ~/.claude/skills/md-to-pdf-quickstart.sh report.md output.pdf

# 批量转换
for file in *.md; do
    bash ~/.claude/skills/md-to-pdf-quickstart.sh "$file"
done
```

### 方式 2：直接使用 Python 脚本

**适合**: 需要在 Python 项目中集成转换功能

```python
# 复制 markdown-to-pdf-skill.md 中的 Python 代码到你的项目
# 然后调用:

from pathlib import Path
import markdown
import subprocess

def md_to_pdf(md_file: str, pdf_file: str) -> bool:
    """将 Markdown 转换为 PDF"""
    # [实现代码见 markdown-to-pdf-skill.md 第 3-4 部分]
    pass

# 使用
md_to_pdf("report.md", "report.pdf")
```

### 方式 3：学习和定制

**适合**: 需要自定义样式、颜色、或集成到特定工作流

1. 阅读 `markdown-to-pdf-skill.md` 第 1-2 部分（理解工作流）
2. 阅读第 5 部分（CSS 样式自定义）
3. 修改脚本或创建自己的版本

---

## 何时使用这个 Skill

### ✅ 适用场景

- 📄 生成技术报告、调研文档
- 📊 将 Markdown 笔记转为 PDF
- 📋 批量处理多个 Markdown 文件
- 🎯 自动化文档生成流程
- 📚 创建标准化的团队文档
- 🔄 持续集成中的文档生成

### ❌ 不适用场景

- 需要高级数学公式排版（LaTeX）
- 需要复杂的多列布局
- 需要动态内容（PDF 表单、脚本）
- 需要 3D 或特殊媒体嵌入

---

## 快速开始（5 分钟）

### 步骤 1: 验证环境
```bash
# 检查 Chrome
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# 检查 Python
python3 --version

# 安装 markdown 库
pip install markdown
```

### 步骤 2: 创建示例 Markdown
创建文件 `example.md`:
```markdown
# 我的第一份 PDF 报告

## 介绍
这是一个示例文档。

## 特性
- 支持标题
- 支持列表
- 支持表格

| 特性 | 支持 |
|------|------|
| 中文 | ✅   |
| 表格 | ✅   |
| 代码 | ✅   |

## 代码示例
\`\`\`python
print("Hello, PDF!")
\`\`\`
```

### 步骤 3: 转换为 PDF
```bash
bash ~/.claude/skills/md-to-pdf-quickstart.sh example.md
# 输出: example.pdf ✅
```

---

## 常见使用模式

### 模式 1：在 Claude 对话中请求转换

**你**: "我有一份 Markdown 格式的产品规划文档，需要转为 PDF。可以帮我转换吗？"

**Claude**: 我会：
1. 建议使用这个 Skill
2. 帮你检查 Markdown 格式
3. 提供转换命令
4. 指导你运行脚本

### 模式 2：创建自动化流程

你可以：
- 在 GitHub Actions 中使用 Skill
- 在定时任务中使用 Skill
- 在项目构建流程中使用 Skill

### 模式 3：定制企业样式

复制脚本，修改 CSS：
```bash
# 创建自己的版本
cp ~/.claude/skills/md-to-pdf-quickstart.sh ./company-pdf-generator.sh

# 编辑公司色彩主题
vim company-pdf-generator.sh
# 修改 CSS 中的颜色值
```

---

## 与其他工具的区别

### vs. Pandoc
- **本 Skill**: 简单、开箱即用、无依赖
- **Pandoc**: 功能强大、学习曲线陡、依赖 LaTeX

### vs. wkhtmltopdf
- **本 Skill**: 基于 Chrome、排版现代、中文支持好
- **wkhtmltopdf**: 独立工具、需要额外安装

### vs. 在线工具
- **本 Skill**: 完全免费、本地运行、无隐私风险
- **在线工具**: 速度快、但有隐私和成本问题

---

## 常见问题

### Q: 我需要修改 PDF 的样式吗？

**A**: 默认样式（蓝色专业主题）已经很好看。如果需要修改：
1. 打开 `markdown-to-pdf-quickstart.sh`
2. 找到 `<style>` 部分
3. 修改颜色值（如 `#1f3a70` → `#your-color`）
4. 重新运行脚本

### Q: 可以在 CI/CD 流程中使用吗？

**A**: 完全可以！查看 `markdown-to-pdf-skill.md` 第 8 部分的 GitHub Actions 示例。

### Q: 如何处理大型文档（100+ 页）？

**A**: 脚本能处理，但可能需要：
- 增加 Chrome 内存限制（见 Skill 文档）
- 分割文档为多个文件并批量处理
- 等待更长的处理时间（30-60 秒）

### Q: 支持图片吗？

**A**: 支持！在 Markdown 中使用：
```markdown
![alt text](file:///absolute/path/to/image.png)
```

### Q: 能添加页码和页脚吗？

**A**: 可以。修改脚本中的 `--print-to-pdf-no-header` 参数，或在 CSS 中添加页脚样式。

---

## 下一步

### 如果你想：

**立即转换一个 Markdown 文件**  
→ 运行: `bash ~/.claude/skills/md-to-pdf-quickstart.sh your_file.md`

**了解完整的技术细节**  
→ 阅读: `~/.claude/skills/markdown-to-pdf-skill.md`

**快速查找命令**  
→ 查看: `~/.claude/skills/MD-TO-PDF-QUICK-REFERENCE.txt`

**修改样式或集成到项目**  
→ 参考: `markdown-to-pdf-skill.md` 第 5 和 8 部分

**在团队中推广使用**  
→ 分享: `README.md` 和快速参考卡片

**贡献改进或报告问题**  
→ 保存这个文件，以备将来参考

---

## 关键快捷方式

### 创建别名（可选但推荐）

添加到 `~/.bashrc` 或 `~/.zshrc`:
```bash
alias md2pdf='bash ~/.claude/skills/md-to-pdf-quickstart.sh'
```

然后可以直接使用：
```bash
md2pdf report.md
```

### 在脚本中调用

```bash
#!/bin/bash
# 在你的脚本中使用
bash ~/.claude/skills/md-to-pdf-quickstart.sh "$1"
```

---

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 输入格式 | Markdown | 标准 |
| Markdown 解析 | Python markdown | 3.x |
| HTML 生成 | 内置 CSS | CSS3 |
| 浏览器引擎 | Chromium | 88+ |
| 输出格式 | PDF | 1.4+ |
| 宿主系统 | Mac/Linux/Windows | 任何 |

---

## 许可和使用条款

- ✅ 自由使用
- ✅ 可修改和定制
- ✅ 可在商业项目中使用
- ✅ 可分享给团队
- ❌ 不需要署名（但欢迎）

---

## 最后的话

这个 Skill 被设计用于 **即插即用** — 你现在就可以开始使用，无需任何额外配置。随着你的使用加深，你可以逐渐定制和优化它以满足你的特定需求。

**祝你转换愉快！** 🎉

---

**创建日期**: 2026-02-02  
**最后更新**: 2026-02-02  
**版本**: 1.0  
**作者**: Claude Code Skill Team  
**许可证**: MIT
