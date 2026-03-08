#!/usr/bin/env bash
# diff.sh — 对比仓库配置与本机当前配置的差异（安装前审查用）
# 用法：bash diff.sh
# 绿色行 = 仓库中有，本机没有（将新增）
# 红色行 = 仓库与本机不同（将覆盖）

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"

declare -A OBSIDIAN_MAP=(
  ["mac-minishu"]="/Users/mac-minishu/Obsidian/kevinob"
  ["yuanxin"]="/Users/yuanxin/documents/kevinob"
)
OBSIDIAN_PATH="${OBSIDIAN_MAP[$CURRENT_USER]:-OBSIDIAN_PATH}"

# 将仓库配置中的占位符替换后与本机对比
diff_config() {
  local repo_file="$1"
  local local_file="$2"
  local label="$3"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📄 $label"
  echo "   仓库：$repo_file"
  echo "   本机：$local_file"

  if [[ ! -f "$repo_file" ]]; then
    echo "   ⚠️  仓库中无此文件，跳过"
    return
  fi

  # 替换占位符到临时文件
  local tmp
  tmp=$(mktemp)
  sed \
    -e "s|OBSIDIAN_PATH|${OBSIDIAN_PATH}|g" \
    -e "s|HOME_PATH|${HOME_PATH}|g" \
    "$repo_file" > "$tmp"

  if [[ ! -f "$local_file" ]]; then
    echo "   🆕 本机无此文件（将新建）"
    rm -f "$tmp"
    return
  fi

  if diff -q "$tmp" "$local_file" > /dev/null 2>&1; then
    echo "   ✅ 无差异（已是最新）"
  else
    echo "   🔄 存在差异："
    diff --color=always "$local_file" "$tmp" | head -40 || true
  fi

  rm -f "$tmp"
  echo ""
}

echo "═══════════════════════════════════════════"
echo "🔍 配置差异审查 (仓库 vs 本机)"
echo "   用户：$CURRENT_USER | Obsidian：$OBSIDIAN_PATH"
echo "═══════════════════════════════════════════"
echo ""

diff_config \
  "${REPO_DIR}/antigravity/settings.json" \
  "${HOME_PATH}/.gemini/settings.json" \
  "Antigravity settings.json"

diff_config \
  "${REPO_DIR}/claude-code/settings.json" \
  "${HOME_PATH}/.claude/settings.json" \
  "Claude Code settings.json"

diff_config \
  "${REPO_DIR}/claude-code/CLAUDE.md" \
  "${HOME_PATH}/.claude/CLAUDE.md" \
  "Claude Code CLAUDE.md"

diff_config \
  "${REPO_DIR}/codex/config.toml" \
  "${HOME_PATH}/.codex/config.toml" \
  "Codex config.toml"

diff_config \
  "${REPO_DIR}/opencode/opencode.json" \
  "${HOME_PATH}/.config/opencode/opencode.json" \
  "OpenCode opencode.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "审查完成。如确认无误，执行：bash install.sh"
