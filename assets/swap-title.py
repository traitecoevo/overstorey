#!/usr/bin/env python3
"""Post-render: reorder browser-tab titles from "Page – Overstorey" to
"Overstorey – Page".

Quarto composes the <title> as "{page} – {site}" in its HTML writer, after
all Lua filters run, so this can only be fixed on the rendered output.

post-render runs over the ENTIRE output dir on every render — including a
single-file or preview render — so the rewrite must be idempotent: we only
swap when the trailing segment is exactly the site title. Once swapped, the
trailing segment is the page title, so a second pass leaves it alone. Pages
with no separator (e.g. the home page, title just "Overstorey") are skipped.
"""
import os
import re
import sys
from pathlib import Path

SITE = "Overstorey"  # website.title in _quarto.yml; the suffix Quarto appends
SEP = " – "  # space en-dash space, as Quarto emits it
TITLE_RE = re.compile(r"<title>(.*?)</title>", re.DOTALL)

out_dir = Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "_site"))
if not out_dir.is_absolute():
    out_dir = Path(os.environ.get("QUARTO_PROJECT_DIR", ".")) / out_dir

changed = 0
for html in out_dir.rglob("*.html"):
    text = html.read_text(encoding="utf-8")

    def swap(m):
        global changed
        title = m.group(1)
        page, sep, site = title.rpartition(SEP)
        if not sep or site != SITE:
            return m.group(0)  # no separator, or already reordered
        changed += 1
        return f"<title>{site}{SEP}{page}</title>"

    new = TITLE_RE.sub(swap, text, count=1)
    if new != text:
        html.write_text(new, encoding="utf-8")

print(f"swap-title: reordered {changed} page title(s)", file=sys.stderr)
