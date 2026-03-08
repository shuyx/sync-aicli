#!/usr/bin/env bash
# backup.sh — 在安装/更新前完整备份当前机器的所有 AI 工具配置
# 用法：bash backup.sh [备份标签]
# 示例：bash backup.sh before-sync

set -euo pipefail

LABEL="${1:-manual}"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"
BACKUP_DIR="${HOME_PATH}/.ai-config-backups/${TIMESTAMP}_${LABEL}"

mkdir -p "$BACKUP_DIR"

echo "📦 备份 AI 工具配置 → $BACKUP_DIR"
echo "   标签：$LABEL | 时间：$TIMESTAMP"

backup_file() {
  local src="$1"
  local name="$2"
  if [[ -f "$src" ]]; then
    cp "$src" "$BACKUP_DIR/${name}"
    echo "   ✅ $name"
  else
    echo "   ⚠️  跳过（不存在）：$src"
  fi
}

backup_dir() {
  local src="$1"
  local name="$2"
  if [[ -d "$src" ]]; then
    cp -r "$src" "$BACKUP_DIR/${name}"
    echo "   ✅ $name/ ($(find "$BACKUP_DIR/${name}" -type f | wc -l | tr -d ' ') files)"
  else
    echo "   ⚠️  跳过（不存在）：$src"
  fi
}

echo ""
echo "── Antigravity ───────────────────────────"
backup_file "${HOME_PATH}/.gemini/settings.json"                "antigravity_settings.json"
backup_dir  "${HOME_PATH}/.gemini/antigravity/skills"           "antigravity_skills"

echo ""
echo "── Claude Code ───────────────────────────"
backup_file "${HOME_PATH}/.claude/settings.json"                "claude_settings.json"
backup_file "${HOME_PATH}/.claude/settings.local.json"          "claude_settings_local.json"
backup_file "${HOME_PATH}/.claude/CLAUDE.md"                    "claude_CLAUDE.md"
backup_dir  "${HOME_PATH}/.claude/skills"                       "claude_skills"

echo ""
echo "── Codex ─────────────────────────────────"
backup_file "${HOME_PATH}/.codex/config.toml"                   "codex_config.toml"

echo ""
echo "── OpenCode ──────────────────────────────"
backup_file "${HOME_PATH}/.config/opencode/opencode.json"       "opencode.json"

echo ""
echo "── Shared .agents ────────────────────────"
backup_dir  "${HOME_PATH}/.agents/skills"                       "agents_skills"

# 写入元信息
cat > "$BACKUP_DIR/BACKUP_INFO.txt" << EOF
备份时间：$TIMESTAMP
标签：$LABEL
用户：$CURRENT_USER
HOME：$HOME_PATH
EOF

echo ""
echo "═══════════════════════════════════════════"
echo "✅ 备份完成！"
echo "   路径：$BACKUP_DIR"
echo "   大小：$(du -sh "$BACKUP_DIR" | cut -f1)"
echo ""
echo "恢复命令："
echo "   bash restore.sh $TIMESTAMP"
echo "═══════════════════════════════════════════"
