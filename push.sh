#!/usr/bin/env bash
# push.sh — 一键将本机最新配置推送到 GitHub 仓库
# 用法：bash push.sh
# 自动完成：rsync 所有配置+skills → 路径占位符化 → git add/commit/push

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"

declare -A OBSIDIAN_MAP=(
  ["mac-minishu"]="/Users/mac-minishu/Obsidian/kevinob"
  ["yuanxin"]="/Users/yuanxin/documents/kevinob"
)

OBSIDIAN_PATH="${OBSIDIAN_MAP[$CURRENT_USER]:-}"
if [[ -z "$OBSIDIAN_PATH" ]]; then
  echo "⚠️  未识别用户名: $CURRENT_USER，请输入 Obsidian Vault 路径："
  read -r OBSIDIAN_PATH
fi

echo "🔄 同步本机最新配置到仓库..."
echo "   用户：$CURRENT_USER | Obsidian：$OBSIDIAN_PATH"
echo ""

# ── 将路径替换回占位符（通用化后存仓库）─────────────────
to_template() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  sed \
    -e "s|${OBSIDIAN_PATH}|OBSIDIAN_PATH|g" \
    -e "s|${HOME_PATH}|HOME_PATH|g" \
    "$src" > "$dst"
  echo "  ✅ $(basename "$dst")"
}

copy_direct() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "  ✅ $(basename "$dst")"
}

sync_skills() {
  local src="$1" dst="$2" label="$3"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    rsync -a --no-links --delete --exclude='*.pyc' --exclude='__pycache__' \
          --exclude='.DS_Store' "${src}/" "$dst/"
    local count
    count=$(find "$dst" -name "SKILL.md" | wc -l | tr -d ' ')
    echo "  ✅ $label ($count skills)"
  else
    echo "  ⚠️  跳过（不存在）：$src"
  fi
}

echo "── 配置文件 ──────────────────────────────────────────"
to_template    "${HOME_PATH}/.gemini/settings.json"               "${REPO_DIR}/antigravity/settings.json"
copy_direct    "${HOME_PATH}/.gemini/GEMINI.md"                   "${REPO_DIR}/antigravity/GEMINI.md"
copy_direct    "${HOME_PATH}/.claude/settings.json"               "${REPO_DIR}/claude-code/settings.json"
copy_direct    "${HOME_PATH}/.claude/CLAUDE.md"                   "${REPO_DIR}/claude-code/CLAUDE.md"
to_template    "${HOME_PATH}/.codex/config.toml"                  "${REPO_DIR}/codex/config.toml"
to_template    "${HOME_PATH}/.config/opencode/opencode.json"      "${REPO_DIR}/opencode/opencode.json"

echo ""
echo "── Skills ────────────────────────────────────────────"
sync_skills "${HOME_PATH}/.gemini/antigravity/skills" "${REPO_DIR}/antigravity/skills"       "Antigravity skills"
sync_skills "${HOME_PATH}/.claude/skills"             "${REPO_DIR}/claude-code/skills"       "Claude Code skills"
sync_skills "${HOME_PATH}/.agents/skills"             "${REPO_DIR}/shared/agents-skills"     "Shared .agents/skills"

echo ""
echo "── Git push ──────────────────────────────────────────"
cd "$REPO_DIR"
git add .

CHANGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CHANGED" -gt 0 ]]; then
  echo "  📝 变更文件（$CHANGED 项）："
  git diff --cached --name-only | sed 's/^/     /'
  git commit -m "chore: sync configs from ${CURRENT_USER} at $(date '+%Y-%m-%d %H:%M')"
  git push
  echo ""
  echo "✅ 推送成功！另一台电脑执行 git pull && bash install.sh 即可同步。"
else
  echo "  ℹ️  无变更，无需提交"
fi

echo ""
echo "── 当前能力摘要 ──────────────────────────────────────"
ANTI_COUNT=$(find "${REPO_DIR}/antigravity/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
CC_COUNT=$(find "${REPO_DIR}/claude-code/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
ANTI_MCP=$(python3 -c "import json; d=json.load(open('${REPO_DIR}/antigravity/settings.json')); print(len(d.get('mcpServers',{})))" 2>/dev/null || echo "?")

echo "  Antigravity : $ANTI_MCP MCP + $ANTI_COUNT Skills"
echo "  Claude Code : $CC_COUNT Skills"
echo "  仓库已更新，可分发到其他机器 ✅"
