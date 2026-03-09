# acpx Prompt 实战样板集

> 来源：矿山自动化项目（2026-03-10），Antigravity 为 Claude Code / OpenCode 自动生成

## 样板说明

这些 Prompt 是 Antigravity 在多 Agent 编排场景中**自动生成**的。归档目的是让后续任务拆解时有"样板间"参考。

### 样板结构对照

所有有效 Prompt 都遵循同一结构：

```
1. 头部元信息（派发方式 + 工作目录）
2. 背景段（一段话交代上下文）
3. 关键约束（❌✅⚠️ 强调）
4. 任务 N：输出路径 + 内容结构 + 参考素材
5. 完成后：cc-connect 回调命令
```

---

## 样板 1：重量级 Claude 任务（多任务 + 参考素材）

> 原文件：`_prompt_claude.md` | 派发给 Claude Code | 含 2 个子任务

```markdown
# Claude 任务 Prompt

> 派发方式：`acpx claude -s mining-doc -f "_prompt_claude.md"`
> 工作目录：`/Users/xxx/project`

---

你需要完成矿山自动化项目的两份对外输出文档。请严格按照以下要求执行。

## 背景
[一段话说明项目背景、已有文档情况、当前要输出什么]

## 关键约束（必须严格遵守）
1. ❌ **绝对不提** [敏感内容A]
2. ❌ [某机构] 只作为背景提及，**不独立展开**
3. ✅ [核心产品] 可作为重点突出
4. ⚠️ 场景**不锁定**为某个具体方向，要保持灵活
5. 语气：客观、克制、专业

---

## 任务一：重写 [文件名]
**输出路径**：`path/to/output.md`（覆盖已有文件）

**内容结构**：
1. **第一节** — 简述
2. **第二节** — 简述
3. **第三节** — 简述
...

**参考素材**（请先阅读）：
- `path/to/reference1.md`（当前版本）
- `path/to/reference2.md`（产品细节素材）

---

## 任务二：新建 [文件名]
**输出路径**：`path/to/new_output.md`

**内容结构**：
1. **维度A** — 简述
2. **维度B** — 简述
...

**参考素材**（请先阅读）：
- `path/to/reference3.md`
- `path/to/reference4.md`

---

## 完成后（必须执行）
两篇文档都写完后，执行以下命令向 Telegram 群组汇报：
\```bash
cc-connect send --project gemini-openclaw --stdin <<'CCEOF'
📝 Claude 任务完成汇报
✅ 文件A — 已完成（简述变更）
✅ 文件B — 已完成（简述变更）
📂 输出位置：path/to/output/
CCEOF
\```
```

---

## 样板 2：轻量级 OpenCode 任务（单文件）

> 原文件：`_prompt_opencode_onepage.md` | 派发给 OpenCode | 单个任务

```markdown
# OpenCode 任务 Prompt

> 派发方式：`acpx opencode -s task-name -f "_prompt_opencode.md"`
> 工作目录：`/Users/xxx/project`

---

## 背景
[一两句话交代上下文]

## 关键约束
1. ❌ [禁止事项]
2. ✅ [必须事项]

## 任务：新建 [文件名]
**输出路径**：`path/to/output.md`

**内容结构**：
[一段话或表格描述]

**参考素材**：
- `path/to/reference.md`

## 完成后（必须执行）
\```bash
cc-connect send --project gemini-openclaw -m '✅ OpenCode 完成：[文件名]'
\```
```

---

## 使用指南

### Antigravity 写 Prompt 时参考此样板的要点

1. **长 Prompt 必写文件**：超过 3 行的 Prompt 必须写成 `.md` 文件用 `-f` 加载
2. **参考素材必须列路径**：让子 Agent "先读再写"，避免凭空编造
3. **约束条件放最前面**：用 ❌/✅/⚠️ 符号强调，子 Agent 注意力有限
4. **输出路径必须明确**：写清是新建还是覆盖
5. **一个 Prompt 可含多个子任务**：但同一 Agent 的任务放一个文件
6. **回调统一 `gemini-openclaw`**：不用各自 project

### 任务体量 → Agent 分配建议

| 任务类型 | 推荐 Agent | Prompt 复杂度 |
|---------|-----------|-------------|
| 多文件写作 / 复杂逻辑 | Claude Code | 样板 1（多任务 + 参考素材） |
| 单文件生成 / 模板填充 | OpenCode | 样板 2（单任务极简） |
| 调研搜索 / 信息收集 | Gemini | 样板 2 + 不加 --approve-all |
| 代码生成 / 测试修复 | Codex | 样板 1 或 2 视复杂度定 |
