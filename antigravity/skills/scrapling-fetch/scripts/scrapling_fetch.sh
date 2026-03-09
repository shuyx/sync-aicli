#!/bin/bash
# scrapling_fetch.sh — Bash wrapper for Scrapling adaptive web fetcher
# Usage: scrapling_fetch.sh <url> [fast|stealth|browser|auto]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
URL="$1"
MODE="${2:-auto}"

if [ -z "$URL" ]; then
  echo "Usage: $0 <url> [fast|stealth|browser|auto]"
  echo ""
  echo "Modes:"
  echo "  fast    — Pure HTTP (fastest, no anti-bot bypass)"
  echo "  stealth — Fingerprint spoofing (Cloudflare bypass)"
  echo "  browser — Full headless browser (JS-heavy SPA pages)"
  echo "  auto    — Try fast → stealth → browser (default)"
  exit 1
fi

python3 "${SCRIPT_DIR}/scrapling_fetch.py" "$URL" "$MODE"
