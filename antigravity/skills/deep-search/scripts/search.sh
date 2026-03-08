#!/usr/bin/env bash
# deep-search/scripts/search.sh
# Antigravity 多源深度搜索编排脚本
# 使用 Brave + Exa + Tavily MCP 中的 API Key 并行检索，生成 MD 报告
# 注意：本脚本通过 npx 直接调用各 MCP server，或通过环境变量调用 curl

set -euo pipefail

# ── 默认参数 ──────────────────────────────────────────────
PROMPT=""
TASK_NAME="search-$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="/tmp/deep-search-results"
OUTPUT_FILE=""
MAX_RESULTS=5

# API Keys（从 Antigravity settings.json 中已配置）
BRAVE_API_KEY="BSAHoe345BI8eW7D094WTfejZO__RFQ"
EXA_API_KEY="7c8b94b0-a73f-44ac-8463-a9c8c490d10f"
TAVILY_API_KEY="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"

# ── 参数解析 ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)      PROMPT="$2";       shift 2 ;;
    --task-name)   TASK_NAME="$2";    shift 2 ;;
    --output)      OUTPUT_FILE="$2";  shift 2 ;;
    --max-results) MAX_RESULTS="$2";  shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

[[ -z "$PROMPT" ]] && { echo "ERROR: --prompt is required"; exit 1; }

mkdir -p "$OUTPUT_DIR"
[[ -z "$OUTPUT_FILE" ]] && OUTPUT_FILE="$OUTPUT_DIR/${TASK_NAME}.md"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
ENCODED_PROMPT=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$PROMPT")

echo "🔍 Deep Search: $PROMPT"
echo "📄 Output: $OUTPUT_FILE"

# ── 报告头部 ──────────────────────────────────────────────
cat > "$OUTPUT_FILE" << EOF
# 深度搜索报告：$PROMPT
生成时间：$TIMESTAMP | Task: $TASK_NAME

---

EOF

# ── 1. Brave Search ──────────────────────────────────────
echo "⚡ [1/3] Brave Search..."
BRAVE_RESPONSE=$(curl -sf \
  "https://api.search.brave.com/res/v1/web/search?q=${ENCODED_PROMPT}&count=${MAX_RESULTS}&text_decorations=false" \
  -H "Accept: application/json" \
  -H "Accept-Encoding: gzip" \
  -H "X-Subscription-Token: $BRAVE_API_KEY" \
  --compressed 2>/dev/null || echo '{"web":{"results":[]}}')

cat >> "$OUTPUT_FILE" << 'EOF'
## 🔵 Brave Search 结果

EOF

echo "$BRAVE_RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
results = data.get('web', {}).get('results', [])
if not results:
    print('（无结果）')
for i, r in enumerate(results, 1):
    title = r.get('title', '').replace('\n', ' ')
    url = r.get('url', '')
    desc = r.get('description', '').replace('\n', ' ')[:200]
    print(f'**{i}. [{title}]({url})**')
    print(f'> {desc}')
    print()
" >> "$OUTPUT_FILE"

# ── 2. Exa Search ───────────────────────────────────────
echo "⚡ [2/3] Exa Semantic Search..."
EXA_RESPONSE=$(curl -sf \
  "https://api.exa.ai/search" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $EXA_API_KEY" \
  -d "{\"query\": \"$PROMPT\", \"numResults\": $MAX_RESULTS, \"useAutoprompt\": true}" \
  2>/dev/null || echo '{"results":[]}')

cat >> "$OUTPUT_FILE" << 'EOF'
## 🟣 Exa 语义搜索结果

EOF

echo "$EXA_RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
results = data.get('results', [])
if not results:
    print('（无结果）')
for i, r in enumerate(results, 1):
    title = r.get('title', '').replace('\n', ' ')
    url = r.get('url', '')
    score = r.get('score', 0)
    snippet = r.get('text', '')[:200].replace('\n', ' ')
    print(f'**{i}. [{title}]({url})** (score: {score:.3f})')
    if snippet:
        print(f'> {snippet}...')
    print()
" >> "$OUTPUT_FILE"

# ── 3. Tavily Search + Extract ───────────────────────────
echo "⚡ [3/3] Tavily Deep Extract..."
TAVILY_RESPONSE=$(curl -sf \
  "https://api.tavily.com/search" \
  -H "Content-Type: application/json" \
  -d "{\"api_key\": \"$TAVILY_API_KEY\", \"query\": \"$PROMPT\", \"search_depth\": \"advanced\", \"max_results\": $MAX_RESULTS, \"include_answer\": true}" \
  2>/dev/null || echo '{"results":[],"answer":""}')

cat >> "$OUTPUT_FILE" << 'EOF'
## 🟠 Tavily 深度搜索结果

EOF

echo "$TAVILY_RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
answer = data.get('answer', '')
if answer:
    print('### AI 综合回答')
    print(answer)
    print()
print('### 来源详情')
results = data.get('results', [])
if not results:
    print('（无结果）')
for i, r in enumerate(results, 1):
    title = r.get('title', '').replace('\n', ' ')
    url = r.get('url', '')
    content = r.get('content', '')[:300].replace('\n', ' ')
    score = r.get('score', 0)
    print(f'**{i}. [{title}]({url})** (relevance: {score:.2f})')
    if content:
        print(f'> {content}...')
    print()
" >> "$OUTPUT_FILE"

# ── 来源汇总 ─────────────────────────────────────────────
cat >> "$OUTPUT_FILE" << 'EOF'

---

## 📚 参考来源汇总

EOF

{
  echo "$BRAVE_RESPONSE" | python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('web',{}).get('results',[]):
    print(f'- [Brave] [{r.get(\"title\",\"\")}]({r.get(\"url\",\"\")})')
" 2>/dev/null || true

  echo "$EXA_RESPONSE" | python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('results',[]):
    print(f'- [Exa]   [{r.get(\"title\",\"\")}]({r.get(\"url\",\"\")})')
" 2>/dev/null || true

  echo "$TAVILY_RESPONSE" | python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('results',[]):
    print(f'- [Tavily][{r.get(\"title\",\"\")}]({r.get(\"url\",\"\")})')
" 2>/dev/null || true

} >> "$OUTPUT_FILE"

echo ""
echo "✅ 报告完成！路径: $OUTPUT_FILE"
echo "字数: $(wc -w < "$OUTPUT_FILE") words"
