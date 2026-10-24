#!/usr/bin/env python3
"""
gen_kiriac_concepts.py -- Concept stage: turn structured Kiriac Ch.I postmark
records (derived from the raw source) into a wiki concept page.

Input: a JSON array of postmark-group records (from the concept-derivation pass over
sources/kiriac-1974/chapter-1-postmarks-1858.md). Output: a concept page
entities/postmarks/kiriac-figures.md that catalogues Kiriac figure -> type / towns /
dimensions / ink / period, each citing the Kiriac page (DR-007), cross-linked to the
auction [[census]] and the handstamp entities.

Usage: python gen_kiriac_concepts.py <records.json> wiki
"""
import sys, os, json


def cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ").strip()


def towns_str(towns):
    out = []
    for t in towns or []:
        if isinstance(t, dict):
            m = t.get("town_modern") or t.get("town_raw") or ""
            out.append(m)
        else:
            out.append(str(t))
    return ", ".join(x for x in out if x)


def main():
    recsfile, vault = sys.argv[1], sys.argv[2]
    records = json.load(open(recsfile, encoding="utf-8"))
    pmdir = os.path.join(vault, "entities", "postmarks")
    os.makedirs(pmdir, exist_ok=True)

    # sort by first figure number
    def figkey(r):
        f = str(r.get("kiriac_figures", ""))
        import re
        m = re.search(r"\d+", f)
        return int(m.group()) if m else 9999
    records.sort(key=figkey)

    hi = [r for r in records if r.get("relevance_to_bulls_head") == "high"]
    all_pages = sorted({p for r in records for p in (r.get("pdf_pages") or [])})

    out = ["---", "id: entities/postmarks/kiriac-figures", "type: reference",
           "title: {en: Kiriac figure catalogue — classic postmarks 1858}",
           "status: draft",
           "refs: [\"[[../references/catalogues/kiriac-1974]]\"]",
           f"derived_from: \"[[../../sources/kiriac-1974/chapter-1-postmarks-1858]]\"",
           f"record_count: {len(records)}", "---", "",
           "# Kiriac figure catalogue — classic postmarks (1858)",
           "",
           "> **Concept stage** ([[../../meta/decisions/DR-011-raw-source-ingestion-stage|DR-011]]): "
           "structured from the raw [[../../sources/kiriac-1974/chapter-1-postmarks-1858|Kiriac 1974 Chapter I]] "
           "text — each Kiriac figure → marking type, towns, dimensions, ink, period. "
           "Romanian diacritics restored from context; every row cites its Kiriac pdf page "
           "([[../references/catalogues/kiriac-1974]], DR-007). `status: draft` until verified against "
           "the source images.",
           "",
           "This is the authoritative spine for the [[census|auction postmark census]] "
           "and for the [[../handstamps/PM52|PM52]]/[[../handstamps/M1|M1]]/[[../handstamps/M2|M2]]/"
           "[[../handstamps/M3|M3]]/[[../handstamps/C1|C1]] → Kiriac concordance.",
           "",
           "> ⚠ **Two Kiriac numbering systems — do not conflate.** The figure numbers here "
           "are from the **1974 catalogue, Chapter I** (Fig. 37–119). The `Kiriac fig. 271–313` "
           "numbers cited in the auction [[census]] are from Dragomir's later "
           "***Ștampilografie poștală* (1990)** — a *different* numbering of the **same devices**. "
           "Map the two by **device type + town** (e.g. the B.1 round *MOLDOVA* Iași datestamp "
           "here = the auction \"JASSY / MOLDOVA\" = *Ștampilografie* fig. 279), not by figure "
           "number. Confirm against the 1990 work when available.",
           "",
           f"**{len(records)} marking groups** derived from Kiriac pdf pages "
           f"{min(all_pages) if all_pages else '?'}–{max(all_pages) if all_pages else '?'}. "
           f"**{len(hi)}** are directly relevant to cancelling the 1858 Bull's Head stamps.",
           ""]

    def table(rows, title):
        b = [f"## {title}", "",
             "| Kiriac fig | Type (RO / EN) | Region | Dims (mm) | Towns | Ink | Period | Kiriac p. |",
             "|---|---|---|---|---|---|---|---|"]
        for r in rows:
            b.append("| " + " | ".join(cell(x) for x in [
                r.get("kiriac_figures", ""),
                (r.get("type_code", "") + " " + r.get("type_name", "")).strip(),
                r.get("region", ""),
                r.get("dimensions_mm", ""),
                towns_str(r.get("towns")),
                ", ".join(r.get("ink_colors", []) if isinstance(r.get("ink_colors"), list) else [r.get("ink_colors", "")]),
                r.get("period", ""),
                ", ".join(str(p) for p in (r.get("pdf_pages") or [])),
            ]) + " |")
        b.append("")
        return b

    out += table(hi, "Postmarks used on the 1858 Bull's Head (high relevance)")
    rest = [r for r in records if r not in hi]
    if rest:
        out += table(rest, "Other classic markings (Moldavia / Wallachia postal history)")

    # notes section for records that carry notes
    noted = [r for r in records if r.get("notes")]
    if noted:
        out += ["## Notes", ""]
        for r in noted:
            out.append(f"- **Fig. {cell(r.get('kiriac_figures',''))}** "
                       f"({cell(r.get('type_name',''))}): {cell(r['notes'])}")
        out.append("")

    open(os.path.join(pmdir, "kiriac-figures.md"), "w", encoding="utf-8").write("\n".join(out))
    print(f"wrote {pmdir}/kiriac-figures.md ({len(records)} records, {len(hi)} high-relevance)")


if __name__ == "__main__":
    main()
