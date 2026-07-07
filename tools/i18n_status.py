#!/usr/bin/env python3
"""
i18n_status.py -- Report translation coverage & staleness across the narrative.

For each English page it reads the unit markers + English text, recomputes each
unit's en_hash, and compares against the sidecar's stored en_hash:
  - ok      : translation present and en_hash matches  -> valid
  - stale   : translation present but English changed since (hash mismatch)
  - missing : translatable English unit with no translation for that language
Orphan (non-English loose) units are reported separately.

Feeds audit Stage D (REQ-L2). Read-only.

Usage:
  python i18n_status.py wiki [--lang ro,fr,de] [--verbose]
"""
import sys, os, re, argparse, glob
import yaml
sys.path.insert(0, os.path.dirname(__file__))
from i18n import en_hash, sidecar_path

MARKER = re.compile(r"<!--\s*u:(u\d+)\s+kind:(\w+)\s*-->")


def parse_page_units(md_path):
    """Return {uid: {'kind':k, 'en':text}} for units in an English page body."""
    text = open(md_path, encoding="utf-8").read()
    body = text.split("\n---\n", 1)[-1] if text.startswith("---") else text
    # split by markers, keep uid+kind
    units = {}
    parts = MARKER.split(body)
    # parts: [pre, uid1, kind1, chunk1, uid2, kind2, chunk2, ...]
    i = 1
    while i + 2 < len(parts) + 1 and i + 1 < len(parts):
        uid = parts[i]; kind = parts[i + 1]
        chunk = parts[i + 2] if i + 2 < len(parts) else ""
        # strip heading line & image/caption markdown to approximate the EN prose
        en = re.sub(r"^!\[.*?\]\(.*?\)\s*$", "", chunk, flags=re.M)
        en = re.sub(r"^\*.*\*\s*$", "", en, flags=re.M).strip()
        units[uid] = {"kind": kind, "en": en}
        i += 3
    return units


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("vault")
    ap.add_argument("--lang", default="ro,fr,de")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()
    langs = args.lang.split(",")

    narr = os.path.join(args.vault, "narrative")
    pages = sorted(glob.glob(os.path.join(narr, "**", "*.md"), recursive=True))
    pages = [p for p in pages if not p.endswith("_toc.md")]

    tot = {lg: {"ok": 0, "stale": 0, "missing": 0} for lg in langs}
    orphans = 0
    translatable = 0
    stale_examples = []

    for p in pages:
        side_p = sidecar_path(p)
        side = {}
        if os.path.exists(side_p):
            side = yaml.safe_load(open(side_p, encoding="utf-8")) or {}
        sunits = (side.get("units") or {})
        punits = parse_page_units(p)
        for uid, pu in punits.items():
            if pu["kind"] != "quad":
                continue  # only quad units are translatable prose
            translatable += 1
            cur_hash = en_hash(pu["en"])
            su = sunits.get(uid, {})
            for lg in langs:
                entry = su.get(lg)
                if not isinstance(entry, dict) or not entry.get("text"):
                    tot[lg]["missing"] += 1
                elif su.get("en_hash") and su["en_hash"] != cur_hash:
                    tot[lg]["stale"] += 1
                    if len(stale_examples) < 8:
                        stale_examples.append(f"{os.path.relpath(p, narr)} :: {uid} :: {lg}")
                else:
                    tot[lg]["ok"] += 1
        # orphan (non-English loose) units
        for uid, su in sunits.items():
            if su.get("kind") == "text" and su.get("orphan_lang"):
                orphans += 1

    print(f"pages: {len(pages)} | translatable EN quad-units: {translatable} | orphan fragments: {orphans}")
    print(f"{'lang':>5} | {'ok':>5} {'stale':>6} {'missing':>8} | coverage")
    for lg in langs:
        t = tot[lg]
        denom = t["ok"] + t["stale"] + t["missing"]
        cov = 100.0 * t["ok"] / denom if denom else 0.0
        print(f"{lg:>5} | {t['ok']:>5} {t['stale']:>6} {t['missing']:>8} | {cov:5.1f}% valid")
    if args.verbose and stale_examples:
        print("\nstale examples:")
        for e in stale_examples:
            print("  ", e)


if __name__ == "__main__":
    main()
