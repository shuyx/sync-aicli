---
name: beamer
description: "Use this skill to convert Markdown documents into professional LaTeX presentations (Beamer .tex) or reports (article .tex). Trigger when the user says: 'convert to Beamer', 'make a Beamer PPT', 'generate .tex slides', 'LaTeX presentation', 'make a report', 'generate report PDF', 'use R02 template', or asks to turn a .md file into a PDF via Overleaf. Supports both PPT templates (T01-T03) and Report templates (R01-R02). Output is a .tex file the user pastes into Overleaf (XeLaTeX compiler) to produce a PDF."
---

# LaTeX Skill (Beamer PPT + Report)

## Workflow Overview

```
User's .md file → AI reads → generates .tex → User pastes into Overleaf → PDF
```

**No local LaTeX installation required.** Overleaf (free tier) compiles with XeLaTeX.
Overleaf free tier has no compilation limit, only 1 collaborator.

---

## Step 1: Read the Source Markdown

Read the target `.md` file in full before generating anything. Identify:
- Document sections (H1/H2 headings → frames or sections)
- Tables → `tabularx` or `booktabs` tables
- Code blocks → `verbatim` or `lstlisting`
- Lists → `itemize` / `enumerate`
- Emphasis / bold → LaTeX equivalents

**Frame planning rule**: Aim for 5–8 bullet points or 1 table per frame. If a section is long, split into multiple frames. Never let content overflow a frame silently.

---

## Step 2: Generate the .tex File

### Required File Header

Every generated `.tex` MUST start with this magic comment so Overleaf auto-selects XeLaTeX:

```latex
%!TEX program = xelatex
```

> ⚠️ If Overleaf still uses pdfLaTeX, tell the user: Menu → Settings → Compiler → XeLaTeX

### Standard Template Structure

```latex
%!TEX program = xelatex
\documentclass[aspectratio=169, 10pt]{beamer}
\usetheme{metropolis}

% Chinese support
\usepackage[UTF8]{ctex}
\usepackage{fontspec}

% Tables
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{array}

% Colors
\usepackage{xcolor}

% Mono font only (let ctex handle CJK fonts automatically)
\setmonofont{Courier New}

% Color palette (Ocean Gradient - default)
\definecolor{navyBlue}{HTML}{1E2761}
\definecolor{deepBlue}{HTML}{065A82}
\definecolor{tealAccent}{HTML}{14B8A6}
\definecolor{offWhite}{HTML}{F0F4F8}
\definecolor{mutedText}{HTML}{64748B}

% Metropolis color overrides
\setbeamercolor{frametitle}{bg=navyBlue, fg=white}
\setbeamercolor{progress bar}{fg=tealAccent, bg=navyBlue!30}
\setbeamercolor{title separator}{fg=tealAccent}
\setbeamercolor{block title}{bg=navyBlue, fg=white}
\setbeamercolor{block body}{bg=offWhite}

\metroset{progressbar=frametitle, sectionpage=progressbar, block=fill}

\title{[TITLE]}
\subtitle{[SUBTITLE]}
\author{[AUTHOR]}
\date{[DATE]}

\begin{document}

% Cover slide (dark background)
{
  \setbeamercolor{background canvas}{bg=navyBlue}
  \begin{frame}
    \titlepage
  \end{frame}
}

% TOC
\begin{frame}{目录}
  \tableofcontents[hideallsubsections]
\end{frame}

\section{...}
\begin{frame}{...}
  ...
\end{frame}

% Closing slide
{
  \setbeamercolor{background canvas}{bg=navyBlue}
  \begin{frame}[standout]
    \textcolor{tealAccent}{\Large 谢谢}
  \end{frame}
}

\end{document}
```

### Layout Patterns

**Three columns (goals, features, comparisons):**
```latex
\begin{columns}[T]
  \begin{column}{0.31\textwidth}
    \begin{block}{标题}内容\end{block}
  \end{column}
  \begin{column}{0.31\textwidth}
    \begin{alertblock}{标题}内容\end{alertblock}
  \end{column}
  \begin{column}{0.31\textwidth}
    \begin{exampleblock}{标题}内容\end{exampleblock}
  \end{column}
\end{columns}
```

**Table (data/specs):**
```latex
\begin{tabularx}{\textwidth}{lX}
  \toprule
  \textbf{列A} & \textbf{列B} \\
  \midrule
  内容 & 内容 \\
  \bottomrule
\end{tabularx}
```

**Two columns (image + text or text + table):**
```latex
\begin{columns}[c]
  \begin{column}{0.45\textwidth}
    左侧内容
  \end{column}
  \begin{column}{0.50\textwidth}
    右侧内容
  \end{column}
\end{columns}
```

**Stacked blocks (architecture layers, process steps):**
```latex
\begin{block}{层级 A}\small 内容\end{block}
\vspace{0.3em}
\begin{alertblock}{层级 B}\small 内容\end{alertblock}
\vspace{0.3em}
\begin{exampleblock}{层级 C}\small 内容\end{exampleblock}
```

---

## Step 3: Save the .tex File

Save the generated `.tex` file to the **same directory as the source `.md` file**, with the naming convention:

```
[source_name]_beamer.tex
```

Example: `01｜活动计划书.md` → `活动计划书_beamer.tex`

---

## Step 4: Tell the User

After saving, always remind the user:

> **Overleaf 粘贴步骤**：
> 1. [overleaf.com](https://overleaf.com) → New Project → Blank Project
> 2. 将 `.tex` 内容粘贴覆盖 `main.tex`
> 3. Menu → Settings → Compiler → **XeLaTeX**
> 4. Recompile

---

## Color Palette Options

| 名称 | Primary | Accent | 适合场景 |
|------|---------|--------|---------|
| **Ocean Gradient**（默认）| `1E2761` | `14B8A6` | 科技/商务 |
| **Midnight Executive** | `1E2761` | `CADCFC` | 高管汇报 |
| **Charcoal Minimal** | `36454F` | `F2F2F2` | 学术报告 |
| **Cherry Bold** | `990011` | `FCF6F5` | 品牌发布 |

---

## Common Pitfalls

- **中文乱码**：必须用 XeLaTeX，`pdfLaTeX` 无法处理中文
- **内容溢出**：Beamer 不自动换页，内容太多要手动拆 frame
- **特殊字符**：`&` → `\&`，`%` → `\%`，`_` → `\_`，`#` → `\#`
- **Emoji**：Overleaf XeLaTeX 支持部分 Emoji，复杂 Emoji 改用文字描述
