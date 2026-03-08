---
name: markdown-to-pdf
description: |
  将 Markdown 文档转换为高质量的 PDF 文件。使用 Chrome 无头浏览器引擎进行渲染，
  支持中文、代码高亮、表格等。适用于生成技术报告、调研文档、会议记录等场景。
---

# Markdown to PDF Skill

## 概述

将 Markdown 文档转换为高质量 PDF 文件的工具，使用 Chrome 浏览器引擎渲染，确保样式现代、排版美观。

## 使用场景

- 📄 生成技术报告、调研文档
- 📊 将 Markdown 笔记转为 PDF
- 📋 批量处理多个 Markdown 文件
- 🎯 自动化文档生成流程
- 📚 创建标准化的团队文档

## 快速使用

### 一键脚本

```bash
bash ~/.claude/skills/markdown-to-pdf-skill/md-to-pdf-quickstart.sh report.md
```

### 指定输出文件名

```bash
bash ~/.claude/skills/markdown-to-pdf-skill/md-to-pdf-quickstart.sh report.md output.pdf
```

### 批量转换

```bash
for file in *.md; do
    bash ~/.claude/skills/markdown-to-pdf-skill/md-to-pdf-quickstart.sh "$file"
done
```

## Python 实现

```python
import markdown
import subprocess
from pathlib import Path

def md_to_pdf(md_file: str, pdf_file: str = None) -> bool:
    """将 Markdown 转换为 PDF"""
    md_path = Path(md_file)
    if pdf_file is None:
        pdf_file = md_path.with_suffix('.pdf')
    
    # 读取 Markdown
    md_content = md_path.read_text(encoding='utf-8')
    
    # 转换为 HTML
    html_content = markdown.markdown(
        md_content,
        extensions=['tables', 'fenced_code', 'codehilite', 'toc']
    )
    
    # 添加 CSS 样式
    styled_html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
body {{ font-family: 'Helvetica Neue', Arial, sans-serif; padding: 40px; line-height: 1.6; color: #333; }}
h1 {{ color: #1f3a70; border-bottom: 2px solid #1f3a70; padding-bottom: 8px; }}
h2 {{ color: #2c5282; }}
code {{ background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }}
pre {{ background: #f5f5f5; padding: 16px; border-radius: 6px; overflow-x: auto; }}
table {{ border-collapse: collapse; width: 100%; }}
th, td {{ border: 1px solid #ddd; padding: 8px 12px; text-align: left; }}
th {{ background: #1f3a70; color: white; }}
</style>
</head>
<body>{html_content}</body>
</html>"""
    
    # 写入临时 HTML
    tmp_html = Path('/tmp/md_to_pdf_temp.html')
    tmp_html.write_text(styled_html, encoding='utf-8')
    
    # Chrome 无头模式转 PDF
    chrome_path = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
    subprocess.run([
        chrome_path, '--headless', '--disable-gpu',
        f'--print-to-pdf={pdf_file}',
        '--print-to-pdf-no-header',
        str(tmp_html)
    ], check=True)
    
    return Path(pdf_file).exists()
```

## 环境要求

| 组件 | 版本 |
|------|------|
| Python | 3.x |
| markdown (pip) | 3.x |
| Google Chrome | 88+ |

## 常见问题

- **Chrome 路径不对**: macOS 默认在 `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
- **中文乱码**: 确保 HTML 头部有 `<meta charset="utf-8">`
- **大文档超时**: 增加 Chrome 超时参数或分割文档处理
