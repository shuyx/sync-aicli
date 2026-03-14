#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: bash paper-search.sh <query> [limit]" >&2
  exit 1
fi

if [[ -z "${AI4SCHOLAR_API_KEY:-}" ]]; then
  AI4SCHOLAR_API_KEY="$(launchctl getenv AI4SCHOLAR_API_KEY 2>/dev/null || true)"
fi

if [[ -z "${AI4SCHOLAR_API_KEY:-}" ]]; then
  echo "AI4SCHOLAR_API_KEY is not set" >&2
  exit 1
fi

query="$1"
limit="${2:-5}"

case "$limit" in
  ''|*[!0-9]*)
    echo "limit must be a positive integer" >&2
    exit 1
    ;;
esac

curl -sS -X GET "https://ai4scholar.net/graph/v1/paper/search" \
  -G \
  --data-urlencode "query=${query}" \
  --data-urlencode "limit=${limit}" \
  -H "Authorization: Bearer ${AI4SCHOLAR_API_KEY}"
