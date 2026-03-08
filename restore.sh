#!/usr/bin/env bash
# restore.sh — 从备份恢复 AI 工具配置
# 用法：
#   ./restore.sh                  # 列出所有可用备份
#   ./restore.sh 20260309_060000  # 恢复指定时间戳的备份

set -euo pipefail

CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"
BACKUP_ROOT="${HOME_PATH}/.ai-config-backups"

# ── 列出可用备份 ──────────────────────────────────────────
list_backups() {
  echo "📦 可用备份列表："
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [[ ! -d "$BACKUP_ROOT" ]] || [[ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]]; then
    echo "   （暂无备份，先运行 ./backup.sh）"
    return
  fi
  local i=1
  for bdir in "$BACKUP_ROOT"/*/; do
    local name
    name="$(basename "$bdir")"
    local info=""
    [[ -f "$bdir/BACKUP_INFO.txt" ]] && info=$(grep "标签" "$bdir/BACKUP_INFO.txt" | head -1)
    local size
    size=$(du -sh "$bdir" 2>/dev/null | cut -f1)
    echo "   [$i] $name  ($size)  $info"
    ((i++))
  done
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "用法：./restore.sh <时间戳前缀>"
  echo "示例：./restore.sh 20260309_060000"
}

if [[ $# -eq 0 ]]; then
  list_backups
  exit 0
fi

TIMESTAMP_PREFIX="$1"

# 找到匹配的备份目录
BACKUP_DIR=""
for bdir in "$BACKUP_ROOT"/${TIMESTAMP_PREFIX}*/; do
  if [[ -d "$bdir" ]]; then
    BACKUP_DIR="$bdir"
    break
  fi
done

if [[ -z "$BACKUP_DIR" ]]; then
  echo "❌ 未找到时间戳前缀为 '$TIMESTAMP_PREFIX' 的备份"
  echo ""
  list_backups
  exit 1
fi

echo "═══════════════════════════════════════════"
echo "🔄 恢复配置"
echo "   备份：$BACKUP_DIR"
echo ""
echo "⚠️  确认恢复？当前配置将被覆盖（会先自动备份）[y/N]"
read -r CONFIRM
[[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]] && { echo "已取消"; exit 0; }

# 先备份当前配置（防万一）
echo ""
echo "📦 先备份当前配置..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/backup.sh" "before-restore"

echo ""
echo "── 开始恢复 ──────────────────────────────"

restore_file() {
  local src="$1" dst="$2" label="$3"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "   ✅ $label"
  else
    echo "   ⚠️  备份中无此文件：$label"
  fi
}

restore_dir() {
  local src="$1" dst="$2" label="$3"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -r "${src}/." "$dst/"
    find "$dst" -name "*.sh" -exec chmod +x {} \;
    echo "   ✅ $label"
  else
    echo "   ⚠️  备份中无此目录：$label"
  fi
}

restore_file "${BACKUP_DIR}/antigravity_settings.json"  "${HOME_PATH}/.gemini/settings.json"                "Antigravity settings.json"
restore_dir  "${BACKUP_DIR}/antigravity_skills"         "${HOME_PATH}/.gemini/antigravity/skills"           "Antigravity skills/"
restore_file "${BACKUP_DIR}/claude_settings.json"       "${HOME_PATH}/.claude/settings.json"                "Claude Code settings.json"
restore_file "${BACKUP_DIR}/claude_settings_local.json" "${HOME_PATH}/.claude/settings.local.json"          "Claude Code settings.local.json"
restore_file "${BACKUP_DIR}/claude_CLAUDE.md"           "${HOME_PATH}/.claude/CLAUDE.md"                    "Claude Code CLAUDE.md"
restore_dir  "${BACKUP_DIR}/claude_skills"              "${HOME_PATH}/.claude/skills"                       "Claude Code skills/"
restore_file "${BACKUP_DIR}/codex_config.toml"          "${HOME_PATH}/.codex/config.toml"                   "Codex config.toml"
restore_file "${BACKUP_DIR}/opencode.json"              "${HOME_PATH}/.config/opencode/opencode.json"        "OpenCode opencode.json"
restore_dir  "${BACKUP_DIR}/agents_skills"              "${HOME_PATH}/.agents/skills"                       ".agents/skills/"

echo ""
echo "═══════════════════════════════════════════"
echo "✅ 恢复完成！请重启相关工具生效。"
echo "═══════════════════════════════════════════"
