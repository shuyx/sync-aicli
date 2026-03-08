# LaTeX Report Templates Index

双栏学术报告/技术报告模板库，适合论文、业务报告、技术文档等场景。

> **与 PPT 模板的区别**：这里的模板输出为 **多页 PDF 报告**，不是幻灯片。

## 使用方式

Overleaf 使用步骤：
1. New Project → **从模板新建**，或 Blank Project（手动上传 class 文件）
2. 编译器：各模板独立注明（pdfLaTeX 或 XeLaTeX）

## 模板列表

| 编号 | 文件 | 文档类 | 编译器 | 风格 | 适合场景 |
|------|------|--------|--------|------|---------|
| R01 | `r01_rho_twocolumn.tex` | rho-class | pdfLaTeX | 双栏，学术期刊风 | 研究报告、实验报告、技术文档 |
| R02 | `r02_ocean_report.tex` | article（自包含）| XeLaTeX | 深蓝/青色，Ocean Gradient，Markdown 适配 | 技术报告、项目文档、调研报告 |

---

## 如何新增模板

1. 在 Overleaf 上找到喜欢的报告模板
2. 将完整 `.tex` 代码发给 AI
3. AI 会保存为 `reports/rXX_[类名]_[风格].tex`
4. 更新此 INDEX.md 表格并同步所有工具
