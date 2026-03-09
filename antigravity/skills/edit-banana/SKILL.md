---
name: edit-banana
description: |
  将静态不可编辑的图表（PDF/截图）转换为完全可编辑的矢量格式（DrawIO XML / PPTX / SVG）。
  由北京理工大学 DataLab 基于 SAM3 + 多模态 LLM 构建，支持流程图、架构图、PDF 页面的精准重建。
  触发条件：用户提到"PDF转可编辑"、"流程图转DrawIO"、"截图转PPT"、"图表重建"、
  "把这张图变成可编辑的"、"Edit Banana"等关键词。
---

# Edit Banana — 静态图表转可编辑格式

> 核心口号：**Make the Uneditable, Editable**
> 来源：北京理工大学 BIT-DataLab | GitHub: [BIT-DataLab/Edit-Banana](https://github.com/BIT-DataLab/Edit-Banana)

## 推荐使用方式

**直接使用在线版（推荐）**，无需本地部署：

🌐 **[https://editbanana.anxin6.cn/](https://editbanana.anxin6.cn/)**

> 注：GitHub 代码版本落后于在线服务，优先用在线版。注册送 10 credits，用完后付费。

---

## 支持的转换场景

| 场景 | 输入 | 输出格式 |
|------|------|---------|
| **流程图/架构图转矢量** | 截图 PNG/JPG | DrawIO XML / SVG / PPTX |
| **PDF转可编辑PPT** | PDF 文件 | PPTX（元素可独立拖拽编辑）|
| **Human-in-the-Loop修改** | 截图 + 交互指令 | 局部修改后的 DrawIO |
| **技术图表重建** | 论文/方案PDF中的图 | DrawIO 全元素可编辑 |

---

## 核心技术

- **SAM3**（BIT fine-tuned Segment Anything Model 3）：精准分割图表元素，还原形状/箭头/样式
- **Qwen-VL / GPT-4V**：多模态 LLM 多轮扫描，提取语义内容
- **Tesseract OCR + Pix2Text**：文字定位 + 数学公式 → LaTeX 转换
- **精度保证**：1:1 还原颜色/层级/虚线样式，所有元素独立可选

---

## 使用流程（在线版）

```
① 访问 https://editbanana.anxin6.cn/
② 上传图片（PNG/JPG）或 PDF 文件
③ 等待处理（通常数秒内完成）
④ 下载 DrawIO XML / PPTX / SVG
⑤ 在 DrawIO / PowerPoint 中直接编辑
```

---

## 典型使用场景（与现有工作流结合）

### 场景 1：PDF 技术方案图 → Overleaf/Beamer PPT

```
PDF 技术方案（含架构图截图）
  ↓ Edit Banana（在线版）
DrawIO XML（可编辑）
  ↓ DrawIO 调整布局/标注
导出 SVG/PNG
  ↓ beamer Skill → Overleaf
精美 LaTeX 汇报幻灯片
```

### 场景 2：竞品技术框架图「借用」后二改

```
竞品白皮书截图
  ↓ Edit Banana
DrawIO XML
  ↓ 修改品牌色/文字/箭头
申报书/方案书可用图表
```

### 场景 3：揭榜挂帅类申报材料图表修改

```
旧版 PDF 方案图（不可编辑）
  ↓ Edit Banana
PPTX（按模块逐一编辑）
  ↓ 调整参数/指标后导出
新版申报材料
```

---

## 触发关键词

直接对 Antigravity 说：
- 「把这个 PDF/截图转成 DrawIO」
- 「帮我把这张流程图变成可编辑的」
- 「PDF 转 PPTX，要可以编辑元素」
- 「用 Edit Banana 处理这张图」
- 「截图里的架构图怎么变成矢量」

---

## 注意事项

| 项目 | 说明 |
|------|------|
| **本地部署** | 需要 GPU + SAM3 模型权重，Mac Mini 无独显不适合本地跑 |
| **Credits** | 注册送 10 credits，复杂图片消耗更多 |
| **精度局限** | 高度复杂的图表（密集节点 + 多色渐变）可能需要手动微调 |
| **数据安全** | 在线版上传内容注意保密级别，涉密图表请本地部署处理 |
