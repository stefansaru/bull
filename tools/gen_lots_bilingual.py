#!/usr/bin/env python3
"""
gen_lots_bilingual.py -- Bilingual (EN/RO) page of notable Bull's Head auction lots.

Input: work/census/lots_bilingual.json ({catalogue,page,issue,denomination,en,ro}).
Output: wiki/entities/references/bulls-head-lots.md — grouped by issue/denomination,
each lot showing its English description and Romanian translation. Cross-links to the
census. This is the catalogue-side counterpart of the Kiriac source translation (DR-012).

Usage: python gen_lots_bilingual.py work/census/lots_bilingual.json wiki
"""
import sys, os, json, re
from collections import defaultdict


def house_year(slug):
    y = re.match(r"(\d{4})", slug or "")
    h = "Corinphila" if "corinphila" in (slug or "") else "David Feldman" if "feldman" in (slug or "") else ""
    return f"{h} {y.group(1) if y else ''}".strip()


def main():
    src, vault = sys.argv[1], sys.argv[2]
    lots = json.load(open(src, encoding="utf-8"))
    groups = defaultdict(list)
    for l in lots:
        groups[(l.get("issue", "?"), l.get("denomination") or 0)].append(l)

    out = ["---", "id: entities/references/bulls-head-lots", "type: reference",
           "title:", "  en: Notable Bull's Head auction lots (EN / RO)",
           "  ro: Loturi notabile Cap de bour la licitație (EN / RO)",
           "status: draft", f"lot_count: {len(lots)}", "---", "",
           "# Notable Bull's Head auction lots — bilingual (EN / RO)", "",
           "> Substantive Bull's Head lot descriptions from the [[README|auction catalogues]], "
           "translated to Romanian ([[../../meta/decisions/DR-012-source-translations|DR-012]]). "
           "English is the catalogue original (cleaned); Romanian is the translation. "
           "See the [[../postmarks/census|postmark census]] for the structured data.", "",
           f"**{len(lots)} lots.**", ""]

    for (issue, denom) in sorted(groups, key=lambda k: (k[0], k[1])):
        out.append(f"## Issue {issue} — {denom} parale")
        out.append("")
        for l in groups[(issue, denom)]:
            hy = house_year(l.get("catalogue", ""))
            out.append(f"**{hy}, p.{l.get('page','?')}**")
            out.append("")
            out.append(f"- 🇬🇧 {l.get('en','').strip()}")
            out.append(f"- 🇷🇴 {l.get('ro','').strip()}")
            out.append("")
    os.makedirs(os.path.join(vault, "entities", "references"), exist_ok=True)
    open(os.path.join(vault, "entities", "references", "bulls-head-lots.md"),
         "w", encoding="utf-8").write("\n".join(out))
    print(f"wrote entities/references/bulls-head-lots.md ({len(lots)} lots, "
          f"{len(groups)} issue/denomination groups)")


if __name__ == "__main__":
    main()
