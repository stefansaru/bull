#!/usr/bin/env python3
"""
gen_glossary_terms.py -- Build the bilingual (EN/RO) terminology glossary page from
structured term records.

Input: JSON array of {term_en, term_ro, def_en, def_ro, category, sources}.
Output: wiki/meta/terminology.md — grouped by category, EN/RO, with source attribution.
Complements meta/glossary.md (symbols & abbreviations). FR/DE columns can be added later.

Usage: python gen_glossary_terms.py <terms.json> wiki
"""
import sys, os, json
from collections import defaultdict

CAT_ORDER = ["postmark", "postal-history", "printing", "paper", "philatelic-object",
             "condition", "forgery", "catalogue", "currency"]
CAT_TITLE = {"postmark": "Postmarks & cancellations", "postal-history": "Postal history",
             "printing": "Printing & production", "paper": "Paper & watermark",
             "philatelic-object": "Philatelic objects", "condition": "Condition & gum",
             "forgery": "Forgery & reprints", "catalogue": "Catalogues & references",
             "currency": "Currency"}


def cell(s):
    return str(s or "").replace("|", "\\|").replace("\n", " ").strip()


def src_badges(sources):
    m = {"kiriac-ch1": "K", "catalogue": "C", "book-draft": "B"}
    return " ".join(m.get(s, s) for s in (sources or []))


def main():
    terms_file, vault = sys.argv[1], sys.argv[2]
    terms = json.load(open(terms_file, encoding="utf-8"))
    by_cat = defaultdict(list)
    for t in terms:
        by_cat[t.get("category", "other")].append(t)

    out = ["---", "id: meta/terminology", "type: reference",
           "title:", "  en: Terminology — bilingual glossary of terms",
           "  ro: Terminologie — glosar bilingv de termeni",
           "status: draft", f"term_count: {len(terms)}", "---", "",
           "# Terminology — glossary of terms", "",
           "> Bilingual (EN/RO) glossary of the specialist terms used in the Bull's Head "
           "domain — the meaningful subset from **Kiriac 1974 Chapter I** (`K`), the "
           "**auction catalogues** (`C`), and the **book draft** (`B`). Complements "
           "[[glossary]] (symbols & abbreviations). FR/DE columns to be added when those "
           "editions are prepared ([[decisions/DR-009-published-languages|DR-009]]).",
           "",
           f"**{len(terms)} terms.** Source key: `K` Kiriac Ch.1 · `C` catalogues · `B` book draft.",
           ""]

    cats = [c for c in CAT_ORDER if c in by_cat] + [c for c in by_cat if c not in CAT_ORDER]
    for c in cats:
        out.append(f"## {CAT_TITLE.get(c, c.title())}")
        out.append("")
        out.append("| Term (EN) | Termen (RO) | Definition | Definiție | Src |")
        out.append("|---|---|---|---|---|")
        for t in sorted(by_cat[c], key=lambda x: (x.get("term_en") or "").lower()):
            out.append("| " + " | ".join([
                f"**{cell(t.get('term_en'))}**", cell(t.get("term_ro")),
                cell(t.get("def_en")), cell(t.get("def_ro")),
                src_badges(t.get("sources"))]) + " |")
        out.append("")

    os.makedirs(os.path.join(vault, "meta"), exist_ok=True)
    open(os.path.join(vault, "meta", "terminology.md"), "w", encoding="utf-8").write("\n".join(out))
    print(f"wrote {vault}/meta/terminology.md ({len(terms)} terms, {len(cats)} categories)")


if __name__ == "__main__":
    main()
