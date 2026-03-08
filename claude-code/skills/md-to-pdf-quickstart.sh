#!/bin/bash
# ============================================
# Markdown 到 PDF 快速转换脚本
# 使用: ./md-to-pdf-quickstart.sh input.md [output.pdf]
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ 用法: $0 input.md [output.pdf]${NC}"
    echo -e "${BLUE}示例:${NC}"
    echo "  $0 report.md report.pdf"
    echo "  $0 report.md  # 自动生成 report.pdf"
    exit 1
fi

INPUT_MD="$1"
if [ -z "$2" ]; then
    OUTPUT_PDF="${INPUT_MD%.md}.pdf"
else
    OUTPUT_PDF="$2"
fi

# 验证输入文件
if [ ! -f "$INPUT_MD" ]; then
    echo -e "${RED}❌ 错误: 文件不存在 - $INPUT_MD${NC}"
    exit 1
fi

echo -e "${BLUE}📖 Markdown 到 PDF 转换器${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "📥 输入:  $INPUT_MD"
echo -e "📤 输出:  $OUTPUT_PDF"
echo ""

# Step 1: 检查依赖
echo -e "${YELLOW}[1/3] 检查依赖...${NC}"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 未安装${NC}"
    exit 1
fi

python3 -c "import markdown" 2>/dev/null || {
    echo -e "${YELLOW}   安装 markdown 库...${NC}"
    pip install markdown -q
}

echo -e "${GREEN}✅ 依赖检查完成${NC}"

# Step 2: Markdown 转 HTML
echo ""
echo -e "${YELLOW}[2/3] 转换 Markdown 为 HTML...${NC}"

TEMP_HTML="/tmp/$(basename "$INPUT_MD" .md)_temp_$(date +%s).html"

python3 << PYTHON_SCRIPT
import markdown
from pathlib import Path
import re

with open("$INPUT_MD", 'r', encoding='utf-8') as f:
    md_content = f.read()

html_body = markdown.markdown(
    md_content,
    extensions=['extra', 'tables', 'toc', 'codehilite']
)

# 修复：为所有标题添加 ID（支持 PDF 目录链接）
html_body = re.sub(
    r'<h([1-6])>([^<]+)</h([1-6])>',
    lambda m: f'<h{m.group(1)} id="{re.sub(r"[^a-z0-9]", "-", m.group(2).lower())}">{m.group(2)}</h{m.group(3)}>',
    html_body
)

css = """<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
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
p { margin: 10px 0; text-align: justify; }
table {
    width: 100%;
    border-collapse: collapse;
    margin: 15px 0;
    page-break-inside: avoid;
    font-size: 10pt;
}
thead { background-color: #1f3a70; color: white; }
th, td { padding: 8px 10px; border: 1px solid #ddd; }
tbody tr:nth-child(even) { background-color: #f9f9f9; }
pre {
    background-color: #f5f5f5;
    border-left: 3px solid #ff7f50;
    padding: 12px;
    margin: 12px 0;
    page-break-inside: avoid;
    overflow-x: auto;
}
code { font-family: 'Courier New', monospace; font-size: 9pt; }
strong { color: #ff7f50; font-weight: 700; }
a { color: #2d5a96; text-decoration: none; }
a:hover { text-decoration: underline; }
@page { 
    size: A4; 
    margin: 20mm;
    padding: 0;
}
@bottom-center { display: none; }
@page :first { margin-top: 20mm; }
@media print { 
    h1, h2, h3 { page-break-after: avoid; } 
    table, pre { page-break-inside: avoid; }
    body { margin: 0; padding: 0; }
    @page { margin: 20mm; }
}
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

with open("$TEMP_HTML", 'w', encoding='utf-8') as f:
    f.write(html)

print("HTML 生成成功")
PYTHON_SCRIPT

echo -e "${GREEN}✅ HTML 已生成${NC}"

# Step 3: HTML 转 PDF (Chrome Headless)
echo ""
echo -e "${YELLOW}[3/3] 生成 PDF...${NC}"

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    if [ ! -f "$CHROME" ]; then
        echo -e "${RED}❌ Chrome 未找到${NC}"
        echo -e "${YELLOW}请安装: brew install --cask google-chrome${NC}"
        exit 1
    fi
elif [ "$OS" = "Linux" ]; then
    CHROME="google-chrome"
    if ! command -v google-chrome &> /dev/null; then
        echo -e "${RED}❌ Chrome 未找到${NC}"
        echo -e "${YELLOW}请安装: sudo apt-get install google-chrome-stable${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ 不支持的操作系统: $OS${NC}"
    exit 1
fi

"$CHROME" \
    --headless \
    --disable-gpu \
    --print-to-pdf="$OUTPUT_PDF" \
    --print-to-pdf-no-header \
    --hide-scrollbars \
    "file://$TEMP_HTML" 2>/dev/null || {
    echo -e "${RED}❌ PDF 生成失败${NC}"
    rm -f "$TEMP_HTML"
    exit 1
}

echo -e "${GREEN}✅ PDF 已生成${NC}"

# 清理临时文件
rm -f "$TEMP_HTML"

# 验证输出
if [ -f "$OUTPUT_PDF" ]; then
    SIZE=$(du -h "$OUTPUT_PDF" | cut -f1)
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}✅ 转换成功！${NC}"
    echo -e "${BLUE}📄 文件: $OUTPUT_PDF${NC}"
    echo -e "${BLUE}📊 大小: $SIZE${NC}"
    echo -e "${BLUE}================================${NC}"
else
    echo -e "${RED}❌ PDF 文件未生成${NC}"
    exit 1
fi
