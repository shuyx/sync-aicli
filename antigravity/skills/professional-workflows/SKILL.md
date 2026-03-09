---
name: professional-workflows
description: 三大专业 SOP 工作流：深度预研(deep-research-pipeline)、政府申报书(formal-proposal-workflow)、专利起草(patent-drafting-sop)。当用户提到"调研"、"预研"、"技术路线"、"申报书"、"商业计划书"、"专利"、"权利要求"、"技术交底"等关键词时自动触发对应 workflow。
---

# Professional Workflows Skill

管理三个互相关联的专业级 SOP 工作流。每个 workflow 存放在 `.agents/workflows/` 目录下，通过斜杠命令触发。

## 三大 Workflow 概览

| Workflow | 斜杠命令 | 适用场景 |
|---|---|---|
| 深度预研 | `/deep-research-pipeline` | 新课题预研、前沿技术商业化分析、技术路线对比 |
| 政府申报书 | `/formal-proposal-workflow` | 政府项目申报、商业计划书、正式提案文档 |
| 专利起草 | `/patent-drafting-sop` | 技术交底书 → 专利申请材料（权利要求 + 说明书） |

## 核心架构

三个 workflow **共享全局约束**（`global.md`）：
- 深度思考：Chain of Thought + Trade-offs 对比
- 事实 vs. 推论必须明确区分
- Architecture-First：先宏观架构，后具体逻辑
- 学术克制文风：客观、术语一致

### 互联关系
```
/deep-research-pipeline（调研层）
     ↓ 输出：技术路线对比报告、可行性结论
/formal-proposal-workflow（文书层）
     ↓ 引用调研结论，组装申报书
/patent-drafting-sop（知识产权层）
     ↓ 将技术方案转化为专利文件
```

## Workflow 1：深度预研 `/deep-research-pipeline`

**触发词**：调研、预研、技术路线、可行性分析

**执行流程**：
1. **定义研究边界** — 明确核心问题、排除范围
2. **多源信息采集** — 使用 `deep-search` / `perplexica` skill 进行多源搜索
3. **技术路线拆解** — 至少对比 2-3 种方案，列出 Trade-offs
4. **可行性判定** — 区分事实（已有论据）与推论（逻辑推演），标注知识盲区
5. **输出** — 结构化调研报告（Markdown），写入用户指定目录或 Obsidian

**输出路径**：用户指定 或 默认 `~/Documents/Files/[项目名]/`

## Workflow 2：政府申报书 `/formal-proposal-workflow`

**触发词**：申报书、计划书、提案、项目申报

**执行流程**：
1. **需求解析** — 确认申报类别、字数限制、评审侧重
2. **骨架提取** — 按申报模板自动生成章节结构
3. **内容填充** — 引用调研报告（如已执行 `/deep-research-pipeline`），用 `humanizer` 去 AI 痕迹
4. **格式合规** — 术语一致性检查，生硬的 AI 用语替换
5. **输出** — 可用于 Overleaf 的 LaTeX 或 Markdown，使用 `beamer` skill 转换

**输出路径**：用户指定 或 默认 `~/Documents/Files/[项目名]/`

## Workflow 3：专利起草 `/patent-drafting-sop`

**触发词**：专利、权利要求、技术交底书、说明书

**执行流程**：
1. **技术交底解析** — 从口语化描述中提取核心技术方案
2. **现有技术检索** — 使用搜索 skill 查找相关专利和论文
3. **权利要求起草** — 标准体例：前序部分 + "其特征在于" + 特征部分
4. **说明书撰写** — 技术问题、技术方案、有益效果、实施例
5. **附图需求清单** — 使用 `edit-banana` skill 辅助图表生成
6. **输出** — 专利申请全套文档

**输出路径**：用户指定 或 默认 `~/Documents/Files/[项目名]/`

## 注意事项

- 所有 workflow 标注了 `// turbo-all`，全流程自动化执行
- 执行结束后会自动提示用户是否写入记忆胶囊（`Openclaw/records/`）
- 可通过 `acpx` 将 workflow 内的子任务拆分给多个 agent 并行执行
