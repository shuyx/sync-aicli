---
name: mineru-pdf-sync
description: |
  PDF文档智能转换为Markdown并同步到Obsidian。适用于将PDF论文、资料用MinerU云端API转Markdown后自动归档到Obsidian知识库。
  触发条件：(1) 用户提到"PDF转Markdown"、"MinerU"、"PDF同步Obsidian"；(2) 处理~/Documents/Files/<项目>/PDF下的PDF文件
---

# MinerU PDF → Markdown → Obsidian 自动同步

## 一句话指令模板

```
把 ~/Documents/Files/无人机/PDF 里的新PDF用MinerU云端转成md，并同步到Obsidian商业孵化/【2】无人机/【0】资料文件，已转过的跳过。
```

## 工作流概览

1. **输入**: `~/Documents/Files/<项目>/PDF/*.pdf`
2. **转换**: MinerU 云端 API（异步任务 + 轮询结果）
3. **中转输出**: `~/Documents/Files/<项目>/【0】资料文件/<pdf_stem>.md`
4. **最终归档（剪切）**: `~/Obsidian/kevinob/商业孵化/<对应项目>/【0】资料文件/`

## 关键脚本与配置

### 执行脚本

```bash
python3 /Users/mac-minishu/clawd/agents/main/mineru_cloud_pdf_to_md_sync.py --max-files 2
```

**常用参数**:

- `--max-files N`: 每次最多处理N个新PDF（默认2）
- `--model-version vlm`: 模型版本（默认vlm）
- `--poll-timeout 900`: 最长轮询等待（默认900s）

### 配置文件

- **Token**: `/Users/mac-minishu/clawd/agents/main/data/mineru_cloud_token.txt`
- **状态文件**: `/Users/mac-minishu/clawd/agents/main/memory/mineru-cloud-state.json`（去重记录）
- **并发锁**: `/tmp/mineru_cloud_pdf_to_md_sync.lock`

## 去重机制

- 同一个PDF若`mtime_ns + size`未变化且state为success → **跳过**
- 若Obsidian对应目录已存在`<pdf_stem>.md` → **直接跳过并记录success**

## 验证方法

1. 放一个小PDF到：`~/Documents/Files/无人机/PDF/`
2. 手动跑脚本：

   ```bash
   python3 /Users/mac-minishu/clawd/agents/main/mineru_cloud_pdf_to_md_sync.py --max-files 1
   ```

3. 检查Obsidian目录：`~/Obsidian/kevinob/商业孵化/【2】无人机/【0】资料文件/`

## 常见故障排查

- **Token错误/过期**: 更新`data/mineru_cloud_token.txt`
- **轮询超时**: 增加`--poll-timeout`，或降低`--max-files`
- **zip下载失败**: 检查`full_zip_url`是否过期
- **Obsidian未移动**: 确认项目名能匹配（商业孵化/<项目>/【0】资料文件）

## 项目映射规则

以Obsidian `商业孵化/`下的项目文件夹为真相源，按"名称归一化"进行匹配。

输入目录规范: `~/Documents/Files/<项目>/PDF/`
输出归档目录: `~/Obsidian/kevinob/商业孵化/<对应项目>/【0】资料文件/`
