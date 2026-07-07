#!/usr/bin/env python3
"""
assemble_kiriac_translations.py -- Stitch the translated Kiriac Ch.I chunks into the
cleaned/translated source sibling files (DR-012).

Reads work/kiriac/ch1_p28-43.<lang>.md + ch1_p44-59.<lang>.md and writes
wiki/sources/kiriac-1974/chapter-1-postmarks-1858.<lang>.md with frontmatter.

Usage: python assemble_kiriac_translations.py work/kiriac wiki
"""
import sys, os

CHUNKS = ["ch1_p28-43", "ch1_p44-59"]
LANGS = {"en": "English", "ro": "Romanian (cleaned)"}


def fm(lang):
    return "\n".join([
        "---",
        f"id: sources/kiriac-1974/chapter-1-postmarks-1858.{lang}",
        "type: source-translated",
        "source: kiriac-1974",
        "raw: \"[[chapter-1-postmarks-1858]]\"",
        "pdf_pages: 28-59",
        f"lang: {lang}",
        "status: translated",
        "---", ""])


def main():
    indir, vault = sys.argv[1], sys.argv[2]
    outdir = os.path.join(vault, "sources", "kiriac-1974")
    for lang, label in LANGS.items():
        parts = []
        missing = []
        for ch in CHUNKS:
            p = os.path.join(indir, f"{ch}.{lang}.md")
            if os.path.exists(p):
                parts.append(open(p, encoding="utf-8").read().strip())
            else:
                missing.append(p)
        if missing:
            print(f"[{lang}] MISSING: {missing} — skipping")
            continue
        header = (f"# Kiriac 1974 — Chapter I, Classic postmarks 1858 "
                  f"({label}, pdf pp. 28-59)\n\n"
                  f"> Cleaned + translated from the raw OCR "
                  f"[[chapter-1-postmarks-1858|raw source]] (DR-012). Diacritics restored / "
                  f"translated; page markers preserved. Verbatim baseline stays in the raw file.\n\n")
        body = "\n\n".join(parts)
        out = os.path.join(outdir, f"chapter-1-postmarks-1858.{lang}.md")
        open(out, "w", encoding="utf-8").write(fm(lang) + header + body + "\n")
        print(f"wrote {out} ({len(body)} chars)")


if __name__ == "__main__":
    main()
