#!/bin/bash
# Perplexica Search Script
# Usage: perplexica_search.sh <query> [mode] [sources]
# mode: speed|balanced|quality (default: balanced)
# sources: web|academic|discussions (default: web)

PERPLEXICA_URL="${PERPLEXICA_URL:-http://localhost:3001}"
QUERY="$1"
MODE="${2:-balanced}"
SOURCES="${3:-web}"

if [ -z "$QUERY" ]; then
  echo "Usage: $0 <query> [speed|balanced|quality] [web|academic|discussions]"
  exit 1
fi

export _Q="$QUERY" _MODE="$MODE" _SOURCES="$SOURCES" PERPLEXICA_URL

# Get provider info and build search request via Python
RESULT=$(python3 << 'PYEOF'
import json, urllib.request, sys, os

url = os.environ.get("PERPLEXICA_URL", "http://localhost:3001")
query = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("_Q", "")
mode = os.environ.get("_MODE", "balanced")
sources_str = os.environ.get("_SOURCES", "web")

# Get providers
req = urllib.request.Request(f"{url}/api/providers")
with urllib.request.urlopen(req) as resp:
    providers = json.loads(resp.read())["providers"]

# Find chat provider (first with chat models)
chat_pid, chat_key = None, None
embed_pid, embed_key = None, None

for p in providers:
    if p.get("chatModels") and not chat_pid:
        chat_pid = p["id"]
        # Prefer flash-lite > flash > first available
        for m in p["chatModels"]:
            if "flash-lite" in m["key"].lower():
                chat_key = m["key"]
                break
        if not chat_key:
            for m in p["chatModels"]:
                if "flash" in m["key"].lower():
                    chat_key = m["key"]
                    break
        if not chat_key:
            chat_key = p["chatModels"][0]["key"]

    if p.get("embeddingModels") and not embed_pid:
        embed_pid = p["id"]
        embed_key = p["embeddingModels"][0]["key"]

if not chat_pid or not embed_pid:
    print(json.dumps({"error": "No provider configured"}))
    sys.exit(1)

# Build request
sources = [s.strip() for s in sources_str.split(",")]
body = json.dumps({
    "chatModel": {"providerId": chat_pid, "key": chat_key},
    "embeddingModel": {"providerId": embed_pid, "key": embed_key},
    "optimizationMode": mode,
    "sources": sources,
    "query": query,
    "stream": False
}).encode()

req = urllib.request.Request(f"{url}/api/search", data=body, headers={"Content-Type": "application/json"})
try:
    with urllib.request.urlopen(req, timeout=180) as resp:
        data = json.loads(resp.read())
        if "message" in data and "sources" in data:
            print("## 搜索结果\n")
            print(data["message"])
            print("\n## 来源引用\n")
            for i, src in enumerate(data.get("sources", []), 1):
                meta = src.get("metadata", {})
                title = meta.get("title", "N/A")
                url_s = meta.get("url", "#")
                print(f"[{i}] [{title}]({url_s})")
        else:
            print(json.dumps(data, ensure_ascii=False, indent=2))
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
PYEOF
)

echo "$RESULT"
