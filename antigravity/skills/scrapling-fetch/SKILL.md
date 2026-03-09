---
name: scrapling-fetch
description: |
  使用 Scrapling 自适应抓取框架获取网页内容，突破反爬虫屏障。
  当 read_url_content 返回 403/被阻断、需要绕过 Cloudflare 防护、
  或需要渲染 JS 动态页面时使用此 Skill。
  触发条件：用户提到"抓取网页"、"爬取"、"read_url_content 失败"、
  "403 被拦截"、"Cloudflare 盾"、"JS 渲染页面"等关键词，
  或当内置 read_url_content 工具返回空内容/错误时自动降级使用。
---

# Scrapling Fetch — 自适应反反爬网页抓取 Skill

> 基于 [Scrapling](https://github.com/D4Vinci/Scrapling) 库，提供三级渐进式网页抓取能力。

## 何时使用

| 场景 | 用 read_url_content | 用 scrapling-fetch |
|------|:---:|:---:|
| 普通公开网页 | ✅ | |
| Cloudflare 5s 盾保护 | ❌ | ✅ (`stealth`) |
| 需要 JS 渲染的 SPA 页面 | ❌ | ✅ (`browser`) |
| Reddit / Twitter 返回 403 | ❌ | ✅ (`stealth` / `auto`) |
| PyPI / npm 等包信息页 | ❌ | ✅ (`auto`) |
| 高速批量简单页面 | ✅ | ✅ (`fast`) |

## 三种抓取模式

| 模式 | 引擎 | 速度 | 反爬能力 | 适用场景 |
|------|------|:---:|:---:|------|
| `fast` | Fetcher (纯 HTTP) | ⚡⚡⚡ | 低 | 公开静态页面、API 端点 |
| `stealth` | StealthFetcher (指纹伪装) | ⚡⚡ | 中高 | Cloudflare、WAF 防护 |
| `browser` | PlayWrightFetcher (无头浏览器) | ⚡ | 高 | JS 渲染 SPA、动态加载 |
| `auto` | 逐级升级尝试 | 自适应 | 自适应 | **推荐默认** |

## 使用方法

### 方式 1: 脚本调用

```bash
bash ~/.gemini/antigravity/skills/scrapling-fetch/scripts/scrapling_fetch.sh \
  "https://example.com" \
  auto
```

参数:
- `$1`: 目标 URL (必需)
- `$2`: 模式 — `fast` | `stealth` | `browser` | `auto` (默认 auto)

### 方式 2: 直接 Python 调用

```bash
python3 ~/.gemini/antigravity/skills/scrapling-fetch/scripts/scrapling_fetch.py \
  "https://example.com" \
  stealth
```

### 方式 3: 分析 read_url_content 失败后自动降级

当 `read_url_content` 工具返回 403、空内容或 Cloudflare 挑战页面时：

```bash
# 先尝试 stealth 模式
bash ~/.gemini/antigravity/skills/scrapling-fetch/scripts/scrapling_fetch.sh \
  "https://blocked-site.com/article" \
  stealth

# 如果仍失败，升级到 browser 模式
bash ~/.gemini/antigravity/skills/scrapling-fetch/scripts/scrapling_fetch.sh \
  "https://blocked-site.com/article" \
  browser
```

## 依赖

- Python 3.8+
- `scrapling` (`pip install scrapling`)
- Playwright 浏览器内核 (仅 `browser` 模式需要，通过 `scrapling install` 安装)

## 运维

### 安装/更新 Scrapling
```bash
pip3 install -U scrapling
```

### 安装 Playwright 浏览器内核 (首次使用 browser 模式前)
```bash
scrapling install
```
