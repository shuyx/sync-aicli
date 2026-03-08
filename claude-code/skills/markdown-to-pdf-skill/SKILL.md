---
name: markdown-to-pdf-skill
description: "Convert Markdown documents into polished PDF files with reliable Chinese support and styling options."
---

# Markdown 到 PDF 完整转换 Skill

**Skill 名称**: Markdown to PDF Converter  
**版本**: 1.0  
**作者**: Claude Code  
**最后更新**: 2026-02-02  
**难度**: ⭐⭐⭐ (中等)  
**应用场景**: 报告生成、文档排版、演示资料输出

---

## 一、Skill 概述

### 功能定义
将 Markdown 格式的文档转换为排版精美、专业的 PDF 文件，支持中文、表格、代码块、链接等复杂元素。

### 适用场景
- ✅ 技术报告生成（调研报告、可行性分析）
- ✅ 商业文档输出（融资计划书、产品规划）
- ✅ 学术论文排版
- ✅ 知识库文档导出
- ✅ 日志或议题的正式版本

### 核心优势
- **快速高效**: 3 个步骤完成 Markdown → PDF
- **排版精美**: 支持自定义 CSS 样式、主题色、字体
- **完全兼容**: 支持表格、代码块、公式、链接、图片
- **无依赖冲突**: 使用浏览器内核，避免环境配置复杂性
- **跨平台**: Mac、Windows、Linux 均适用

---

## 二、完整工作流程

### 方案选择（3 种方案对比）

| 方案 | 优点 | 缺点 | 推荐度 | 环境要求 |
|------|------|------|--------|---------|
| **方案 A: Chrome Headless** | ✅ 最可靠、排版最完美、无依赖 | 需要 Chrome 浏览器 | ⭐⭐⭐⭐⭐ | Chrome 或 Chromium |
| **方案 B: Pandoc + LaTeX** | ✅ 功能强大、支持复杂排版 | ❌ 依赖多、配置复杂、中文支持难 | ⭐⭐⭐ | Pandoc, xelatex |
| **方案 C: Python 库（xhtml2pdf）** | ✅ 部署简单、Python 原生 | ❌ 样式支持有限、中文支持弱 | ⭐⭐ | Python 3.7+ |

**推荐**: 使用 **方案 A（Chrome Headless）**，理由：
- 最简洁可靠
- 不依赖外部库
- 排版效果最好
- 中文支持完善
- 跨平台最佳

---

## 三、实施步骤（三步法）

### Step 1: 准备 Markdown 文件

**要求**:
- ✅ UTF-8 编码
- ✅ 使用标准 Markdown 语法（#, ##, ###, 等）
- ✅ 表格使用 | 格式
- ✅ 代码块用 ``` 包围
- ✅ 图片使用相对路径或完整 URL

**示例 Markdown 结构**:
```markdown
# 报告标题

**作者**: 名字  
**日期**: 2026-02-02

---

## 第一章 简介

### 1.1 背景

正文内容...

| 列1 | 列2 |
|-----|-----|
| A   | B   |

### 1.2 方法

```python
print("Hello, World!")
```

## 第二章 分析

...
```

---

### Step 2: 创建 HTML 中间文件

**Python 脚本** (`md_to_html.py`):

```python
import markdown
from pathlib import Path

def markdown_to_html(md_file: str, output_html: str) -> str:
    """将 Markdown 转换为 HTML（带 CSS 样式）"""
    
    md_file = Path(md_file)
    output_html = Path(output_html)
    
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    html_body = markdown.markdown(
        md_content,
        extensions=['extra', 'tables', 'toc', 'codehilite']
    )
    
    css = """
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif;
            font-size: 11pt;
            line-height: 1.7;
            color: #2c3e50;
        }
        
        h1 {
            font-size: 26pt;
            font-weight: 700;
            color: #1f3a70;
            margin: 25px 0 15px 0;
            padding-bottom: 12px;
            border-bottom: 3px solid #ff7f50;
            page-break-after: avoid;
        }
        
        h2 {
            font-size: 18pt;
            font-weight: 700;
            color: #1f3a70;
            margin: 20px 0 12px 0;
            padding-left: 10px;
            border-left: 4px solid #ff7f50;
            page-break-after: avoid;
        }
        
        h3 {
            font-size: 14pt;
            font-weight: 700;
            color: #2d5a96;
            margin: 15px 0 10px 0;
            page-break-after: avoid;
        }
        
        p {
            margin: 10px 0;
            text-align: justify;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            page-break-inside: avoid;
            font-size: 10pt;
        }
        
        thead {
            background-color: #1f3a70;
            color: white;
        }
        
        th, td {
            padding: 8px 10px;
            border: 1px solid #ddd;
        }
        
        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        pre {
            background-color: #f5f5f5;
            border-left: 3px solid #ff7f50;
            padding: 12px;
            margin: 12px 0;
            page-break-inside: avoid;
            overflow-x: auto;
        }
        
        code {
            font-family: 'Courier New', monospace;
            font-size: 9pt;
        }
        
        strong {
            color: #ff7f50;
            font-weight: 700;
        }
        
        @page {
            size: A4;
            margin: 20mm;
        }
        
        @media print {
            h1, h2, h3 { page-break-after: avoid; }
            table, pre { page-break-inside: avoid; }
        }
    </style>
    """
    
    html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    {css}
</head>
<body style="padding: 20px;">
    {html_body}
</body>
</html>
"""
    
    with open(output_html, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"✅ HTML 已生成: {output_html}")
    return str(output_html)
```

**使用方式**:
```bash
python3 md_to_html.py input.md output.html
```

---

### Step 3: 使用 Chrome Headless 转换为 PDF

#### 3a. 检查 Chrome 安装

**Mac**:
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --version
```

**Windows**:
```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --version
```

**Linux**:
```bash
google-chrome --version
# 如果未安装:
sudo apt-get install google-chrome-stable
```

#### 3b. 使用 Chrome 命令行生成 PDF

**Mac/Linux**:
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --print-to-pdf="output.pdf" \
  --print-to-pdf-no-header \
  "file:///absolute/path/to/input.html"
```

**Windows** (PowerShell):
```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --headless `
  --disable-gpu `
  --print-to-pdf="output.pdf" `
  --print-to-pdf-no-header `
  "file:///C:/absolute/path/to/input.html"
```

#### 3c. Python 自动化脚本

```python
import subprocess
from pathlib import Path
import platform
import os

def html_to_pdf(html_file: str, pdf_file: str) -> bool:
    """使用 Chrome Headless 将 HTML 转换为 PDF"""
    
    html_path = Path(html_file).absolute()
    pdf_path = Path(pdf_file).absolute()
    
    if not html_path.exists():
        print(f"❌ HTML 文件不存在: {html_path}")
        return False
    
    system = platform.system()
    
    if system == "Darwin":  # macOS
        chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    elif system == "Windows":
        chrome_path = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
    else:  # Linux
        chrome_path = "google-chrome"
    
    if not Path(chrome_path).exists() and system != "Linux":
        print(f"❌ Chrome 未找到: {chrome_path}")
        return False
    
    cmd = [
        chrome_path,
        "--headless",
        "--disable-gpu",
        f'--print-to-pdf="{pdf_path}"',
        "--print-to-pdf-no-header",
        "--hide-scrollbars",
        f"file://{html_path}"
    ]
    
    print(f"🔄 正在转换... ({html_path.name})")
    
    try:
        result = subprocess.run(cmd, capture_output=True, timeout=60)
        
        if result.returncode == 0 and pdf_path.exists():
            size_mb = pdf_path.stat().st_size / (1024 * 1024)
            print(f"✅ PDF 已生成")
            print(f"📄 位置: {pdf_path}")
            print(f"📊 大小: {size_mb:.2f} MB")
            return True
        else:
            print(f"❌ 转换失败: {result.stderr.decode('utf-8', errors='ignore')}")
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ 转换超时（超过 60 秒）")
        return False
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False
```

**使用方式**:
```python
html_to_pdf("input.html", "output.pdf")
```

---

## 四、完整一键脚本

### 整合脚本 (md_to_pdf.py)

```python
#!/usr/bin/env python3
"""
Markdown 到 PDF 完整转换脚本
使用: python3 md_to_pdf.py input.md output.pdf
"""

import markdown
import subprocess
from pathlib import Path
import platform
import sys
import re

def md_to_html(md_file: str) -> str:
    """Markdown 转 HTML"""
    md_path = Path(md_file)
    html_path = md_path.with_suffix('.html')
    
    with open(md_path, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    html_body = markdown.markdown(
        md_content,
        extensions=['extra', 'tables', 'toc', 'codehilite']
    )
    
    # 修复1：为所有标题添加 ID（支持 PDF 目录链接跳转）
    html_body = re.sub(
        r'<h([1-6])>([^<]+)</h([1-6])>',
        lambda m: f'<h{m.group(1)} id="{re.sub(r"[^a-z0-9]", "-", m.group(2).lower())}">{m.group(2)}</h{m.group(3)}>',
        html_body
    )
    
    css = """<style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Microsoft YaHei", sans-serif; font-size: 11pt; line-height: 1.7; color: #2c3e50; }
        h1 { font-size: 26pt; font-weight: 700; color: #1f3a70; margin: 25px 0 15px; padding-bottom: 12px; border-bottom: 3px solid #ff7f50; page-break-after: avoid; }
        h2 { font-size: 18pt; font-weight: 700; color: #1f3a70; margin: 20px 0 12px; padding-left: 10px; border-left: 4px solid #ff7f50; page-break-after: avoid; }
        h3 { font-size: 14pt; font-weight: 700; color: #2d5a96; margin: 15px 0 10px; page-break-after: avoid; }
        p { margin: 10px 0; text-align: justify; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; page-break-inside: avoid; font-size: 10pt; }
        thead { background-color: #1f3a70; color: white; }
        th, td { padding: 8px 10px; border: 1px solid #ddd; }
        tbody tr:nth-child(even) { background-color: #f9f9f9; }
        pre { background-color: #f5f5f5; border-left: 3px solid #ff7f50; padding: 12px; margin: 12px 0; page-break-inside: avoid; overflow-x: auto; }
        code { font-family: 'Courier New', monospace; font-size: 9pt; }
        strong { color: #ff7f50; font-weight: 700; }
        a { color: #2d5a96; text-decoration: none; }
        a:hover { text-decoration: underline; }
        @page { size: A4; margin: 20mm; padding: 0; }
        @bottom-center { display: none; }
        @page :first { margin-top: 20mm; }
        @media print { h1, h2, h3 { page-break-after: avoid; } table, pre { page-break-inside: avoid; } body { margin: 0; padding: 0; } @page { margin: 20mm; } }
    </style>"""
    
    html = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    {css}
</head>
<body style="padding: 20px;">
    {html_body}
</body>
</html>"""
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"✅ HTML 已生成: {html_path}")
    return str(html_path)

def html_to_pdf(html_file: str, pdf_file: str) -> bool:
    """HTML 转 PDF"""
    html_path = Path(html_file).absolute()
    pdf_path = Path(pdf_file).absolute()
    
    system = platform.system()
    
    if system == "Darwin":
        chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    elif system == "Windows":
        chrome = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
    else:
        chrome = "google-chrome"
    
    cmd = [
        chrome,
        "--headless",
        "--disable-gpu",
        f'--print-to-pdf="{pdf_path}"',
        "--print-to-pdf-no-header",
        f"file://{html_path}"
    ]
    
    print(f"🔄 正在生成 PDF...")
    
    try:
        result = subprocess.run(cmd, capture_output=True, timeout=60)
        
        if result.returncode == 0 and pdf_path.exists():
            size = pdf_path.stat().st_size / (1024 * 1024)
            print(f"✅ PDF 已生成")
            print(f"📄 位置: {pdf_path}")
            print(f"📊 大小: {size:.2f} MB")
            return True
        else:
            print(f"❌ 失败: {result.stderr.decode('utf-8', errors='ignore')}")
            return False
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("使用: python3 md_to_pdf.py input.md [output.pdf]")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2] if len(sys.argv) > 2 else Path(md_file).with_suffix('.pdf')
    
    html_file = md_to_html(md_file)
    success = html_to_pdf(html_file, pdf_file)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

**使用方式**:
```bash
# 方式 1: 指定输出文件名
python3 md_to_pdf.py report.md report.pdf

# 方式 2: 自动使用同名 PDF
python3 md_to_pdf.py report.md
```

---

## 五、CSS 样式自定义

### 预设主题

#### 主题 1: 蓝色专业（推荐）
```css
h1 { color: #1f3a70; border-bottom: 3px solid #ff7f50; }
h2 { color: #1f3a70; border-left: 4px solid #ff7f50; }
strong { color: #ff7f50; }
table thead { background-color: #1f3a70; }
```

#### 主题 2: 绿色科技
```css
h1 { color: #2d5016; border-bottom: 3px solid #4caf50; }
h2 { color: #2d5016; border-left: 4px solid #4caf50; }
strong { color: #4caf50; }
table thead { background-color: #2d5016; }
```

#### 主题 3: 暗黑模式
```css
body { color: #ecf0f1; background-color: #2c3e50; }
h1, h2 { color: #ecf0f1; }
table { background-color: #34495e; }
```

---

## 六、故障排除

### 问题 1: Chrome 未找到

**症状**: `❌ Chrome 未找到`

**解决方案**:
```bash
# macOS
brew install --cask google-chrome

# Windows
# 访问 https://www.google.com/chrome/ 下载安装

# Linux
sudo apt-get install google-chrome-stable
```

### 问题 2: PDF 中文显示乱码

**症状**: 生成的 PDF 中文显示为空白或乱码

**解决方案**:
- 确保 HTML 有 `<meta charset="UTF-8">`
- 确保 CSS 包含 `font-family` 支持中文（如 "Microsoft YaHei", "SimSun"）
- 确保 Markdown 文件本身是 UTF-8 编码

### 问题 3: 表格跨页分割

**症状**: 表格被分割到多个页面

**解决方案**:
在 CSS 中添加:
```css
table {
    page-break-inside: avoid;
    break-inside: avoid;
}
```

### 问题 4: 图片不显示

**症状**: HTML 中的图片在 PDF 中未显示

**解决方案**:
- 使用**绝对路径**或完整 URL
- 不要使用相对路径（如 `./images/pic.png`）
- 示例: `![图片](file:///absolute/path/to/image.png)`

---

## 七、性能优化

### 大文件处理

对于 > 100 页的大型文档：

```bash
# 增加 Chrome 内存限制
"$CHROME" --headless --disable-gpu \
  --memory-pressure-off \
  --print-to-pdf="output.pdf" \
  "file:///$HTML"
```

### 多文件批处理

```bash
#!/bin/bash
for md_file in *.md; do
    echo "处理: $md_file"
    python3 md_to_pdf.py "$md_file"
done
```

---

## 八、集成示例

### 与项目自动化集成

**GitHub Actions 示例** (`.github/workflows/md-to-pdf.yml`):

```yaml
name: Generate PDF Reports

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y google-chrome-stable
          pip install markdown
      
      - name: Generate PDFs
        run: |
          for md_file in reports/*.md; do
            python3 md_to_pdf.py "$md_file"
          done
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: pdf-reports
          path: reports/*.pdf
```

---

## 九、最佳实践

### ✅ DO（推荐）

- ✅ 使用清晰的标题层级（H1 → H2 → H3）
- ✅ 定期保存 Markdown 原始文件
- ✅ 为复杂表格提供备选文本说明
- ✅ 使用代码高亮（\`\`\`python）
- ✅ 在 Markdown 中使用清晰的视觉分隔符（---）

### ❌ DON'T（避免）

- ❌ 不要在 Markdown 中嵌入 HTML（会破坏排版）
- ❌ 不要使用相对路径引用外部文件
- ❌ 不要在一行中放置过多内容（> 100 字）
- ❌ 不要频繁更改文件编码
- ❌ 不要在表格中使用复杂格式

---

## 十、常见模板

### 商业报告模板

```markdown
# 商业报告标题

**公司名**: XXX  
**报告日期**: 2026-02-02  
**作者**: 名字  
**机密级别**: 内部使用

---

## 执行摘要

简要说明报告内容...

## 1. 背景分析

### 1.1 市场现状

表格数据...

### 1.2 竞争对标

| 项目 | A公司 | B公司 | 我们 |
|------|-------|-------|------|
| 价格 | 100k  | 50k   | 30k  |
| 功能 | 完整  | 基础  | 完整 |

## 2. 建议方案

关键代码示例：

```python
def strategy():
    return "执行计划"
```

## 3. 财务预测

详细数据和分析...

---

**报告完成**
```

---

## 十一、总结

### 核心工作流

```
Markdown 文件
    ↓
Step 1: Python markdown 库 → HTML（CSS 样式）
    ↓
Step 2: 验证 Chrome 安装
    ↓
Step 3: Chrome Headless → PDF（print 模式）
    ↓
高质量 PDF 输出
```

### 优势总结

| 维度 | 评价 |
|------|------|
| **速度** | ⭐⭐⭐⭐⭐ 1 分钟完成 |
| **质量** | ⭐⭐⭐⭐⭐ 出版级排版 |
| **兼容性** | ⭐⭐⭐⭐⭐ 跨平台完全支持 |
| **易用性** | ⭐⭐⭐⭐⭐ 一键生成 |
| **成本** | ⭐⭐⭐⭐⭐ 完全免费 |

---

## 12. 参考资源

### 工具链
- **Markdown 库**: https://github.com/Python-Markdown/markdown
- **Chrome 命令行**: https://chromedriver.chromium.org/
- **Markdown 语法**: https://www.markdownguide.org/

### 相关 Skills
- HTML & CSS 排版优化
- 自动化文档生成
- Python 脚本编写

### 常见问题 FAQ
见第六部分（故障排除）

---

**Skill 更新日志**:
- v1.0 (2026-02-02): 初版发布，包含完整工作流、脚本、故障排除

**贡献者**: Claude Code Team  
**License**: MIT（自由使用和修改）
