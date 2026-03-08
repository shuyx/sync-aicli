---
name: define
description: "A concept definition and explanation assistant. Answers conceptual questions like 'What is X?', 'What does X do?', 'Where can X be applied?', 'What's the value of X?'. Generates detailed explanations and automatically saves them to markdown documents organized by concept name."
---

# Define: Concept Explanation Assistant

## Overview

This skill specializes in answering conceptual and explanatory questions. When you ask about what something is, what it does, how it's used, or what value it provides, this skill provides clear, well-structured explanations and automatically documents them.

## Supported Question Types

The skill recognizes and handles these types of questions:

- **What is X?** - Basic definitions and core concepts
- **What does X do?** - Functionality and purpose
- **What's the use of X?** - Practical applications and use cases
- **Where can X be applied?** - Application domains and scenarios
- **What's the value of X?** - Benefits, advantages, and importance
- **How does X compare to Y?** - Comparative analysis
- **Can you explain X?** - Any conceptual clarification

## The Process

### 1. Recognition
The skill detects when your question is concept-oriented by looking for:
- Question markers: "What is", "What does", "What's", "How", "Explain"
- Concept extraction: Text within quotation marks or code formatting
- Intent detection: Explanatory or definitional intent

### 2. Explanation Generation
For each concept, the skill provides:

**In the conversation:**
- Clear definition
- Core characteristics and features
- Practical applications and use cases
- Advantages/disadvantages or comparisons (when relevant)
- Related concepts or resources
- **Total length: 无限制** (根据需要尽可能详细和全面)

**Format guidelines:**
- Use markdown formatting for clarity
- Include tables or lists where helpful
- Provide examples when appropriate
- Add context about related concepts

### 3. Documentation
The skill automatically creates/updates markdown files with:

**File organization:**
```
~/Obsidian/Obsidian Work/概念库/
├── [概念名称].md
├── [另一个概念].md
└── ...
```

**File naming:**
- Extract the concept name from your question (usually text in quotes or code formatting)
- Use the Chinese/English name you used exactly as the filename
- Format: `概念名称.md` or `ConceptName.md`

**File structure:**
```markdown
# [概念名称]

> 定义日期：YYYY-MM-DD
> 来源：通过 Droid define skill 生成

## 摘要

[第一段：约 500 字的摘要，清晰说明本文档的整体内容结构和主要观点]

这段摘要应该能让读者快速理解：
- 概念的基本定义
- 核心特性和关键点
- 主要应用场景
- 与其他概念的关系
- 文档涵盖的全部内容

## 基本定义

[详细的定义，可多段落]

## 核心特性

- 特性 1
- 特性 2
- 特性 3

## 应用场景

- 场景 1
- 场景 2
- 场景 3

## 优缺点对比

[如需要]

## 深入分析

[理论基础、工作原理等]

## 相关概念

- 概念 A
- 概念 B

## 参考资源

[如有相关论文、文档等]
```

### 4. Response Format

After answering, the skill provides:
1. **Confirmation message**: "已保存到 [filepath]"
2. **File details**: Show the path and summary of what was documented
3. **Suggestions**: Offer to explain related concepts or dive deeper

## Key Principles

1. **Clarity First** - Explain like you're teaching someone new to the concept
2. **Reasonable Length** - Comprehensive but not overwhelming (300-600 words)
3. **Practical Focus** - Include real-world applications and examples
4. **Structured Output** - Use markdown formatting consistently
5. **Auto-Documentation** - Always save to disk without asking
6. **Smart Naming** - Use the exact concept name from your question as the filename

## Configuration

### Storage Location
Default storage location for concept definitions:
- **Primary**: `~/Obsidian/Obsidian Work/概念库/`
- **Fallback**: User's current project directory
- **Customizable**: Can be set in Factory settings

### Language Support
- 支持中文概念定义
- Support for English concepts
- 支持混合语言解释 (Mixed language explanations)

## Examples

### Example 1: Simple Concept Question
**Your question:** 什么是"UMI"？

**Skill response:**
- Provides 1-2 paragraph definition
- Lists key characteristics (cost, speed, applications)
- Explains use cases and scenarios
- Compares with similar tools
- Saves to: `~/Obsidian/Obsidian Work/概念库/UMI.md`

### Example 2: Comparative Question
**Your question:** "Domain Randomization" 与 "System Identification" 有什么区别？

**Skill response:**
- Explains both concepts
- Creates comparison table
- Highlights when to use each
- Saves to: `~/Obsidian/Obsidian Work/概念库/Domain_Randomization.md` 和 `System_Identification.md`

### Example 3: Application-Focused Question
**Your question:** 能告诉我"强化学习"可以应用在哪些场景吗？

**Skill response:**
- Lists major application domains
- Provides concrete examples
- Discusses advantages in each context
- Saves to: `~/Obsidian/Obsidian Work/概念库/强化学习.md`

## Best Practices

1. **Clear Question Formulation**
   - Use quotes or code formatting to highlight the concept
   - Ask one concept per question for best results
   - Provide context if the concept is domain-specific

2. **Follow-up Questions**
   - Ask "Tell me more about [related concept]"
   - Use "Compare [concept A] with [concept B]"
   - Ask "What are practical examples of [concept]?"

3. **Knowledge Building**
   - Concepts are saved to your knowledge base automatically
   - Review saved concepts periodically to refine understanding
   - Build a personal glossary of important concepts

## Integration with Other Skills

This skill works well with:
- **brainstorming** - Use define first to understand concepts before designing
- **content-research-writer** - Define concepts before writing detailed content
- **docx** - Export concept definitions to professional documents

## Limitations

- Focuses on **conceptual explanations**, not detailed implementation guides
- Saves to **local markdown files**, not to cloud/databases
- Best for **single concepts**, not complex multi-part systems
- Does **not execute code** or create live demonstrations

## Configuration

### Customize Storage Location

To change the default storage location, set in your Droid config:

```yaml
skills:
  define:
    storage_path: "/Users/mac-minishu/Obsidian/Obsidian Work/概念库"
    language: "auto"  # auto, zh, en
    template: "full"  # full, brief, minimal
```

### Available Templates

- **full** (default) - Complete explanation with all sections
- **brief** - Shorter version (200-300 words)
- **minimal** - Bullet points only

## Output Examples

### Chinese Concept Example Output

```markdown
# 强化学习 (Reinforcement Learning)

> 定义日期：2026-01-17
> 来源：通过 Droid define skill 生成

## 基本定义

强化学习是机器学习的一个分支，通过与环境的交互来学习最优策略。...

## 核心特性

- 通过试错学习
- 基于奖励信号优化
- 自主决策和规划能力

...
```

---

**Version**: 1.0  
**Last Updated**: 2026-01-17  
**Skill Type**: Personal Assistant
