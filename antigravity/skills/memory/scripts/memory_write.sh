#!/usr/bin/env bash
# memory_write.sh — 写入结构化记忆条目到 Openclaw/records
# 用法: bash memory_write.sh --type <type> --title "标题" --content "内容" [--tags "tag1,tag2"] [--importance low|medium|high]

set -euo pipefail

# === 参数解析 ===
TYPE="quicknote"
TITLE=""
CONTENT=""
TAGS=""
IMPORTANCE="medium"
SOURCE="conversation"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)       TYPE="$2";       shift 2 ;;
    --title)      TITLE="$2";      shift 2 ;;
    --content)    CONTENT="$2";    shift 2 ;;
    --tags)       TAGS="$2";       shift 2 ;;
    --importance) IMPORTANCE="$2"; shift 2 ;;
    --source)     SOURCE="$2";     shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [ -z "$TITLE" ] || [ -z "$CONTENT" ]; then
  echo "错误: --title 和 --content 为必填参数"
  echo "用法: bash memory_write.sh --type quicknote --title \"标题\" --content \"内容\" --tags \"tag1,tag2\""
  exit 1
fi

# === 验证 type ===
case "$TYPE" in
  debug|architecture|project|research|quicknote) ;;
  *) echo "错误: type 必须是 debug/architecture/project/research/quicknote 之一"; exit 1 ;;
esac

# === 路径探测 ===
if [ -d "$HOME/Obsidian/kevinob/Openclaw/records" ]; then
  RECORDS_DIR="$HOME/Obsidian/kevinob/Openclaw/records"
elif [ -d "$HOME/documents/kevinob/Openclaw/records" ]; then
  RECORDS_DIR="$HOME/documents/kevinob/Openclaw/records"
else
  echo "错误: 找不到 Openclaw/records 目录"
  exit 1
fi

# === 确保子目录存在 ===
mkdir -p "$RECORDS_DIR/$TYPE"

# === 生成文件名 ===
DATE_PREFIX=$(date +%Y%m%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S+08:00)
# 将标题中的空格替换为连字符，移除特殊字符
SAFE_TITLE=$(echo "$TITLE" | tr ' ' '-' | tr -d '!@#$%^&*()[]{}|\\/<>?')
FILENAME="${DATE_PREFIX}-${SAFE_TITLE}.md"
FILEPATH="$RECORDS_DIR/$TYPE/$FILENAME"

# === 格式化 tags ===
if [ -n "$TAGS" ]; then
  TAGS_YAML=$(echo "$TAGS" | sed 's/,/, /g')
  TAGS_LINE="tags: [$TAGS_YAML]"
else
  TAGS_LINE="tags: []"
fi

# === 写入文件 ===
cat > "$FILEPATH" << HEREDOC
---
type: $TYPE
$TAGS_LINE
created: $TIMESTAMP
source: $SOURCE
importance: $IMPORTANCE
---

# $TITLE

$CONTENT
HEREDOC

echo "✅ 记忆已保存: $FILEPATH"
echo "类型: $TYPE | 重要性: $IMPORTANCE | 标签: $TAGS"
