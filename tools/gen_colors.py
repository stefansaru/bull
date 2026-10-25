#!/usr/bin/env python3
"""
gen_colors.py -- Generate wiki/entities/colors/<slug>.md, one page per colour of the
book's "🎨 Colors" chapter (UIC-DAT-02).

Inputs:
  wiki/narrative/25-colors/0NN-*.md   the colour sections (4-language titles)
  work/extract/swatches.json          swatch cells with the author's shading
                                      (run tools/extract_swatches.py first)

Each swatch keeps the standard's own code as the authority and the author's cell
shading as `hex`, a screen approximation (bull DR-015, owner ruling 2026-10-25).
Pages carry `generated_by`; remove that key to take a page over by hand.

Usage: python tools/gen_colors.py
"""
import json
import re
import sys

from wikilib import WIKI, REPO, HandOwnedPage, read_page, slug, write_generated

GENERATOR = "tools/gen_colors.py"
NARRATIVE = WIKI / "narrative" / "25-colors"
OUT = WIKI / "entities" / "colors"
SWATCHES = REPO / "work" / "extract" / "swatches.json"
LANGS = ["en", "ro", "fr", "de"]

FAMILY_WORDS = {"blue": "blue", "blueish": "blue", "green": "green", "greenish": "green",
                "red": "red", "rose": "red", "black": "neutral", "white": "neutral"}
FAMILY_LABEL = {"blue": "blues", "green": "greens", "red": "reds", "neutral": "neutrals"}

STANDARD = [
    ("pantone", re.compile(r"^Pantone\s+(?P<code>P\s+\d+-\d+\s+C|\d+(?:\s+[CU](?=\s|$))?)\s*(?P<name>.*)$")),
    ("ral", re.compile(r"^RAL\s+(?P<code>\d{3}\s+\d{2}\s+\d{2}|\d{4})\s*(?P<name>.*)$")),
    ("ams-std", re.compile(r"^AMS-STD\s+(?P<code>\d+)\s*(?P<name>.*)$")),
    ("ams", re.compile(r"^AMS\s+(?P<code>\d+)\s*(?P<name>.*)$")),
    ("ncs", re.compile(r"^(?P<code>S\s+\d{4}-[A-Z]\d*[A-Z]?)\s*(?P<name>.*)$")),
]
SYSTEM_LABEL = {"pantone": "Pantone", "ral": "RAL", "ams": "AMS", "ams-std": "AMS-STD",
                "ncs": "NCS", "web": "Web colour", "other": ""}
WEB_COLOURS = {"mistyrose": "MistyRose"}


def parse_standard(text, description):
    for system, rx in STANDARD:
        m = rx.match(text)
        if m:
            entry = {"system": system, "code": m.group("code"), "name": m.group("name").strip()}
            break
    else:
        key = text.replace(" ", "").lower()
        if key in WEB_COLOURS:
            entry = {"system": "web", "code": WEB_COLOURS[key], "name": ""}
        else:
            entry = {"system": "other", "code": text, "name": ""}
    # "AMS-STD 37925 / Insignia White": the second line is a name, not a description.
    if description and not description.lower().startswith("a "):
        entry["name"] = entry["name"] or description
        description = ""
    entry["description"] = description
    return entry


def label(sw):
    return " ".join(p for p in (SYSTEM_LABEL[sw["system"]], sw["code"]) if p)


def main():
    if not SWATCHES.exists():
        sys.exit(f"{SWATCHES} missing; run tools/extract_swatches.py first")
    colours = json.loads(SWATCHES.read_text(encoding="utf-8"))["colours"]
    pages = sorted(p for p in NARRATIVE.glob("0*.md") if re.match(r"0(0[3-9]|1\d|2[0-4])-", p.name))
    if len(pages) != len(colours):
        sys.exit(f"{len(pages)} colour sections but {len(colours)} swatch groups")

    records = []
    for page, colour in zip(pages, colours):
        meta, _ = read_page(page)
        heading = str(meta["title"]["en"]).replace("🎨", "").strip()
        if heading != colour["heading"].replace("🎨", "").strip():
            sys.exit(f"order mismatch: {page.name} vs {colour['heading']}")
        names = [n.strip() for n in heading.split("|")]
        en = names[0]
        family = FAMILY_WORDS[en.split()[-1].lower()]
        swatches = []
        for sw in colour["swatches"]:
            entry = parse_standard(sw["standard"], sw["description"])
            entry["hex"] = "#" + sw["hex"]
            swatches.append(entry)
        records.append({"slug": slug(en), "names": names, "en": en, "family": family,
                        "swatches": swatches, "page": page})

    changed = 0
    for r in records:
        same_family = [o for o in records if o["family"] == r["family"] and o is not r]
        codes = [label(s) for s in r["swatches"]]
        summary = f"{r['en']} — matched in the book to " + (
            ", ".join(codes[:-1]) + " and " + codes[-1] if len(codes) > 1 else codes[0]) + "."
        meta = {
            "id": f"entities/colors/{r['slug']}",
            "type": "color",
            "title": {lang: name for lang, name in zip(LANGS, r["names"])},
            "family": r["family"],
            "hex": r["swatches"][0]["hex"],
            "summary": summary,
            "swatches": r["swatches"],
            "hex_source": "author's book, colour table cell shading (screen approximation; "
                          "the standard's code is authoritative)",
            "related": [f"[[{o['slug']}]]" for o in same_family],
            "narrative_refs": [f"[[../../narrative/25-colors/{r['page'].stem}]]"],
            "status": "draft",
        }
        rows = "\n".join(
            f"| {label(s)} | {s['name']} | `{s['hex']}` | {s['description']} |" for s in r["swatches"])
        body = (f"# 🎨 {r['en']}\n\n{summary}\n\n"
                f"| Standard | Name | Screen colour | Description |\n|---|---|---|---|\n{rows}\n\n"
                f"The hex values reproduce the shading of the author's colour table; screens show "
                f"them only approximately. Other {FAMILY_LABEL[r['family']]}: "
                + ", ".join(f"[[{o['slug']}|{o['en']}]]" for o in same_family) + ".\n")
        try:
            changed += write_generated(OUT / f"{r['slug']}.md", meta, body, GENERATOR)
        except HandOwnedPage as e:
            print(f"skipped: {e}")
    print(f"{len(records)} colour pages, {changed} changed")


if __name__ == "__main__":
    main()
