---
name: research-writing-assistant
description: 面向中文科研论文的AI写作助手。默认先讨论再执行，自动创建并维护plan上下文，支持去AI化写作、文献综述、Python图表与Miniconda环境配置，默认以Markdown/纯文本交付并提供Word迁移指引。
---

# 科研写作助手 (Research Writing Assistant)

> 整合自 [articlewriting-skill](https://github.com/Norman-bury/articlewriting-skill) 与 [claude-scientific-writer](https://github.com/K-Dense-AI/claude-scientific-writer)

面向中文学术论文（尤其 EMBA/MBA 学位论文）的全流程写作与润色 Skill。

## 触发条件

用户提到以下关键词时触发：
- "论文写作"、"学术润色"、"去AI化"、"降AI味"
- "文献综述"、"参考文献检查"、"引用格式"
- "论文排版"、"LaTeX 润色"、"投稿准备"

## 核心能力矩阵

| 能力 | 来源 Skill | 说明 |
|------|-----------|------|
| 去AI化写作 | articlewriting-skill | 禁用机械过渡词、强调句式、AI模式化表达 |
| 文献真实性审查 | claude-scientific-writer | 零容忍虚构文献，所有引用必须可验证 |
| 上下文管理(plan/) | articlewriting-skill | 先讨论后执行，progress/notes/stage-gates |
| LaTeX 编译与排版 | claude-scientific-writer | 默认 LaTeX+BibTeX，PDF格式校验 |
| 学科路由 | articlewriting-skill | 文科/社科/医学/法学模块自动分流 |
| 图表生成 | 两者整合 | Python绘图 + 示意图生成 |

## 执行协议

### Step 1: 去AI化语言规范（最高优先级）

**禁用词表**：
- 机械过渡词：首先、其次、最后、此外、另外、总之、综上
- 强调句式：值得注意的是、需要指出的是、重要的是
- AI衔接词：不难发现、显而易见、众所周知
- 过度修辞：极其、毫无疑问、不言而喻

**替代策略**：
- 用实质内容的因果逻辑代替过渡词
- 用数据和引文代替主观判断
- 保持客观第三人称学术叙述

可用 `bash research-writing-skill/scripts/style_check.sh <文件>` 做快速检查。

### Step 2: 文献引用铁律

1. **绝不编造文献** — 每一条 BibTeX 条目必须可在 Google Scholar / 知网验证
2. 英文文献通过 Google Scholar 检索后引用
3. 中文文献优先让用户提供来源再整理
4. 每条引用至少具备：作者、年份、期刊/出版社三项完整信息
5. 引用格式严格使用 `\cite{}` 上标编号，不使用括号内文献

### Step 3: 小标题规范

- 所有二级、三级、四级标题≤12个汉字
- 使用学术精炼语言，禁用比喻、隐喻、文学化表达
- 禁用冒号分割式长标题（如"XXX：YYYYYY的ZZZ"）

### Step 4: 写作质检清单

提交前必须通过：
- [ ] 全文无 AI 模式化表达
- [ ] 所有引用真实可查
- [ ] 引用编号从 [1] 开始按出现顺序排列
- [ ] 所有小标题≤12字
- [ ] 无括号内文献引用（统一上标格式）
- [ ] 无"资料来源：作者整理"等非标准注释
- [ ] LaTeX 编译 0 Error

## 模块索引

详细模块位于两个 skill 子目录中：

| 场景 | 文件路径 |
|------|---------|
| 中文写作核心 | `articlewriting-skill/modules/writing-core.md` |
| 去AI化 Prompts | `articlewriting-skill/modules/prompts-collection.md` |
| 文献综述 | `articlewriting-skill/modules/literature-review.md` |
| LaTeX 排版 | `articlewriting-skill/modules/latex-guide.md` |
| 引用管理 | `claude-scientific-writer/skills/citation-management/SKILL.md` |
| 同行评审 | `articlewriting-skill/modules/peer-review.md` |
| Python 图表 | `articlewriting-skill/modules/figures-python.md` |
