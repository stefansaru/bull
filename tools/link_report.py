#!/usr/bin/env python3
"""
link_report.py -- Which external sites does the wiki link to, and which have a reference page?

Inline URLs stay where they are in the prose (DR-014). Each site or database gets one
reference page under entities/references/{web,archives}/ listing its `domains:`. This
report counts URLs per domain and flags domains with no reference page.

Raw OCR under sources/ is counted separately: URLs there are mostly page footers of the
scanned documents, not citations.

Read-only. Usage: python link_report.py wiki [--min 3]
"""
import argparse
import os
import re
from collections import Counter

import yaml

URL = re.compile(r"https?://([^/\s)\]>\"'|]+)")


def domains_with_pages(vault):
    covered = {}
    for kind in ("web", "archives", "articles"):
        d = os.path.join(vault, "entities", "references", kind)
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if not f.endswith(".md"):
                continue
            text = open(os.path.join(d, f), encoding="utf-8").read()
            if not text.startswith("---"):
                continue
            fm = yaml.safe_load(text[3:text.find("\n---", 3)]) or {}
            for dom in fm.get("domains") or []:
                covered[str(dom).lower()] = f"{kind}/{f[:-3]}"
    return covered


def normalise(host):
    host = host.lower().split(":")[0]
    return host[4:] if host.startswith("www.") else host


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("vault")
    ap.add_argument("--min", type=int, default=3, help="hide uncovered domains with fewer URLs")
    args = ap.parse_args()

    covered = {normalise(k): v for k, v in domains_with_pages(args.vault).items()}
    prose, raw = Counter(), Counter()
    for dirpath, _, files in os.walk(args.vault):
        bucket = raw if os.sep + "sources" in dirpath.replace(args.vault, "", 1) else prose
        for f in files:
            if f.endswith((".md", ".yml")):
                for m in URL.finditer(open(os.path.join(dirpath, f), encoding="utf-8", errors="replace").read()):
                    bucket[normalise(m.group(1))] += 1

    def table(counter, title):
        print(f"\n## {title}\n")
        print(f"{'URLs':>6}  {'domain':<40} reference page")
        hidden = 0
        for dom, n in counter.most_common():
            page = covered.get(dom) or next((v for k, v in covered.items() if dom.endswith("." + k)), "")
            if not page and n < args.min:
                hidden += 1
                continue
            print(f"{n:>6}  {dom:<40} {page or '— missing'}")
        if hidden:
            print(f"   (+{hidden} uncovered domains with fewer than {args.min} URLs)")

    table(prose, "Wiki prose (entities, narrative, meta, strategy)")
    table(raw, "Raw sources (sources/) — mostly scan footers")
    total = sum(prose.values())
    hit = sum(n for d, n in prose.items() if d in covered or any(d.endswith("." + k) for k in covered))
    print(f"\nCoverage of prose URLs by a reference page: {hit}/{total} ({hit / total:.0%})" if total else "")


if __name__ == "__main__":
    main()
