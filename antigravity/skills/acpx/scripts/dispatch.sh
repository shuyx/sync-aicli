#!/bin/bash
# acpx-dispatch.sh — acpx 多 Agent 任务派发辅助脚本
# 用法: acpx-dispatch.sh <agent> <session-name> <prompt-file> [cwd]
#
# 功能:
# 1. 自动 sessions ensure（幂等创建 session）
# 2. 自动处理 --approve-all（Gemini 除外）
# 3. 以 --no-wait 模式后台派发
# 4. 输出结构化日志
#
# 示例:
#   acpx-dispatch.sh claude doc-task ./prompt.md /path/to/project
#   acpx-dispatch.sh opencode fix-task ./prompt.md
#   acpx-dispatch.sh gemini research ./prompt.md

set -euo pipefail

AGENT="${1:?用法: acpx-dispatch.sh <agent> <session-name> <prompt-file> [cwd]}"
SESSION="${2:?缺少 session 名}"
PROMPT_FILE="${3:?缺少 prompt 文件路径}"
CWD="${4:-$(pwd)}"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[acpx-dispatch]${NC} Agent=${AGENT} Session=${SESSION}"
echo -e "${GREEN}[acpx-dispatch]${NC} Prompt=${PROMPT_FILE}"
echo -e "${GREEN}[acpx-dispatch]${NC} CWD=${CWD}"

# 检查 prompt 文件存在
if [ ! -f "$PROMPT_FILE" ]; then
  echo -e "${RED}[ERROR]${NC} Prompt 文件不存在: ${PROMPT_FILE}"
  exit 1
fi

# Step 1: sessions ensure（幂等）
echo -e "${YELLOW}[1/3]${NC} 确保 session 存在..."
acpx --cwd "$CWD" "$AGENT" sessions ensure --name "$SESSION" 2>&1

# Step 2: 构建派发命令
APPROVE_FLAG=""
if [ "$AGENT" != "gemini" ]; then
  APPROVE_FLAG="--approve-all"
fi

# Step 3: 派发
echo -e "${YELLOW}[2/3]${NC} 派发任务..."
acpx --cwd "$CWD" $APPROVE_FLAG "$AGENT" -s "$SESSION" --no-wait -f "$PROMPT_FILE" 2>&1

echo -e "${GREEN}[3/3]${NC} ✅ 任务已入队: ${AGENT}/${SESSION}"
echo -e "${GREEN}[acpx-dispatch]${NC} 监控: acpx ${AGENT} -s ${SESSION} status"
