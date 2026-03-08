#!/usr/bin/env bash
# install.sh — 一键安装 + 能力同步报告
# 用法：bash install.sh
# 在新机器克隆仓库后直接运行，自动完成：
#   1. 备份当前配置
#   2. 安装四个 AI 工具配置（含路径替换）
#   3. 安装所有 Skills
#   4. 输出能力同步验证报告

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER=$(whoami)
HOME_PATH="/Users/${CURRENT_USER}"

# ── 机器→Obsidian 路径映射 ────────────────────────────────
if [[ "$CURRENT_USER" == "mac-minishu" ]]; then
  OBSIDIAN_PATH="/Users/mac-minishu/Obsidian/kevinob"
elif [[ "$CURRENT_USER" == "yuanxin" ]]; then
  OBSIDIAN_PATH="/Users/yuanxin/documents/kevinob"
else
  echo "⚠️  未识别用户名: $CURRENT_USER，请手动输入 Obsidian Vault 路径："
  read -r OBSIDIAN_PATH
fi


# ── 内部计数器 ────────────────────────────────────────────
INSTALLED=0
SKIPPED=0
FAILED=0

print_header() {
  echo ""
  echo "╔═══════════════════════════════════════════╗"
  echo "║  $1"
  echo "╚═══════════════════════════════════════════╝"
}

print_step() { echo "  [$1] $2"; }

# ── 辅助：替换路径占位符 ──────────────────────────────────
replace_placeholders() {
  local src="$1" dst="$2"
  sed \
    -e "s|OBSIDIAN_PATH|${OBSIDIAN_PATH}|g" \
    -e "s|HOME_PATH|${HOME_PATH}|g" \
    "$src" > "$dst"
}

# ── 辅助：安装单个配置文件 ───────────────────────────────
install_config() {
  local repo_file="$1" target="$2" label="$3" needs_replace="${4:-false}"
  local dir
  dir="$(dirname "$target")"
  mkdir -p "$dir"

  if [[ ! -f "$repo_file" ]]; then
    print_step "⚠ " "$label → 仓库中无此文件，跳过"
    ((SKIPPED++))
    return
  fi

  # 备份已有文件
  if [[ -f "$target" ]]; then
    cp "$target" "${target}.bak.$(date +%Y%m%d_%H%M%S)"
  fi

  if [[ "$needs_replace" == "true" ]]; then
    replace_placeholders "$repo_file" "$target"
  else
    cp "$repo_file" "$target"
  fi
  print_step "✅" "$label"
  ((INSTALLED++))
}

# ── 辅助：安装 skills 目录 ────────────────────────────────
install_skills() {
  local src="$1" dst="$2" label="$3"
  if [[ ! -d "$src" ]]; then
    print_step "⚠ " "$label → 仓库中无此目录，跳过"
    ((SKIPPED++))
    return
  fi
  mkdir -p "$dst"
  cp -r "${src}/." "$dst/"
  find "$dst" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
  local count
  count=$(find "$src" -name "SKILL.md" | wc -l | tr -d ' ')
  print_step "✅" "$label ($count skills)"
  ((INSTALLED++))
}

# ═══════════════════════════════════════════════════════════
print_header "📦 Step 1/5 — 信息确认"
echo "  用户名：$CURRENT_USER"
echo "  HOME：$HOME_PATH"
echo "  Obsidian：$OBSIDIAN_PATH"
echo "  仓库：$REPO_DIR"

# ═══════════════════════════════════════════════════════════
print_header "💾 Step 2/5 — 备份当前配置"
bash "${REPO_DIR}/backup.sh" "before-install" 2>&1 | grep -E "✅|⚠️|路径|大小" || true

# ═══════════════════════════════════════════════════════════
print_header "🔧 Step 3/5 — 安装配置文件"

echo ""
echo "  ── Antigravity ───────────────────────────"
install_config \
  "${REPO_DIR}/antigravity/settings.json" \
  "${HOME_PATH}/.gemini/settings.json" \
  "Antigravity settings.json" "true"

echo ""
echo "  ── Claude Code ───────────────────────────"
install_config \
  "${REPO_DIR}/claude-code/settings.json" \
  "${HOME_PATH}/.claude/settings.json" \
  "Claude Code settings.json"
install_config \
  "${REPO_DIR}/claude-code/CLAUDE.md" \
  "${HOME_PATH}/.claude/CLAUDE.md" \
  "Claude Code CLAUDE.md"

echo ""
echo "  ── Codex ─────────────────────────────────"
install_config \
  "${REPO_DIR}/codex/config.toml" \
  "${HOME_PATH}/.codex/config.toml" \
  "Codex config.toml" "true"

echo ""
echo "  ── OpenCode ──────────────────────────────"
install_config \
  "${REPO_DIR}/opencode/opencode.json" \
  "${HOME_PATH}/.config/opencode/opencode.json" \
  "OpenCode opencode.json" "true"

# ═══════════════════════════════════════════════════════════
print_header "🧩 Step 4/5 — 安装 Skills"

echo ""
install_skills \
  "${REPO_DIR}/antigravity/skills" \
  "${HOME_PATH}/.gemini/antigravity/skills" \
  "Antigravity skills"

install_skills \
  "${REPO_DIR}/claude-code/skills" \
  "${HOME_PATH}/.claude/skills" \
  "Claude Code skills"

install_skills \
  "${REPO_DIR}/shared/agents-skills" \
  "${HOME_PATH}/.agents/skills" \
  "Shared .agents/skills"

# ═══════════════════════════════════════════════════════════
print_header "📊 Step 5/5 — 能力同步验证报告"

echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │          >> 能力同步状态验证 <<              │"
printf "  │  机器：%-38s│\n" "$CURRENT_USER"
printf "  │  时间：%-38s│\n" "$(date '+%Y-%m-%d %H:%M')"
echo "  └─────────────────────────────────────────────┘"
echo ""

check_mcp() {
  local tool="$1" config="$2" mcp_name="$3"
  if grep -q "\"${mcp_name}\"" "$config" 2>/dev/null || grep -q "${mcp_name}" "$config" 2>/dev/null; then
    echo "    ✅ $mcp_name"
  else
    echo "    ❌ $mcp_name (未找到)"
  fi
}

echo "  ▶ Antigravity MCP (${HOME_PATH}/.gemini/settings.json)"
for mcp in brave-search exa tavily web-search-prime ai4scholar arxiv \
           github git playwright fetch ripgrep memory context7 sequential-thinking; do
  check_mcp "antigravity" "${HOME_PATH}/.gemini/settings.json" "$mcp"
done

echo ""
echo "  ▶ Antigravity Skills (${HOME_PATH}/.gemini/antigravity/skills/)"
ANTI_SKILL_COUNT=0
if [[ -d "${HOME_PATH}/.gemini/antigravity/skills" ]]; then
  for skill_dir in "${HOME_PATH}/.gemini/antigravity/skills"/*/; do
    [[ -f "${skill_dir}SKILL.md" ]] && {
      sname=$(basename "$skill_dir")
      echo "    ✅ $sname"
      ((ANTI_SKILL_COUNT++))
    }
  done
  echo "    → 共 $ANTI_SKILL_COUNT 个 Skills"
fi

echo ""
echo "  ▶ Claude Code MCP (.claude/settings.json)"
if [[ -f "${HOME_PATH}/.claude/settings.json" ]]; then
  echo "    ✅ settings.json 存在"
  [[ -f "${HOME_PATH}/.claude/CLAUDE.md" ]] && echo "    ✅ CLAUDE.md 存在"
fi
CC_SKILL_COUNT=$(find "${HOME_PATH}/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
echo "    ✅ Claude Code Skills: $CC_SKILL_COUNT 个"

echo ""
echo "  ▶ Codex (~/.codex/config.toml)"
if [[ -f "${HOME_PATH}/.codex/config.toml" ]]; then
  echo "    ✅ config.toml 存在"
  MODEL=$(grep '^model ' "${HOME_PATH}/.codex/config.toml" | head -1 | cut -d'"' -f2)
  echo "    ✅ 主模型：$MODEL"
  MCP_COUNT=$(grep -c '^\[mcp_servers\.' "${HOME_PATH}/.codex/config.toml" 2>/dev/null || echo 0)
  echo "    ✅ MCP 数量：$MCP_COUNT 个"
fi

echo ""
echo "  ▶ OpenCode (~/.config/opencode/opencode.json)"
if [[ -f "${HOME_PATH}/.config/opencode/opencode.json" ]]; then
  echo "    ✅ opencode.json 存在"
  OC_MODEL=$(python3 -c "import json; d=json.load(open('${HOME_PATH}/.config/opencode/opencode.json')); print(d.get('model','?'))" 2>/dev/null || echo "?")
  echo "    ✅ 主模型：$OC_MODEL"
  OC_MCP=$(python3 -c "import json; d=json.load(open('${HOME_PATH}/.config/opencode/opencode.json')); print(len(d.get('mcp',{})))" 2>/dev/null || echo "?")
  echo "    ✅ MCP 数量：$OC_MCP 个"
fi

echo ""
echo "  ┌─────────────────────────────────────────────┐"
printf "  │  安装：%-3s项  跳过：%-3s项  失败：%-3s项      │\n" "$INSTALLED" "$SKIPPED" "$FAILED"
if [[ $FAILED -eq 0 ]]; then
  echo "  │  状态：🟢 同步成功，能力已对齐！             │"
else
  echo "  │  状态：🔴 有 $FAILED 项失败，请检查上方输出     │"
fi
echo "  └─────────────────────────────────────────────┘"

echo ""
echo "⚡ 下一步："
echo "   • 重启 VS Code（生效 Antigravity）"
echo "   • 重启 Claude Code / Codex / OpenCode"
echo ""
echo "🔁 日后同步（在主机运行）："
echo "   bash ~/sync-aicli/push.sh"
echo ""
echo "↩️  如需恢复："
echo "   bash ~/sync-aicli/restore.sh"
