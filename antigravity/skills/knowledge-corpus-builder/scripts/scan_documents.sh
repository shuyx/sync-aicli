#!/bin/bash
# scan_documents.sh — 扫描源文档文件夹，统计文档数量和结构
# 用法: bash scan_documents.sh <source_dir>
# 示例: bash scan_documents.sh ~/Obsidian/kevinob/Cubox/智能制造

SOURCE_DIR="${1:?用法: scan_documents.sh <source_dir>}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ 目录不存在: $SOURCE_DIR"
  exit 1
fi

echo "📂 扫描目录: $SOURCE_DIR"
echo "---"

# 统计总文档数
TOTAL=$(find "$SOURCE_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
echo "📄 Markdown 文档总数: $TOTAL"

# 统计子目录
echo ""
echo "📁 子目录结构:"
for d in "$SOURCE_DIR"/*/; do
  if [ -d "$d" ]; then
    COUNT=$(find "$d" -name "*.md" -type f | wc -l | tr -d ' ')
    DIRNAME=$(basename "$d")
    echo "  - $DIRNAME/: $COUNT 篇"
  fi
done

# 统计根目录直属文件
ROOT_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
if [ "$ROOT_COUNT" -gt 0 ]; then
  echo "  - (根目录): $ROOT_COUNT 篇"
fi

# 文件大小统计
echo ""
echo "📏 文件大小分布:"
SMALL=$(find "$SOURCE_DIR" -name "*.md" -type f -size -5k | wc -l | tr -d ' ')
MEDIUM=$(find "$SOURCE_DIR" -name "*.md" -type f -size +5k -size -50k | wc -l | tr -d ' ')
LARGE=$(find "$SOURCE_DIR" -name "*.md" -type f -size +50k | wc -l | tr -d ' ')
echo "  - < 5KB (短文): $SMALL 篇"
echo "  - 5KB-50KB (中等): $MEDIUM 篇"
echo "  - > 50KB (长文): $LARGE 篇"

# 时间分布
echo ""
echo "📅 最近修改:"
echo "  最新: $(find "$SOURCE_DIR" -name "*.md" -type f -exec stat -f '%m %N' {} \; | sort -rn | head -1 | awk '{print $2}' | xargs basename)"
echo "  最旧: $(find "$SOURCE_DIR" -name "*.md" -type f -exec stat -f '%m %N' {} \; | sort -n | head -1 | awk '{print $2}' | xargs basename)"

echo ""
echo "---"
echo "✅ 扫描完成. 共 $TOTAL 篇文档."
