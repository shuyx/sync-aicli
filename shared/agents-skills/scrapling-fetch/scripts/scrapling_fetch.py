#!/usr/bin/env python3
"""
scrapling_fetch.py — Adaptive web page fetcher with anti-bot bypass.

Usage:
    python3 scrapling_fetch.py <url> [mode]

Modes:
    fast    — Pure HTTP request (fastest, no anti-bot bypass)
    stealth — Stealth HTTP with fingerprint spoofing (Cloudflare bypass)
    browser — Full headless browser rendering (JS-heavy SPA pages)
    auto    — Try fast → stealth → browser (default)

Output: Clean text content of the page, printed to stdout.
"""

import sys
import json


def fetch_fast(url):
    """Fast mode: pure HTTP, no anti-bot. Best for static/public pages."""
    from scrapling import Fetcher
    fetcher = Fetcher()
    page = fetcher.get(url, timeout=30)
    return page


def fetch_stealth(url):
    """Stealth mode: fingerprint spoofing, bypasses Cloudflare 5s shield."""
    from scrapling import StealthyFetcher
    page = StealthyFetcher.fetch(url, timeout=60000)
    return page


def fetch_browser(url):
    """Browser mode: full Playwright headless, handles JS SPA rendering."""
    from scrapling import DynamicFetcher
    page = DynamicFetcher.fetch(url, timeout=90000)
    return page


def extract_content(page):
    """Extract clean text content from a Scrapling Response object."""
    if page is None:
        return None, "Response is None"

    if page.status != 200:
        return None, f"HTTP status: {page.status} {getattr(page, 'reason', '')}"

    text = ""

    # Method 1: get_all_text() — cleanest text extraction
    if hasattr(page, 'get_all_text'):
        try:
            all_text = page.get_all_text()
            if all_text and isinstance(all_text, (list, tuple)):
                text = "\n".join(str(t).strip() for t in all_text if t and str(t).strip())
            elif all_text and isinstance(all_text, str):
                text = all_text.strip()
        except Exception:
            pass

    # Method 2: CSS selectors targeting main content
    if len(text) < 100:
        for selector in ["article", "main", "[role='main']", ".content", "#content"]:
            try:
                elements = page.css(selector)
                if elements:
                    parts = []
                    for el in elements:
                        if hasattr(el, 'get_all_text'):
                            el_texts = el.get_all_text()
                            if isinstance(el_texts, (list, tuple)):
                                parts.extend(str(t).strip() for t in el_texts if t and str(t).strip())
                            elif el_texts:
                                parts.append(str(el_texts).strip())
                        elif hasattr(el, 'text') and el.text:
                            parts.append(el.text.strip())
                    candidate = "\n".join(parts)
                    if len(candidate) > len(text):
                        text = candidate
            except Exception:
                continue

    # Method 3: body as raw HTML → strip tags manually
    if len(text) < 100 and hasattr(page, 'body'):
        try:
            import re
            body = page.body
            if isinstance(body, bytes):
                body = body.decode('utf-8', errors='ignore')
            # Remove script/style tags with content
            body = re.sub(r'<(script|style)[^>]*>.*?</\1>', '', body, flags=re.DOTALL | re.IGNORECASE)
            # Remove all HTML tags
            body = re.sub(r'<[^>]+>', ' ', body)
            # Clean up whitespace
            body = re.sub(r'\s+', ' ', body).strip()
            if len(body) > len(text):
                text = body
        except Exception:
            pass

    if text and len(text) > 50:
        return text, None
    return None, f"Content too short ({len(text) if text else 0} chars)"


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scrapling_fetch.py <url> [fast|stealth|browser|auto]", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else "auto"

    fetchers = {
        "fast":    [("fast", fetch_fast)],
        "stealth": [("stealth", fetch_stealth)],
        "browser": [("browser", fetch_browser)],
        "auto":    [("fast", fetch_fast), ("stealth", fetch_stealth), ("browser", fetch_browser)],
    }

    if mode not in fetchers:
        print(f"Error: unknown mode '{mode}'. Use: fast, stealth, browser, auto", file=sys.stderr)
        sys.exit(1)

    last_error = None
    for name, fetch_fn in fetchers[mode]:
        try:
            print(f"[scrapling] Trying {name} mode for: {url}", file=sys.stderr)
            page = fetch_fn(url)
            content, error = extract_content(page)
            if content:
                # Output header
                print(f"--- scrapling-fetch | mode: {name} | url: {url} ---")
                print(f"Status: {page.status}")
                print(f"Content-Length: {len(content)} chars")
                print("---")
                print()
                print(content)
                return
            elif error:
                last_error = error
                print(f"[scrapling] {name} mode failed: {error}", file=sys.stderr)
            else:
                last_error = f"{name}: unknown extraction failure"
                print(f"[scrapling] {name} mode: {last_error}", file=sys.stderr)
        except Exception as e:
            last_error = f"{name}: {str(e)}"
            print(f"[scrapling] {name} mode exception: {e}", file=sys.stderr)

    # All fetchers failed
    print(json.dumps({
        "error": "All fetcher modes failed",
        "last_error": str(last_error),
        "url": url,
        "mode": mode
    }, ensure_ascii=False, indent=2))
    sys.exit(1)


if __name__ == "__main__":
    main()
