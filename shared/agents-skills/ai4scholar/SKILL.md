---
name: ai4scholar
description: Use when searching scholarly papers, verifying paper metadata, or querying the AI4Scholar Graph API by keyword with an AI4Scholar API key.
metadata:
  clawdbot:
    requires:
      bins:
        - bash
        - curl
      env:
        - AI4SCHOLAR_API_KEY
    primaryEnv: AI4SCHOLAR_API_KEY
---

# AI4Scholar

## Overview

Use AI4Scholar to search academic papers by keyword through the Graph API and return JSON results suitable for downstream checking, citation verification, or literature triage.

## Search Papers

```bash
bash {baseDir}/scripts/paper-search.sh "machine learning"
bash {baseDir}/scripts/paper-search.sh "cash conversion cycle apparel retail" 10
```

- First argument: search query
- Second argument: optional result limit, default `5`

## Direct API Form

```bash
curl -X GET "https://ai4scholar.net/graph/v1/paper/search?query=machine%20learning&limit=5" \
  -H "Authorization: Bearer ${AI4SCHOLAR_API_KEY}"
```

## Notes

- Requires `AI4SCHOLAR_API_KEY` in the environment
- The bundled script uses `curl -G --data-urlencode`, so Chinese and spaces are handled safely
- Returned data is raw JSON; inspect title, authors, year, venue, DOI, and IDs before citing
