# sync-aicli — AI 工具配置同步仓库

> 私有仓库，同步 Claude Code / Codex / OpenCode / Antigravity 四工具的 MCP 和 Skills 配置

## 机器映射

| 机器 | 用户名 | Obsidian Vault |
|------|--------|----------------|
| Mac Mini（主机）| `mac-minishu` | `/Users/mac-minishu/Obsidian/kevinob` |
| 其他 Mac | `yuanxin` | `/Users/yuanxin/documents/kevinob` |

## 仓库结构

```
sync-aicli/
├── README.md
├── .gitignore
├── install.sh              # 新机器一键安装脚本（自动检测用户名）
├── push.sh                 # 将本机最新配置推送到仓库
├── antigravity/
│   ├── settings.json       # ~/.gemini/settings.json
│   └── skills/             # ~/.gemini/antigravity/skills/
├── claude-code/
│   ├── settings.json       # ~/.claude/settings.json
│   ├── CLAUDE.md           # ~/.claude/CLAUDE.md
│   └── skills/             # ~/.claude/skills/ (部分)
├── codex/
│   └── config.toml         # ~/.codex/config.toml
├── opencode/
│   └── opencode.json       # ~/.config/opencode/opencode.json
└── shared/
    └── agents-skills/      # ~/.agents/skills/
```

## 新机器安装（一键）

```bash
git clone https://github.com/shuyx/sync-aicli.git ~/sync-aicli
cd ~/sync-aicli
bash install.sh
```

安装脚本会：
1. 自动检测当前用户名
2. 替换配置中的路径占位符（`OBSIDIAN_PATH`）
3. 将配置文件复制/软链到正确位置
4. 给 scripts 加执行权限

## 更新配置（推送最新版）

```bash
cd ~/sync-aicli
bash push.sh
```

## 依赖

- Node.js + npm（`brew install node`）
- Python + uv（`brew install uv`）
- Git
