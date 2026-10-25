#!/usr/bin/env python3
"""
gen_abbreviations.py -- Generate wiki/entities/abbreviations/: one page per row of the
book's Table 2 (Abbreviations), plus an index README grouped by first letter (UIC-DAT-01).

Source: wiki/meta/glossary.md, "Abbreviations (Table 2)" — the canonical copy; its rows
are identical to narrative/01-introduction/006-abbreviations.md. The glossary stays
verbatim; known source slips are corrected in the generated pages and noted there.

Pages carry `generated_by`; remove that key to take a page over by hand.
Usage: python tools/gen_abbreviations.py
"""
import re
import sys
from collections import defaultdict

from wikilib import WIKI, HandOwnedPage, read_page, slug, write_generated

GENERATOR = "tools/gen_abbreviations.py"
GLOSSARY = WIKI / "meta" / "glossary.md"
OUT = WIKI / "entities" / "abbreviations"
LANGS = ["en", "ro", "fr", "de"]

CATEGORY = {"📅": "calendar", "🌍": "country", "🎨": "colour standard", "📖": "catalogue",
            "📯": "postal", "💰": "money", "£": "money", "⨀": "handstamp", "✉": "postal",
            "~": "general", "DE": "organisation", "": "general"}

# Same letters, different meanings: qualify the slug (keyed by abbreviation and marker).
# Slugs carry an `abbr-` prefix: bare stems like `lp` or `m1` already name catalogue and
# handstamp pages, and wikilinks resolve by unique stem.
QUALIFIED = {("SG", "💰"): "abbr-sg-sear-greek-coins", ("SG", "📖"): "abbr-sg-stanley-gibbons",
             ("g", ""): "abbr-g-gram", ("G", "📅"): "abbr-g-gregorian"}

SEE = {
    "LP": "../references/catalogues/lp", "MI": "../references/catalogues/michel",
    "SC": "../references/catalogues/scott", "abbr-sg-stanley-gibbons": "../references/catalogues/stanley-gibbons",
    "YT": "../references/catalogues/yvert-tellier",
    "M1": "../handstamps/M1", "PM52": "../handstamps/PM52",
    "J": "../concepts/julian-calendar", "G": "../concepts/gregorian-calendar",
}

# BPP: the book's Romanian and French cells are swapped.
SWAPPED_RO_FR = {"BPP"}


def table_rows():
    _, body = read_page(GLOSSARY)
    section = body.split("## Abbreviations (Table 2)", 1)[1]
    rows = []
    for line in section.splitlines():
        line = line.strip()
        if not line.startswith("|"):
            if rows:
                break
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if cells[0] in ("Abbr.", "") or re.fullmatch(r":?-+:?", cells[0]):
            continue
        rows.append(cells)
    return rows


def main():
    rows = table_rows()
    if len(rows) != 60:
        sys.exit(f"expected 60 abbreviations in Table 2, found {len(rows)}")
    records = []
    for abbr, marker, en, ro, fr, de in rows:
        notes = []
        if abbr in SWAPPED_RO_FR:
            ro, fr = fr, ro
            notes.append("The book's Table 2 has the Romanian and French expansions of this row "
                         "in swapped columns; they are shown here in the right place.")
        forms = abbr.split()
        page_slug = QUALIFIED.get((abbr, marker)) or "abbr-" + slug(abbr)
        records.append({"abbr": abbr, "forms": forms, "marker": marker, "slug": page_slug,
                        "expansion": dict(zip(LANGS, (en, ro, fr, de))), "notes": notes,
                        "see": SEE.get(page_slug) or SEE.get(forms[0])})
    if len({r["slug"] for r in records}) != len(records):
        sys.exit("slug collision; extend QUALIFIED")

    by_letter = defaultdict(list)
    for r in records:
        by_letter[r["abbr"][0].upper()].append(r)

    changed = 0
    for r in records:
        exp = r["expansion"]
        category = CATEGORY.get(r["marker"], "general")
        meta = {
            "id": f"entities/abbreviations/{r['slug']}",
            "type": "abbreviation",
            "title": {lang: f"{r['abbr']} — {exp[lang]}" for lang in LANGS},
            "abbr": r["abbr"],
            "forms": r["forms"],
            "marker": r["marker"],
            "category": category,
            "expansion": exp,
            "summary": f"{r['abbr']}: {exp['en']}.",
        }
        if r["see"]:
            meta["see"] = f"[[{r['see']}]]"
        meta["related"] = [f"[[{o['slug']}]]" for o in by_letter[r["abbr"][0].upper()] if o is not r]
        meta["status"] = "draft"
        letter = r["abbr"][0].upper()
        others = ", ".join(f"[[{o['slug']}|{o['abbr']}]]" for o in by_letter[letter] if o is not r)
        body = [f"# {r['abbr']}", "", f"**{exp['en']}** ({category}).", "",
                "| Română | Français | Deutsch |", "|---|---|---|",
                f"| {exp['ro']} | {exp['fr']} | {exp['de']} |", ""]
        if r["see"]:
            body += [f"See [[{r['see']}]].", ""]
        body += r["notes"] + ([""] if r["notes"] else [])
        body += [f"Other abbreviations starting with {letter}: {others or '—'}.", "",
                 "All abbreviations: [[../abbreviations/README|index]]. Source: [[../../meta/glossary|Glossary, Table 2]]."]
        try:
            changed += write_generated(OUT / f"{r['slug']}.md", meta, "\n".join(body), GENERATOR)
        except HandOwnedPage as e:
            print(f"skipped: {e}")

    index = ["# Abbreviations", "",
             f"All {len(records)} abbreviations of the book's Table 2, by first letter. "
             "Source: [[../../meta/glossary|Glossary, Table 2]].", ""]
    for letter in sorted(by_letter):
        index += [f"## {letter}", "", "| Abbreviation | Meaning | Category |", "|---|---|---|"]
        index += [f"| [[{r['slug']}\\|{r['abbr']}]] | {r['expansion']['en']} | "
                  f"{CATEGORY.get(r['marker'], 'general')} |" for r in by_letter[letter]]
        index.append("")
    meta = {"id": "entities/abbreviations/README", "type": "index",
            "title": {"en": "Abbreviations", "ro": "Abrevieri", "fr": "Abréviations", "de": "Abkürzungen"}}
    try:
        changed += write_generated(OUT / "README.md", meta, "\n".join(index), GENERATOR)
    except HandOwnedPage as e:
        print(f"skipped: {e}")
    print(f"{len(records)} abbreviation pages + index, {changed} changed")


if __name__ == "__main__":
    main()
