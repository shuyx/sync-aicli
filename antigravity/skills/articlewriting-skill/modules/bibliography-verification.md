# 参考文献真实性核验模块

本模块提供一套系统化的参考文献真实性核验方法论，适用于 LaTeX 学位论文和期刊投稿项目。核心目标：确保每一条参考文献真实存在、元数据准确、正文引用与文献内容一致。

---

## 一、三类分诊核验框架

对每条参考文献按以下三类分诊，分类处理：

| 分类 | 判定标准 | 处理动作 |
|------|----------|----------|
| ✅ 真实且内容准确 | 文献可查、元数据正确、正文引用与文献论点一致 | 保留，必要时统一格式 |
| ⚠️ 真实但细节错 | 文献存在，但 title / author / year / journal / volume / pages / DOI 有误 | 修正 `.bib` 中的错误字段 |
| ❌ 不存在或高风险伪造 | 无法在任何结构化来源确认其存在 | 替换为用户认可的真实文献，或直接删去正文依赖 |

**执行纪律**：所有 Agent 写入的文献必须经过至少一个结构化来源确认。"搜索引擎摘要片段""二手博客""百度文库搬运"均不算确认。

---

## 二、PDF 序号 ↔ BibTeX Key 映射

在 LaTeX 论文项目中，用户经常按编译后 PDF 里的参考文献序号（如 `[6]`、`[12]`）定位问题。以下脚本可从 `Thesis.aux` 中提取映射：

```bash
python3 - <<'PY'
import re, pathlib
aux = pathlib.Path('Thesis.aux').read_text(encoding='utf-8', errors='ignore').splitlines()
for line in aux:
    m = re.match(r'\\bibcite\{([^}]+)\}\{\{([^}]+)\}', line)
    if m:
        print(f"{m.group(2)}\t{m.group(1)}")
PY
```

**使用原则**：
- 不要先按 `.bib` 的书写顺序判断序号，以编译结果为准。
- 对外沟通时按 PDF 序号汇报，不使用 `ref10`、`ref14` 等内部 BibTeX key。
- 仅在内部调试或修改 `.bib` 时使用 BibTeX key。

---

## 三、多源核验工具链

### 3.1 核验来源优先级

| 优先级 | 来源 | 适用范围 | 说明 |
|--------|------|----------|------|
| 1 | Crossref / DOI | 英文文献 | 最权威的元数据来源，可确认 title / author / year / volume / pages |
| 2 | AI4Scholar | 中英文文献 | 语义搜索引擎，基于论文标题匹配 |
| 3 | IDEAS / RePEc | finance / economics 方向 | 二次交叉验证 |
| 4 | PubMed / IEEE Xplore | 医学 / 工程方向 | 领域专属数据库 |
| 5 | 期刊往期目录页 | 中文期刊 | AI4Scholar 不收录时的降级手段 |
| 6 | 知网 / 万方 | 中文学位论文 | 用户自行搜索或 Playwright 辅助抓取 |
| 7 | Playwright 页面快照 | 所有 | 最后手段：打开网页确认目录、标题、作者 |

### 3.2 核验命令参考

```bash
# AI4Scholar 搜索（如果本地部署了该脚本）
bash ~/.agents/skills/ai4scholar/scripts/paper-search.sh "论文标题" 5

# Crossref API 查询（按标题）
curl -s "https://api.crossref.org/works?query.title=TITLE&rows=3" | python3 -m json.tool

# 按 DOI 查询
curl -s "https://api.crossref.org/works/DOI" | python3 -m json.tool
```

---

## 四、网页核验最低证据标准

对每条需验证的文献，至少满足以下条件之一，方可标记为"已确认"：

1. **DOI 可解析**：通过 `https://doi.org/DOI` 可跳转到出版社原文页面。
2. **结构化数据库命中**：在 Crossref / PubMed / IEEE Xplore / 知网 / 万方中可检索到完整元数据。
3. **期刊官网往期目录**：在期刊官方网站的往期目录中可找到对应卷期页码。

**不算确认的证据**：
- 百度搜索摘要片段（可能抓取自伪造页面）
- 二手博客、百度文库、道客巴巴等搬运站
- 仅在 Google Scholar 引用列表中出现但无法打开原文
- AI 搜索引擎的"综合回答"（无原始来源链接）

---

## 五、正文联动修改原则

替换或修正 `.bib` 中的参考文献后，**必须同步处理正文**：

1. **论证方向一致性检查**：替换后的文献与原句论证方向是否仍然一致？不一致则必须改写相关句子。
2. **作者名和年份同步**：正文中引用的"张三（2020）"如果文献已替换为"李四（2022）"，必须同步修改。
3. **孤儿引用清理**：使用 `rg` 搜索被删除文献的 BibTeX key 是否仍在正文中残留。
4. **不可替代则删除**：如果找不到等价替代文献，不能硬塞一个无关文献，应删除该引用并重写段落。

```bash
# 检查旧 key 是否残留
rg -n "old_key1|old_key2" Chapter*.tex

# 检查旧作者名/年份是否残留
rg -n "旧作者 \\(旧年份\\)" Chapter*.tex
```

---

## 六、编译后全链路验证

每次修改 `.bib` 或正文引用后，按以下顺序验证：

```bash
# 1. 重新编译
latexmk -xelatex Thesis.tex

# 2. 检查编译日志中的引用警告
rg -n "Citation|Undefined|Error|There were" Thesis.log

# 3. 检查 .bbl 输出格式是否符合预期
sed -n '1,100p' Thesis.bbl
```

**验证通过标准**：
- PDF 可正常生成，无中断
- 无 `Undefined citation` 或 `Citation ... undefined` 警告
- `.bbl` 中关键条目的格式与目标样式（如 GB/T 7714）一致
- 对外汇报时按 PDF 序号输出

---

## 七、用户沟通口径规范

向用户汇报参考文献问题时，按三类问题使用标准表述：

| 问题类型 | 标准表述 |
|----------|----------|
| 格式问题 | 「文献 `[N]` 真实存在，格式需调整：[具体字段]」 |
| 引用不匹配 | 「文献 `[N]` 真实存在，但正文引用内容不准确：[具体偏差]」 |
| 不存在 | 「文献 `[N]` 无法确认存在，已替换为 [新文献] / 已删除正文依赖」 |

**执行规则**：
- 一律按编译后 PDF 的参考文献序号汇报。
- 不主动暴露 BibTeX key（如 `ref10`），除非用户明确追问。
- 汇报时先列出问题总数和分类数量，再逐条展开。

---

## 八、GB/T 7714-2015 样式管理速查

### 8.1 标准切换

```latex
% Thesis.tex 中
\usepackage{gbt7714}
\bibliographystyle{gbt7714-numerical}  % 数字制
% 或
\bibliographystyle{gbt7714-author-year}  % 著者-出版年制
```

### 8.2 本地 .bst 定制模式

当官方样式的默认行为与用户需求冲突时（如"保留 DOI 但学位论文不显示 `/OL`"），可复制官方 `.bst` 为本地副本并微调：

```bash
# 复制官方样式
cp $(kpsewhich gbt7714-numerical.bst) ./gbt7714-thesis.bst

# 修改关键开关
# 将 show.medium.type := #1 改为 show.medium.type := #0
# 效果：去掉 [D/OL] → [D]，[J/OL] → [J]，同时保留 DOI 行
```

然后在 `Thesis.tex` 中引用本地副本：
```latex
\bibliographystyle{gbt7714-thesis}
```

### 8.3 常见踩坑

- 不要随意恢复为 `unsrtnat`，否则 GB/T 格式会全部退回。
- 不要把 `@book`、`@mastersthesis` 改回 `@misc`，除非用户确认只在意视觉、不在意类型规范。
- 每次替换文献后必须重新检查 `.bbl`，不能只凭 `.bib` 判断是否已修好。
