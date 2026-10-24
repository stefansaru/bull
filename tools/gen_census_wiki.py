#!/usr/bin/env python3
"""
gen_census_wiki.py -- Generate reference pages + the postmark census in the wiki.

Reads work/census/{postmarks,lots,summary}.json and writes:
  wiki/entities/references/auctions/<catalogue>.md  one page per auction catalogue (postmarks + lots)
  wiki/entities/references/auctions/README.md       the auction catalogue index (ref_type: auction, DR-014)
  wiki/entities/postmarks/census.md          the Bull's Head postmark census (tables)
  wiki/entities/postmarks/data/*.csv/json    the raw census data (for querying)

Usage: python gen_census_wiki.py work/census wiki
"""
import sys, os, re, json, shutil
from collections import Counter, defaultdict

HOUSE_PAGE = {"Corinphila": "corinphila", "David Feldman": "david-feldman"}
HOUSE = {"corinphila": "Corinphila", "david-feldman": "David Feldman",
         "feldman": "David Feldman", "international": "David Feldman"}


def cat_meta(slug):
    m = re.match(r"(\d{4})-([a-z-]+?)-(.*)", slug)
    year = m.group(1) if m else ""
    house = ""
    for k, v in HOUSE.items():
        if k in slug:
            house = v
            break
    sale = ""
    sm = re.search(r"\b(\d{2,3})\b", slug[5:])
    if sm:
        sale = sm.group(1)
    title = slug
    return {"year": year, "house": house or "?", "sale": sale, "slug": slug,
            "title": re.sub(r"-", " ", slug)}


def esc(s):
    return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'


def cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ").strip()


def main():
    indir, vault = sys.argv[1], sys.argv[2]
    postmarks = json.load(open(os.path.join(indir, "postmarks.json"), encoding="utf-8"))
    lots = json.load(open(os.path.join(indir, "lots.json"), encoding="utf-8"))
    summary = json.load(open(os.path.join(indir, "summary.json"), encoding="utf-8"))

    refdir = os.path.join(vault, "entities", "references", "auctions")
    pmdir = os.path.join(vault, "entities", "postmarks")
    datadir = os.path.join(pmdir, "data")
    os.makedirs(refdir, exist_ok=True)
    os.makedirs(datadir, exist_ok=True)
    for fn in ("postmarks.csv", "postmarks.json", "lots.json", "summary.json"):
        src = os.path.join(indir, fn)
        if os.path.exists(src):
            shutil.copy(src, os.path.join(datadir, fn))

    # group by catalogue
    by_cat_pm = defaultdict(list)
    by_cat_lot = defaultdict(list)
    for p in postmarks:
        by_cat_pm[p["catalogue"]].append(p)
    for l in lots:
        by_cat_lot[l["catalogue"]].append(l)
    cats = sorted(set(list(by_cat_pm) + list(by_cat_lot)))

    # ---- per-catalogue reference pages ----
    index_rows = []
    for slug in cats:
        meta = cat_meta(slug)
        pms = by_cat_pm.get(slug, [])
        lts = by_cat_lot.get(slug, [])
        pages = sorted(set(p["page"] for p in pms) | set(l["page"] for l in lts))
        bh = [p for p in pms if p["on_bulls_head"]]
        fm = ["---", f"id: entities/references/auctions/{slug}", "type: reference",
              "ref_type: auction",
              f"title: {{en: {esc(meta['title'])}}}",
              f"house: {esc(meta['house'])}", f"year: {meta['year'] or 'null'}",
              f"sale: {esc(meta['sale'])}",
              f"source_file: {esc('input/catalogues/' + slug + '.pdf')}",
              f"bulls_head_lots: {len(lts)}", f"postmark_occurrences: {len(pms)}",
              "status: verified", "---", ""]
        body = [f"# {meta['house']} — {meta['year']} (sale {meta['sale']})",
                "",
                f"> Auction catalogue. Source: `input/catalogues/{slug}.pdf`. "
                f"Contains **{len(lts)} Bull's Head lot-mentions** and "
                f"**{len(pms)} postmark occurrences** ({len(bh)} on Bull's Head adhesives) "
                f"across pages {', '.join(map(str, pages[:20]))}"
                + (" …" if len(pages) > 20 else "") + ".",
                "",
                "Bibliographic reference for [[census|the postmark census]]. Cited claims "
                "backed by this catalogue link here (DR-007)."
                + (f" Auction house: [[../web/{HOUSE_PAGE[meta['house']]}|{meta['house']}]]."
                   if meta["house"] in HOUSE_PAGE else ""), ""]
        if bh:
            body += ["## Bull's Head postmarks in this catalogue", "",
                     "| Issue | Denom | Marking | Type | Colour | Date | Kiriac | Pg |",
                     "|---|---|---|---|---|---|---|---|"]
            for p in sorted(bh, key=lambda x: (x["issue"], x["denomination"] or 0)):
                body.append("| " + " | ".join(cell(x) for x in [
                    p["issue"], f"{p['denomination']}pa", p["marking"], p["type"],
                    p["color"], p["date"], p["kiriac_fig"], p["page"]]) + " |")
            body.append("")
        if lts:
            # Lots live inside their auction page (DR-014); bulls-head-lots compiles the notable ones.
            body += ["## Bull's Head lots in this catalogue", "",
                     "| Pg | Issue | Denom | On cover | Certificates | Description |",
                     "|---|---|---|---|---|---|"]
            for l in sorted(lts, key=lambda x: (x["page"], x["issue"] or "", x["denomination"] or 0)):
                text = l.get("text", "")
                body.append("| " + " | ".join(cell(x) for x in [
                    l["page"], l["issue"] or "", f"{l['denomination']}pa" if l["denomination"] else "",
                    "yes" if l.get("on_cover") else "", ", ".join(f"{c.get('expert', '')} {c.get('year', '')}".strip() if isinstance(c, dict) else str(c) for c in l.get("certs") or []),
                    text[:160] + ("…" if len(text) > 160 else "")]) + " |")
            body.append("")
        open(os.path.join(refdir, slug + ".md"), "w", encoding="utf-8").write(
            "\n".join(fm + body))
        index_rows.append((meta, len(lts), len(pms), len(bh)))

    # ---- references index ----
    idx = ["---", "id: entities/references/auctions/README", "type: reference",
           "ref_type: auction",
           "title: {en: Auction catalogues}", "status: living", "---", "",
           "# Auction catalogues", "",
           "Part of the [[../README|references]] (DR-014).", "",
           "Auction catalogues ingested as sources for the Bull's Head "
           "[[../../postmarks/census|postmark census]]. Each links to its own page with the "
           "lots/postmarks it contributes. Extracted mechanically from the PDFs' text "
           "layer; see the census page for method & caveats.", "",
           "| Catalogue | House | Year | Sale | BH lots | Postmarks (on BH) |",
           "|---|---|---|---|---|---|"]
    for meta, nl, npm, nbh in sorted(index_rows, key=lambda x: x[0]["year"]):
        idx.append(f"| [[{meta['slug']}]] | {meta['house']} | {meta['year']} | "
                   f"{meta['sale']} | {nl} | {npm} ({nbh}) |")
    idx += ["", "## Coverage notes",
            "- **`2006-david-feldman-classic-romania`** was fully scanned (no text layer); "
            "**now OCR'd** (`tools/pdf_ocr.py`, RapidOCR) and mined — a whole specialist "
            "Romania sale recovered.",
            "- **`2024-corinphila-329-erivan`, `2024-corinphila-321`, "
            "`2021-corinphila-260-provera`** have text layers but **no Bull's Head content** "
            "(not omitted — genuinely absent).",
            "- The **Sperati** sales (forgery references) contain only sparse Romania mentions; "
            "worth a targeted read for the forgery chapter rather than the postmark census.", ""]
    open(os.path.join(refdir, "README.md"), "w", encoding="utf-8").write("\n".join(idx))

    # ---- postmark census ----
    bh = [p for p in postmarks if p["on_bulls_head"]]
    # marking -> kiriac figs + count + issues
    mk = defaultdict(lambda: {"figs": set(), "n": 0, "issues": set(), "colors": set()})
    for p in postmarks:
        if not p["marking"]:
            continue
        key = p["marking"].upper()
        mk[key]["figs"].add(p["kiriac_fig"])
        mk[key]["n"] += 1
        if p["issue"]:
            mk[key]["issues"].add(p["issue"])
        if p["color"]:
            mk[key]["colors"].add(p["color"])

    c = ["---", "id: entities/postmarks/census", "type: reference",
         "title: {en: Auction postmark census (Bull's Head & Moldavia-Wallachia)}",
         "status: verified",
         f"postmark_occurrences: {summary['postmark_occurrences']}",
         f"on_bulls_head: {summary['on_bulls_head']}",
         f"unique_kiriac_figs: {summary['unique_kiriac_figs']}", "---", "",
         "# Auction postmark census", "",
         "> Every postmark/marking identified on Moldavia–Wallachia material across the "
         "ingested [[../references/auctions/README|auction catalogues]], anchored on the **Kiriac "
         "(Dragomir) figure number** — the field's public postmark identifier "
         "([[../../strategy/market-research]]). Use this to build the "
         "[[../handstamps/PM52|PM52]]/[[../handstamps/M1|M1]]… → Kiriac concordance the "
         "book still needs.", "",
         "> **Companion:** [[kiriac-figures]] catalogues the *devices* themselves (from the "
         "Kiriac 1974 catalogue) — type, towns, dimensions, ink, period. Note the auction "
         "`Kiriac fig.` numbers below are from the **1990 *Ștampilografie***, a different "
         "numbering of the same devices; map by device + town. e.g. auction "
         "\"JASSY / MOLDOVA\" red = the B.1 *MOLDOVA* Iași datestamp (Kiriac-1974 Fig. 40-54), "
         "red-carmine used only 28 Aug–18 Oct 1858.", "",
         f"**{summary['postmark_occurrences']} occurrences** · "
         f"**{summary['on_bulls_head']} on Bull's Head adhesives** · "
         f"**{summary['unique_kiriac_figs']} unique Kiriac figures** · "
         f"**{summary['unique_markings']} distinct markings**. "
         "Raw data: [`data/postmarks.csv`](data/postmarks.csv).", "",
         "## Method & caveats", "",
         "- Extracted from the PDF text layer by `tools/census.py`, anchored on "
         "`(Kiriac fig. N)` and quoted markings with cancellation context.",
         "- `on Bull's Head` = the marking sits within a lot that also names a parale "
         "denomination (issue I 27/54/81/108; issue II 5/40/80).",
         "- Town spellings are the catalogues' period/German transliterations (Jassy=Iași, "
         "Bakeu=Bacău, Waslui=Vaslui, Berlad=Bârlad, Tekutsch=Tecuci, Foltitscheni=Fălticeni).",
         "- Mechanical extraction: verify against the source page before citing a specific "
         "claim (DR-007). Feldman catalogues are under-represented (scanned text).", "",
         "## Bull's Head postmark occurrences", "",
         "`Src`: `kiriac` = anchored on a cited Kiriac figure; `desc` = parsed from a "
         "cancellation description (no Kiriac number, e.g. Feldman).", "",
         "| Issue | Denom | Marking | Type | Colour | Date | Kiriac | Src | Catalogue | Pg |",
         "|---|---|---|---|---|---|---|---|---|---|"]
    for p in sorted(bh, key=lambda x: (x["issue"], x["denomination"] or 0, x["kiriac_fig"], x["marking"])):
        c.append("| " + " | ".join(cell(x) for x in [
            p["issue"], f"{p['denomination']}pa", p["marking"], p["type"], p["color"],
            p["date"], p["kiriac_fig"], p.get("source", ""),
            cat_meta(p["catalogue"])["house"] + " " + cat_meta(p["catalogue"])["year"],
            p["page"]]) + " |")
    # Kiriac figure -> marking(s) concordance (supports PM52/M1 -> Kiriac mapping)
    fig_map = defaultdict(lambda: {"marks": Counter(), "types": set(), "n": 0})
    for p in postmarks:
        f = p["kiriac_fig"]
        if not f:
            continue
        fig_map[f]["n"] += 1
        if p["marking"]:
            fig_map[f]["marks"][p["marking"].upper()] += 1
        if p["type"]:
            fig_map[f]["types"].add(p["type"])
    c += ["", "## Kiriac figure concordance", "",
          "Reverse index — each Kiriac (Dragomir) figure number → the marking(s) it "
          "labels across the catalogues. This is the spine for mapping the book's "
          "[[../handstamps/PM52|PM52]]/[[../handstamps/M1|M1]]/[[../handstamps/M2|M2]]/"
          "[[../handstamps/M3|M3]]/[[../handstamps/C1|C1]] codes to the public system.", "",
          "| Kiriac fig | Marking(s) | Type(s) | Occurrences |",
          "|---|---|---|---|"]
    for f in sorted(fig_map, key=lambda x: int(re.sub(r"\D", "", x) or 0)):
        d = fig_map[f]
        marks = "; ".join(f"{m} ({n})" for m, n in d["marks"].most_common(3))
        c.append(f"| {cell(f)} | {cell(marks)} | {', '.join(sorted(t for t in d['types'] if t))} | {d['n']} |")

    c += ["", "## All markings (Bull's Head + pre-philatelic postal history)", "",
          "| Marking | Kiriac fig(s) | Issues | Colours | Occurrences |",
          "|---|---|---|---|---|"]
    for name, d in sorted(mk.items(), key=lambda x: -x[1]["n"]):
        figs = ", ".join(sorted(f for f in d["figs"] if f))
        c.append(f"| {cell(name)} | {figs} | {', '.join(sorted(d['issues']))} | "
                 f"{', '.join(sorted(d['colors']))} | {d['n']} |")
    c.append("")
    os.makedirs(pmdir, exist_ok=True)
    open(os.path.join(pmdir, "census.md"), "w", encoding="utf-8").write("\n".join(c))

    print(f"wrote {len(cats)} reference pages + index -> {refdir}")
    print(f"wrote postmark census ({len(bh)} BH rows, {len(mk)} markings) -> {pmdir}/census.md")


if __name__ == "__main__":
    main()
