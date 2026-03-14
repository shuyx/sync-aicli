#!/usr/bin/env bash
# push.sh — 一键将本机最新配置推送到 GitHub 仓库
# 用法：bash push.sh
# 自动完成：rsync 所有配置+skills → 路径占位符化 → git add/commit/push

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"

OBSIDIAN_PATH=""
case "$CURRENT_USER" in
  "mac-minishu") OBSIDIAN_PATH="/Users/mac-minishu/Obsidian/kevinob" ;;
  "yuanxin") OBSIDIAN_PATH="/Users/yuanxin/Documents/kevinob" ;;
esac
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
          --exclude='.DS_Store' --exclude='.git' "${src}/" "$dst/"
    local count
    count=$(find "$dst" -name "SKILL.md" | wc -l | tr -d ' ')
    echo "  ✅ $label ($count skills)"
  else
    echo "  ⚠️  跳过（不存在）：$src"
  fi
}

strip_secrets() {
  local file="$1"
  local secrets_file="${OBSIDIAN_PATH}/secrets.env"
  if [[ ! -f "$secrets_file" ]]; then
    echo "  ⚠️  密钥金库不存在: $secrets_file，跳过脱敏"
    return
  fi
  set +u
  source "$secrets_file"
  set -u
  # Phase 1: 精确变量替换（从 secrets.env 读取的当前值）
  sed -i '' \
    -e "s|${SECRET_GITHUB_PAT:-__SKIP__}|__SECRET_GITHUB_PAT__|g" \
    -e "s|${SECRET_AI4SCHOLAR_TOKEN:-__SKIP__}|__SECRET_AI4SCHOLAR_TOKEN__|g" \
    -e "s|${SECRET_EXA_API_KEY:-__SKIP__}|__SECRET_EXA_API_KEY__|g" \
    -e "s|${SECRET_WEB_SEARCH_PRIME_TOKEN:-__SKIP__}|__SECRET_WEB_SEARCH_PRIME_TOKEN__|g" \
    -e "s|${SECRET_BRAVE_API_KEY:-__SKIP__}|__SECRET_BRAVE_API_KEY__|g" \
    -e "s|${SECRET_TAVILY_API_KEY:-__SKIP__}|__SECRET_TAVILY_API_KEY__|g" \
    "$file"
  # Phase 2: 通用正则兜底（捕获任何残留的 PAT/Token，包括旧版或已更换的）
  sed -i '' \
    -e 's|github_pat_[A-Za-z0-9_]\{20,\}|__SECRET_GITHUB_PAT__|g' \
    -e 's|ghp_[A-Za-z0-9]\{20,\}|__SECRET_GITHUB_PAT__|g' \
    -e 's|sk-user-[a-f0-9]\{20,\}|__SECRET_AI4SCHOLAR_TOKEN__|g' \
    -e 's|tvly-[A-Za-z0-9_-]\{20,\}|__SECRET_TAVILY_API_KEY__|g' \
    "$file"
  echo "  🔒 已脱敏: $(basename "$file")"
}

echo "── 配置文件 ──────────────────────────────────────────"
to_template    "${HOME_PATH}/.gemini/settings.json"               "${REPO_DIR}/antigravity/settings.json"
strip_secrets  "${REPO_DIR}/antigravity/settings.json"
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
sync_skills "${HOME_PATH}/.agents/workflows"          "${REPO_DIR}/shared/agents-workflows"  "Shared .agents/workflows (~/.agents)"
sync_skills "${OBSIDIAN_PATH}/.agents/workflows"      "${REPO_DIR}/shared/agents-workflows"  "Shared .agents/workflows (Obsidian)"
sync_skills "${OBSIDIAN_PATH}/.agents/rules"          "${REPO_DIR}/shared/agents-rules"      "Shared .agents/rules (Obsidian)"

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
