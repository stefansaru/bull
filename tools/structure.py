#!/usr/bin/env python3
"""
structure.py -- Group the flat document_model into sections + content units.

Consumes work/extract/document_model.json (from extract.py) and produces
work/extract/sections.json: an ordered list of SECTIONS, each delimited by a
heading, carrying a 4-language title and a list of ordered UNITS.

Unit kinds:
  - quad   : a 4-language content unit {en, ro, fr, de} (+ optional images)
  - text   : a single-language loose paragraph {lang, text}
  - figure : an image {targets:[media], caption}
  - table  : a genuine reference table {rows, caption}

The 4-language content in the book is encoded two ways (both handled):
  A) one 2x2 table  -> already {en,ro,fr,de}      (extract.py 'quad')
  B) two consecutive 1x2 tables: [EN,RO] then [FR,DE], sometimes with a
     figure/caption between them                  (extract.py 'table')
Plus edge cases: inline 4-lang cells "A | B | C | D", groups of 4 single-lang
tables, image-only spacer tables. Everything keeps a raw fallback so nothing is
lost; provenance is the source block indices.

Usage: python structure.py work/extract
"""
import sys, os, json, re
sys.path.insert(0, os.path.dirname(__file__))
from lang import guess

MARKERS = "📅💰🧭📯🐃🦬🦅🌸⭐🌙🔍📰🧻🌍💰⬆⬇⏭✍📜🎨∅📖⨀🆁✉△✂🔍"


def markers_in(text):
    return [ch for ch in text if ch in MARKERS]


def is_ref_table(tbl):
    """Genuine reference/data table: has a 'Table N' caption cell or >2 columns."""
    rows = tbl["rows"]
    ncells = tbl.get("ncells", [])
    if rows and rows[0] and re.match(r"\s*Table\s+\d+", rows[0][0]):
        return True
    if any(n >= 3 for n in ncells):
        return True
    return False


def split_inline_4lang(cell):
    """"A | B | C | D" -> (en,ro,fr,de) if it looks like a 4-part pipe string."""
    parts = [p.strip() for p in cell.split("|")]
    if len(parts) == 4:
        return parts
    return None


def lang_of_pair(tbl):
    """For a 1-row 2-cell table, return ('en','ro')/('fr','de')/... via guesser."""
    c0, c1 = tbl["rows"][0]
    return guess(c0), guess(c1)


def build_units(blocks):
    """Walk blocks, emit sections. blocks carry their original index in 'idx'."""
    sections = []
    cur = None

    def new_section(title_en, level, style, idx):
        return {"title": {"en": title_en, "ro": "", "fr": "", "de": ""},
                "level": level, "style": style, "order": len(sections),
                "markers": markers_in(title_en), "source_blocks": [idx],
                "units": []}

    i = 0
    n = len(blocks)
    while i < n:
        b = blocks[i]
        idx = b["idx"]
        t = b["type"]

        if t == "heading":
            # front-matter H0 (Edition/Author/Date values) -> treat as title-page text
            cur = new_section(b["text"].strip(), b["level"], b.get("style"), idx)
            sections.append(cur)
            # a following "RO | FR | DE" para completes the multilingual title
            if i + 1 < n and blocks[i + 1]["type"] == "para" and " | " in blocks[i + 1]["text"]:
                parts = [p.strip() for p in blocks[i + 1]["text"].split("|")]
                if len(parts) == 3:
                    cur["title"]["ro"], cur["title"]["fr"], cur["title"]["de"] = parts
                    cur["source_blocks"].append(blocks[i + 1]["idx"])
                    i += 2
                    continue
            i += 1
            continue

        # ensure a section exists (pre-title content -> a synthetic front section)
        if cur is None:
            cur = new_section("(front matter)", 0, None, idx)
            sections.append(cur)

        if t == "quad":
            u = {"kind": "quad", "en": b.get("en", ""), "ro": b.get("ro", ""),
                 "fr": b.get("fr", ""), "de": b.get("de", ""),
                 "images": b.get("images", []), "source_blocks": [idx]}
            if b.get("singles"):
                u["singles"] = b["singles"]
            cur["units"].append(u)
            cur["source_blocks"].append(idx)
            i += 1
            continue

        if t == "image":
            cur["units"].append({"kind": "figure", "targets": b["targets"],
                                 "caption": b.get("caption", ""), "source_blocks": [idx]})
            cur["source_blocks"].append(idx)
            i += 1
            continue

        if t == "para":
            txt = b["text"].strip()
            # a "Figure N: ..." line is a caption; attach to the previous figure if any
            if cur["units"] and cur["units"][-1]["kind"] == "figure" and re.match(r"\s*(Figure|Figura|Abbildung)\s+\d+", txt):
                if not cur["units"][-1].get("caption"):
                    cur["units"][-1]["caption"] = txt
                cur["source_blocks"].append(idx)
                i += 1
                continue
            cur["units"].append({"kind": "text", "lang": guess(txt), "text": txt,
                                 "source_blocks": [idx]})
            cur["source_blocks"].append(idx)
            i += 1
            continue

        if t == "table":
            # genuine reference table?
            if is_ref_table(b):
                cap = ""
                if b["rows"] and b["rows"][0] and re.match(r"\s*Table\s+\d+", b["rows"][0][0]):
                    cap = b["rows"][0][0].strip()
                cur["units"].append({"kind": "table", "rows": b["rows"], "caption": cap,
                                     "images": b.get("flat_images", []), "source_blocks": [idx]})
                cur["source_blocks"].append(idx)
                i += 1
                continue
            # 1-row 2-cell language half?
            if b.get("ncells") == [2] and len(b["rows"]) == 1:
                c0, c1 = b["rows"][0]
                inline = split_inline_4lang(c0) if not c1.strip() else None
                if inline:  # single cell holds all four "A | B | C | D"
                    en, ro, fr, de = inline
                    cur["units"].append({"kind": "quad", "en": en, "ro": ro, "fr": fr,
                                         "de": de, "images": b.get("flat_images", []),
                                         "source_blocks": [idx]})
                    cur["source_blocks"].append(idx)
                    i += 1
                    continue
                l0, l1 = guess(c0), guess(c1)
                # EN/RO half -> look ahead for the FR/DE half (skipping figures/captions)
                if (l0, l1) in (("en", "ro"),):
                    en, ro = c0, c1
                    between = []
                    j = i + 1
                    fr = de = ""
                    consumed = [idx]
                    while j < n:
                        bj = blocks[j]
                        if bj["type"] == "table" and bj.get("ncells") == [2] and len(bj["rows"]) == 1:
                            g0, g1 = guess(bj["rows"][0][0]), guess(bj["rows"][0][1])
                            if (g0, g1) in (("fr", "de"), ("de", "fr")):
                                fr, de = bj["rows"][0][0], bj["rows"][0][1]
                                if (g0, g1) == ("de", "fr"):
                                    fr, de = de, fr
                                consumed.append(bj["idx"])
                                j += 1
                                break
                            else:
                                break
                        elif bj["type"] in ("image", "para"):
                            between.append(bj)
                            j += 1
                        else:
                            break
                    u = {"kind": "quad", "en": en, "ro": ro, "fr": fr, "de": de,
                         "images": b.get("flat_images", []), "source_blocks": consumed}
                    cur["units"].append(u)
                    # emit the in-between figures/captions as their own units
                    for bj in between:
                        if bj["type"] == "image":
                            cur["units"].append({"kind": "figure", "targets": bj["targets"],
                                                 "caption": bj.get("caption", ""),
                                                 "source_blocks": [bj["idx"]]})
                        else:
                            txt = bj["text"].strip()
                            # a "Figure N:" caption attaches to the preceding figure
                            if (cur["units"] and cur["units"][-1]["kind"] == "figure"
                                    and not cur["units"][-1].get("caption")
                                    and re.match(r"\s*(Figure|Figura|Abbildung)\s+\d+", txt)):
                                cur["units"][-1]["caption"] = txt
                            else:
                                cur["units"].append({"kind": "text", "lang": guess(txt),
                                                     "text": txt, "source_blocks": [bj["idx"]]})
                        consumed.append(bj["idx"])
                    cur["source_blocks"].extend(consumed)
                    i = j
                    continue
                # any other 1x2 (same-lang split, ?/?, leftover fr/de) -> raw 2-col unit
                cur["units"].append({"kind": "table", "rows": b["rows"], "caption": "",
                                     "raw2col": True, "langs": [l0, l1],
                                     "images": b.get("flat_images", []), "source_blocks": [idx]})
                cur["source_blocks"].append(idx)
                i += 1
                continue
            # fallback: keep table as-is
            cur["units"].append({"kind": "table", "rows": b["rows"], "caption": "",
                                 "images": b.get("flat_images", []), "source_blocks": [idx]})
            cur["source_blocks"].append(idx)
            i += 1
            continue

        i += 1

    return sections


def main():
    outdir = sys.argv[1] if len(sys.argv) > 1 else "work/extract"
    dm = json.load(open(os.path.join(outdir, "document_model.json"), encoding="utf-8"))
    blocks = dm["blocks"]
    for k, b in enumerate(blocks):
        b["idx"] = k
    sections = build_units(blocks)

    # stats
    from collections import Counter
    ukinds = Counter(u["kind"] for s in sections for u in s["units"])
    covered = set()
    for s in sections:
        covered.update(s["source_blocks"])
        for u in s["units"]:
            covered.update(u["source_blocks"])
    all_idx = set(range(len(blocks)))
    orphans = sorted(all_idx - covered)

    out = {"section_count": len(sections), "unit_kinds": dict(ukinds),
           "blocks_total": len(blocks), "blocks_covered": len(covered),
           "orphan_blocks": orphans, "sections": sections}
    json.dump(out, open(os.path.join(outdir, "sections.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print("sections:", len(sections), "| unit kinds:", dict(ukinds))
    print(f"coverage: {len(covered)}/{len(blocks)} blocks | orphans: {len(orphans)}")
    if orphans[:20]:
        print("first orphans:", orphans[:20])


if __name__ == "__main__":
    main()
