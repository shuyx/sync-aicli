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
    ((SKIPPED++)) || true
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
  ((INSTALLED++)) || true
}

# ── 辅助：安装 skills 目录 ────────────────────────────────
install_skills() {
  local src="$1" dst="$2" label="$3"
  if [[ ! -d "$src" ]]; then
    print_step "⚠ " "$label → 仓库中无此目录，跳过"
    ((SKIPPED++)) || true
    return
  fi
  mkdir -p "$dst"
  cp -r "${src}/." "$dst/" 2>/dev/null || true
  find "$dst" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
  local count
  count=$(find "$src" -name "SKILL.md" | wc -l | tr -d ' ')
  print_step "✅" "$label ($count skills)"
  ((INSTALLED++)) || true
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

# ── 辅助：检查 skill 是否存在 ──────────────────────────
check_skill() {
  local dir="$1" name="$2"
  if [[ -f "${dir}/${name}/SKILL.md" ]]; then
    echo "    ✅ $name"
  else
    echo "    ❌ $name (缺失)"
  fi
}

echo "  ▶ Antigravity MCP (${HOME_PATH}/.gemini/settings.json)"
for mcp in brave-search exa tavily web-search-prime ai4scholar arxiv \
           github git playwright fetch ripgrep memory context7 \
           sequential-thinking time filesystem; do
  check_mcp "antigravity" "${HOME_PATH}/.gemini/settings.json" "$mcp"
done

echo ""
echo "  ▶ Antigravity Skills (${HOME_PATH}/.gemini/antigravity/skills/)"
ANTI_SKILLS=(beamer content-research-writer csv-data-summarizer deep-search \
             define file-organizer fix humanizer knowledge-corpus-builder \
             markdown-to-pdf-skill mineru-pdf-sync perplexica reddit-fetch)
ANTI_SKILL_OK=0; ANTI_SKILL_TOTAL=${#ANTI_SKILLS[@]}
for sk in "${ANTI_SKILLS[@]}"; do
  if [[ -f "${HOME_PATH}/.gemini/antigravity/skills/${sk}/SKILL.md" ]]; then
    echo "    ✅ $sk"
    ((ANTI_SKILL_OK++)) || true
  else
    echo "    ❌ $sk (缺失)"
  fi
done
echo "    → ${ANTI_SKILL_OK}/${ANTI_SKILL_TOTAL} Skills"

echo ""
echo "  ▶ Claude Code (.claude/)"
if [[ -f "${HOME_PATH}/.claude/settings.json" ]]; then
  echo "    ✅ settings.json 存在"
else
  echo "    ❌ settings.json 缺失"
fi
[[ -f "${HOME_PATH}/.claude/CLAUDE.md" ]] && echo "    ✅ CLAUDE.md 存在" || echo "    ❌ CLAUDE.md 缺失"

echo ""
echo "  ▶ Claude Code Skills (${HOME_PATH}/.claude/skills/)"
CC_SKILLS=(algorithmic-art artifacts-builder beamer brand-guidelines browser \
           canvas-design changelog-generator claude-to-im codeagent \
           competitive-ads-extractor connect content-research-writer \
           csv-data-summarizer define file-organizer fix humanizer \
           image-enhancer invoice-organizer markdown-to-pdf-skill \
           mineru-pdf-sync reddit-fetch)
CC_SKILL_OK=0; CC_SKILL_TOTAL=${#CC_SKILLS[@]}
for sk in "${CC_SKILLS[@]}"; do
  if [[ -f "${HOME_PATH}/.claude/skills/${sk}/SKILL.md" ]]; then
    echo "    ✅ $sk"
    ((CC_SKILL_OK++)) || true
  else
    echo "    ❌ $sk (缺失)"
  fi
done
echo "    → ${CC_SKILL_OK}/${CC_SKILL_TOTAL} Skills"

echo ""
echo "  ▶ Codex MCP (~/.codex/config.toml)"
if [[ -f "${HOME_PATH}/.codex/config.toml" ]]; then
  MODEL=$(grep '^model ' "${HOME_PATH}/.codex/config.toml" | head -1 | cut -d'"' -f2)
  echo "    ✅ config.toml 存在 | 主模型：$MODEL"
  for mcp in notion playwright filesystem fetch context7 obsidian deepwiki \
             github git ripgrep sequential-thinking memory time; do
    if grep -q "\[mcp_servers\.${mcp}" "${HOME_PATH}/.codex/config.toml" 2>/dev/null; then
      echo "    ✅ $mcp"
    else
      echo "    ❌ $mcp (未找到)"
    fi
  done
else
  echo "    ❌ config.toml 缺失"
fi

echo ""
echo "  ▶ OpenCode MCP (~/.config/opencode/opencode.json)"
if [[ -f "${HOME_PATH}/.config/opencode/opencode.json" ]]; then
  OC_MODEL=$(timeout 3 python3 -c "import json; d=json.load(open('${HOME_PATH}/.config/opencode/opencode.json')); print(d.get('model','?'))" 2>/dev/null || echo "?")
  echo "    ✅ opencode.json 存在 | 主模型：$OC_MODEL"
  for mcp in ai4scholar arxiv context7 exa filesystem git github memory \
             playwright qmd ripgrep sequential-thinking time \
             web-reader web-search-prime zai-mcp-server; do
    if grep -q "\"${mcp}\"" "${HOME_PATH}/.config/opencode/opencode.json" 2>/dev/null; then
      echo "    ✅ $mcp"
    else
      echo "    ❌ $mcp (未找到)"
    fi
  done
else
  echo "    ❌ opencode.json 缺失"
fi

echo ""
echo "  ▶ Shared Skills (~/.agents/skills/)"
SHARED_SKILLS=(agent-browser agentic-browser analytics-tracking bibi brainstorming \
               browser-use codex-deep-search commit-work docx find-skills \
               frontend-design inference-sh mckinsey-consultant notion pdf pptx \
               python-executor remotion-best-practices requesting-code-review \
               skill-creator smithery-ai-cli tavily-search ticktick vue \
               web-design-guidelines web-search xlsx)
SH_SKILL_OK=0; SH_SKILL_TOTAL=${#SHARED_SKILLS[@]}
for sk in "${SHARED_SKILLS[@]}"; do
  if [[ -f "${HOME_PATH}/.agents/skills/${sk}/SKILL.md" ]]; then
    echo "    ✅ $sk"
    ((SH_SKILL_OK++)) || true
  else
    echo "    ❌ $sk (缺失)"
  fi
done
echo "    → ${SH_SKILL_OK}/${SH_SKILL_TOTAL} Shared Skills"

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
