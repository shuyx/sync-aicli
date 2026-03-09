#!/bin/bash
# acpx-cleanup.sh — 自动关闭超过指定时间的 idle acpx session
# 用法: acpx-cleanup.sh [max_age_hours]
# 默认: 关闭超过 1 小时的 session
#
# 建议挂 cron: 每小时执行一次
#   0 * * * * /path/to/acpx-cleanup.sh >> /tmp/acpx-cleanup.log 2>&1

set -uo pipefail

MAX_AGE_HOURS="${1:-1}"
MAX_AGE_SECONDS=$((MAX_AGE_HOURS * 3600))
NOW=$(date +%s)
CLOSED=0
SKIPPED=0

AGENTS=("claude" "opencode" "codex" "gemini")

for AGENT in "${AGENTS[@]}"; do
  # 获取 session 列表（跳过已 closed 的）
  SESSIONS=$(acpx "$AGENT" sessions 2>/dev/null | grep -v '\[closed\]' || true)

  if [ -z "$SESSIONS" ]; then
    continue
  fi

  while IFS= read -r LINE; do
    # 解析 session name 和时间
    # 格式: <id>  <name>  <cwd>  <timestamp>
    SESSION_NAME=$(echo "$LINE" | awk '{print $2}')
    TIMESTAMP=$(echo "$LINE" | awk '{print $NF}')

    if [ -z "$SESSION_NAME" ] || [ "$SESSION_NAME" = "-" ]; then
      continue
    fi

    # 转换 ISO 时间为 epoch（macOS 兼容）
    if command -v gdate &>/dev/null; then
      SESSION_EPOCH=$(gdate -d "$TIMESTAMP" +%s 2>/dev/null || echo 0)
    else
      # macOS date fallback
      SESSION_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${TIMESTAMP%%.*}" +%s 2>/dev/null || echo 0)
    fi

    if [ "$SESSION_EPOCH" -eq 0 ]; then
      continue
    fi

    AGE=$((NOW - SESSION_EPOCH))

    if [ "$AGE" -gt "$MAX_AGE_SECONDS" ]; then
      AGE_HOURS=$((AGE / 3600))
      echo "[$(date '+%H:%M:%S')] 关闭 ${AGENT}/${SESSION_NAME}（空闲 ${AGE_HOURS}h）"
      acpx "$AGENT" sessions close "$SESSION_NAME" 2>/dev/null && CLOSED=$((CLOSED + 1)) || true
    else
      SKIPPED=$((SKIPPED + 1))
    fi
  done <<< "$SESSIONS"
done

if [ "$CLOSED" -gt 0 ] || [ "$SKIPPED" -gt 0 ]; then
  echo "[$(date '+%H:%M:%S')] Session 清理: 关闭 ${CLOSED} 个, 保留 ${SKIPPED} 个"
fi

# === Part 2: 归档残留的 _prompt*.md 文件 ===
ARCHIVE_DIR="/tmp/acpx-prompts/$(date '+%Y%m%d')"
ARCHIVED=0

# 从 session 历史中收集所有 cwd 路径
CWDS=$(for AGENT in "${AGENTS[@]}"; do
  acpx "$AGENT" sessions 2>/dev/null | awk '{print $3}' | sort -u
done | sort -u)

for CWD_PATH in $CWDS; do
  if [ ! -d "$CWD_PATH" ]; then
    continue
  fi
  # 用 find 查找 _prompt*.md（只搜 2 层深度，避免误删）
  PROMPTS=$(find "$CWD_PATH" -maxdepth 2 -name "_prompt*.md" -type f 2>/dev/null || true)
  if [ -n "$PROMPTS" ]; then
    mkdir -p "$ARCHIVE_DIR"
    while IFS= read -r PFILE; do
      BASENAME=$(basename "$PFILE")
      PARENT=$(basename "$(dirname "$PFILE")")
      DEST="${ARCHIVE_DIR}/${PARENT}__${BASENAME}"
      mv "$PFILE" "$DEST" 2>/dev/null && ARCHIVED=$((ARCHIVED + 1)) || true
    done <<< "$PROMPTS"
  fi
done

if [ "$ARCHIVED" -gt 0 ]; then
  echo "[$(date '+%H:%M:%S')] Prompt 归档: ${ARCHIVED} 个文件 → ${ARCHIVE_DIR}/"
fi
