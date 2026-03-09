---
description: 深度预研与技术路线规划流 (The Deep Research Pipeline)
---

# /deep-research-pipeline

这个 Workflow 用于开展客观、深度的新课题预研（如前沿底层技术商业化）。
本流程自动继承 `global.md` 全部约束（Trade-offs、Architecture-First、区分事实与推论），以下为增强规则。

> **前置条件**：无（本流程为调研起点）
> **后续衔接**：产出物可直接作为 `/patent-drafting-sop` 或 `/formal-proposal-workflow` 的输入

// turbo-all

## Step 1: 概念爆破与宏观架构定义 (Concept & Architecture Framing)
- **输入**：用户提供课题名称/关键词、参考链接、技术交底材料路径，或一段口语化的问题描述。
- **指令**：定义该技术的核心要素与边界。
- **强制约束 (Architecture-First)**：必须首先输出该体系的系统宏观架构，明确各模块的输入/输出接口、上下游技术栈依赖。找出必须遵守的物理法则或工程极限界限。

## Step 2: 多源深度检索与交叉验证 (State-of-the-Art Analysis)
- **指令**：根据检索目标自动选择工具——
  - **工程实践、市场信息、产品方案**：调用 `deep-search` 获取最新工程界方案（Brave+Exa+Tavily）。
  - **学术论文、期刊、专利引用、理论天花板**：自动切换到 `perplexica` academic 模式。
  - 如果两类信息都需要，应**同时调用两个工具**进行交叉验证。
- **强制约束**：分维度（硬件成本、算法成熟度、工程化难度、连续作业可靠性）对比现有市场的头部方案。**必须列出不同方案的优劣势 (Trade-offs)**。如果某个参数查不到真实数据，必须明确标注 `[知识盲区]`，严禁大模型编造。

## Step 3: 差距分析与破局点推演 (Gap & Opportunity)
- **指令**：综合上述客观事实，推演出当前行业普遍存在的"工程痛点"，并提出可行的技术路线图。
- **强制约束**：输出结果必须严格区分【事实依据区】和【AI推演区】。如果推演涉及复杂的多模块并行开发，建议最后输出 `acpx` 多 Agent 并行调度命令草案（例如 Codex 写评估脚本，Claude 写市场壁垒）。

## Step 4: 产物归档与记忆沉淀 (Archiving)
- **指令**：将完整调研报告存档。
- **强制动作**：
  1. 报告存档到 `Openclaw/records/` 或项目指定目录，文件名格式：`YYYY-MM-DD-[课题关键词]-预研报告.md`。
  2. 主动询问用户是否需要将关键路径和决策压缩沉淀到 `Openclaw/records/` 下的记忆胶囊中。
