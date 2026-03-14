#!/usr/bin/env bash
# memory_search.sh — 在 Openclaw/records 中搜索记忆
# 用法: bash memory_search.sh --query "关键词" [--type debug|architecture|project|research|quicknote]

set -euo pipefail

QUERY=""
TYPE=""
MAX_RESULTS=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)       QUERY="$2";       shift 2 ;;
    --type)        TYPE="$2";        shift 2 ;;
    --max-results) MAX_RESULTS="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [ -z "$QUERY" ]; then
  echo "错误: --query 为必填参数"
  echo "用法: bash memory_search.sh --query \"关键词\" [--type debug]"
  exit 1
fi

# === 路径探测 ===
if [ -d "$HOME/Obsidian/kevinob/Openclaw/records" ]; then
  RECORDS_DIR="$HOME/Obsidian/kevinob/Openclaw/records"
elif [ -d "$HOME/documents/kevinob/Openclaw/records" ]; then
  RECORDS_DIR="$HOME/documents/kevinob/Openclaw/records"
else
  echo "错误: 找不到 Openclaw/records 目录"
  exit 1
fi

# === 确定搜索范围 ===
SEARCH_DIR="$RECORDS_DIR"
if [ -n "$TYPE" ]; then
  case "$TYPE" in
    debug|architecture|project|research|quicknote)
      SEARCH_DIR="$RECORDS_DIR/$TYPE"
      ;;
    *) echo "警告: 未知类型 $TYPE，将搜索全部目录" ;;
  esac
fi

echo "🔍 搜索: \"$QUERY\" in $SEARCH_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === 执行搜索 ===
RESULTS=$(grep -rnI --include="*.md" "$QUERY" "$SEARCH_DIR" 2>/dev/null | head -n "$MAX_RESULTS" || true)

if [ -z "$RESULTS" ]; then
  echo "❌ 未找到匹配结果"
  exit 0
fi

# === 格式化输出 ===
MATCH_COUNT=$(echo "$RESULTS" | wc -l | tr -d ' ')
echo "找到 $MATCH_COUNT 条匹配:"
echo ""

echo "$RESULTS" | while IFS= read -r line; do
  FILE=$(echo "$line" | cut -d: -f1)
  LINE_NUM=$(echo "$line" | cut -d: -f2)
  CONTENT=$(echo "$line" | cut -d: -f3-)
  REL_PATH=${FILE#"$RECORDS_DIR/"}
  echo "📄 $REL_PATH:$LINE_NUM"
  echo "   $CONTENT"
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "提示：使用 --type 参数可缩小搜索范围"
