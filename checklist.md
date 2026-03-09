# ✅ AI 工具 Skills & MCP 对齐检查清单

> **用途**：在另一台电脑 `git pull` 并运行 `install.sh` 后，逐项核对是否与主机对齐。
> **更新日期**：2026-03-09
> **主机**：mac-minishu

---

## 一、Antigravity

### 配置文件

- [ ] `~/.gemini/settings.json` 存在
- [ ] `~/.gemini/GEMINI.md` 存在
- [ ] 路径占位符已替换（`OBSIDIAN_PATH` → 本机实际路径）

### MCP 列表（16 项）

| # | MCP 名称 | 类别 | 检查 |
|---|---------|------|------|
| 1 | `brave-search` | 搜索 | [ ] |
| 2 | `exa` | 搜索 | [ ] |
| 3 | `tavily` | 搜索 | [ ] |
| 4 | `web-search-prime` | 搜索 | [ ] |
| 5 | `ai4scholar` | 学术 | [ ] |
| 6 | `arxiv` | 学术 | [ ] |
| 7 | `github` | 开发 | [ ] |
| 8 | `git` | 开发 | [ ] |
| 9 | `playwright` | 浏览器 | [ ] |
| 10 | `fetch` | 网络 | [ ] |
| 11 | `ripgrep` | 工具 | [ ] |
| 12 | `memory` | 工具 | [ ] |
| 13 | `context7` | 工具 | [ ] |
| 14 | `sequential-thinking` | 推理 | [ ] |
| 15 | `time` | 工具 | [ ] |
| 16 | `filesystem` | 文件 | [ ] |

### Skills 列表（13 项）

| # | Skill 名称 | 检查 |
|---|-----------|------|
| 1 | `beamer` | [ ] |
| 2 | `content-research-writer` | [ ] |
| 3 | `csv-data-summarizer` | [ ] |
| 4 | `deep-search` | [ ] |
| 5 | `define` | [ ] |
| 6 | `file-organizer` | [ ] |
| 7 | `fix` | [ ] |
| 8 | `humanizer` | [ ] |
| 9 | `knowledge-corpus-builder` | [ ] |
| 10 | `markdown-to-pdf-skill` | [ ] |
| 11 | `mineru-pdf-sync` | [ ] |
| 12 | `perplexica` | [ ] |
| 13 | `reddit-fetch` | [ ] |

---

## 二、Claude Code

### 配置文件

- [ ] `~/.claude/settings.json` 存在
- [ ] `~/.claude/CLAUDE.md` 存在
- [ ] 模型 = `haiku`
- [ ] `ANTHROPIC_BASE_URL` = `http://127.0.0.1:5000`

### Skills 列表（23 项）

| # | Skill 名称 | 检查 |
|---|-----------|------|
| 1 | `algorithmic-art` | [ ] |
| 2 | `artifacts-builder` | [ ] |
| 3 | `beamer` | [ ] |
| 4 | `brand-guidelines` | [ ] |
| 5 | `browser` | [ ] |
| 6 | `canvas-design` | [ ] |
| 7 | `changelog-generator` | [ ] |
| 8 | `claude-to-im` | [ ] |
| 9 | `codeagent` | [ ] |
| 10 | `competitive-ads-extractor` | [ ] |
| 11 | `connect` | [ ] |
| 12 | `content-research-writer` | [ ] |
| 13 | `csv-data-summarizer` | [ ] |
| 14 | `define` | [ ] |
| 15 | `file-organizer` | [ ] |
| 16 | `fix` | [ ] |
| 17 | `humanizer` | [ ] |
| 18 | `image-enhancer` | [ ] |
| 19 | `invoice-organizer` | [ ] |
| 20 | `markdown-to-pdf-skill` | [ ] |
| 21 | `mineru-pdf-sync` | [ ] |
| 22 | `reddit-fetch` | [ ] |
| 23 | `HOW-TO-USE-THIS-SKILL` | [ ] |

---

## 三、Codex

### 配置文件

- [ ] `~/.codex/config.toml` 存在
- [ ] 主模型 = `gpt-5.4`
- [ ] Provider = `crs`（base_url: `https://codex.funai.vip/openai/v1`）
- [ ] 路径占位符已替换

### MCP 列表（13 项）

| # | MCP 名称 | 类型 | 检查 |
|---|---------|------|------|
| 1 | `notion` | remote | [ ] |
| 2 | `playwright` | stdio | [ ] |
| 3 | `filesystem` | stdio | [ ] |
| 4 | `fetch` | stdio | [ ] |
| 5 | `context7` | stdio | [ ] |
| 6 | `obsidian` | stdio | [ ] |
| 7 | `deepwiki` | remote | [ ] |
| 8 | `github` | stdio | [ ] |
| 9 | `git` | stdio | [ ] |
| 10 | `ripgrep` | stdio | [ ] |
| 11 | `sequential-thinking` | stdio | [ ] |
| 12 | `memory` | stdio | [ ] |
| 13 | `time` | stdio | [ ] |

---

## 四、OpenCode

### 配置文件

- [ ] `~/.config/opencode/opencode.json` 存在
- [ ] 主模型 = `minimax-cn-coding-plan/MiniMax-M2.5`
- [ ] 路径占位符已替换

### MCP 列表（16 项 — 仓库标准）

| # | MCP 名称 | 类型 | 检查 |
|---|---------|------|------|
| 1 | `ai4scholar` | remote | [ ] |
| 2 | `arxiv` | local | [ ] |
| 3 | `context7` | local | [ ] |
| 4 | `exa` | local | [ ] |
| 5 | `filesystem` | local | [ ] |
| 6 | `git` | local | [ ] |
| 7 | `github` | local | [ ] |
| 8 | `memory` | local | [ ] |
| 9 | `playwright` | local | [ ] |
| 10 | `qmd` | local | [ ] |
| 11 | `ripgrep` | local | [ ] |
| 12 | `sequential-thinking` | local | [ ] |
| 13 | `time` | local | [ ] |
| 14 | `web-reader` | remote | [ ] |
| 15 | `web-search-prime` | remote | [ ] |
| 16 | `zai-mcp-server` | local | [ ] |

### 本地特有 MCP（不纳入同步检查）

> 以下项依赖本机特有路径/venv，仓库中不包含，需在目标机器手动配置。

| MCP 名称 | 说明 |
|---------|------|
| `zread` | 智谱 remote MCP（已在仓库模板中） |
| `paper-search` | 依赖本地 venv 路径 |

---

## 五、共享 Skills（`~/.agents/skills/`）

### Skills 列表（27 项）

| # | Skill 名称 | 检查 |
|---|-----------|------|
| 1 | `agent-browser` | [ ] |
| 2 | `agentic-browser` | [ ] |
| 3 | `analytics-tracking` | [ ] |
| 4 | `bibi` | [ ] |
| 5 | `brainstorming` | [ ] |
| 6 | `browser-use` | [ ] |
| 7 | `codex-deep-search` | [ ] |
| 8 | `commit-work` | [ ] |
| 9 | `docx` | [ ] |
| 10 | `find-skills` | [ ] |
| 11 | `frontend-design` | [ ] |
| 12 | `inference-sh` | [ ] |
| 13 | `mckinsey-consultant` | [ ] |
| 14 | `notion` | [ ] |
| 15 | `pdf` | [ ] |
| 16 | `pptx` | [ ] |
| 17 | `python-executor` | [ ] |
| 18 | `remotion-best-practices` | [ ] |
| 19 | `requesting-code-review` | [ ] |
| 20 | `skill-creator` | [ ] |
| 21 | `smithery-ai-cli` | [ ] |
| 22 | `tavily-search` | [ ] |
| 23 | `ticktick` | [ ] |
| 24 | `vue` | [ ] |
| 25 | `web-design-guidelines` | [ ] |
| 26 | `web-search` | [ ] |
| 27 | `xlsx` | [ ] |

---

## 六、快速自动检查命令

在目标机器上运行以下命令快速生成检查结果：

```bash
bash ~/sync-aicli/install.sh
```

安装脚本的 Step 5 会输出逐项验证报告，对照本清单即可确认对齐状态。

---

*生成日期：2026-03-09 | 来源：sync-aicli 仓库实际配置*
