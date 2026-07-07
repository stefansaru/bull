#!/usr/bin/env python3
"""
pdf_scan.py -- Extract & cache text from the auction catalogues, size the Bull's
Head signal, and list the pages worth parsing.

Caches per-catalogue page text to work/cat_txt/<name>.jsonl (one JSON per page) so
later passes don't re-open the 1.4 GB of PDFs. Reports, per catalogue, how many
pages carry Bull's Head signal (parale / Kiriac fig / quoted Moldavia-Wallachia
postmarks / Michel Romania 1-9 context).

Usage: python pdf_scan.py input/catalogues work/cat_txt
"""
import sys, os, re, json, glob
import fitz

# Bull's Head signal patterns
P_PARALE = re.compile(r"\b(\d{1,3})\s*(?:pa\.?|parale)\b", re.I)
P_KIRIAC = re.compile(r"Kiriac\s*(?:fig\.?|figure)?\s*\.?\s*(\d+[a-z]?)", re.I)
P_PMARK = re.compile(r'"([A-ZÄÖÜŞŢĂÂÎ][A-Za-zÄÖÜäöüŞşŢţĂăÂâÎî .\-/]{2,40})"')
P_BULL = re.compile(r"Bull'?s?\s*Head|cap de bour|Ochsenk|Moldau|Moldavia|Moldova", re.I)
# postmark vocabulary
P_PMKIND = re.compile(r"datestamp|circular|cds|grid|handstamp|cancel|obliter|pmk|postmark|struck|tied", re.I)


def relevant(text):
    has_denom = bool(P_PARALE.search(text))
    has_bull = bool(P_BULL.search(text))
    has_kir = bool(P_KIRIAC.search(text))
    return (has_denom and (has_bull or has_kir)) or has_kir


def main():
    indir, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    pdfs = sorted(glob.glob(os.path.join(indir, "*.pdf")))
    grand = {"pages": 0, "relevant_pages": 0, "kiriac": 0, "lots_est": 0}
    print(f"{'catalogue':<58} {'pg':>4} {'rel':>4} {'Kir':>4}")
    for pdf in pdfs:
        name = os.path.splitext(os.path.basename(pdf))[0]
        cache = os.path.join(outdir, name + ".jsonl")
        d = fitz.open(pdf)
        pc = d.page_count
        relpages = 0
        kir = 0
        with open(cache, "w", encoding="utf-8") as f:
            for i in range(pc):
                t = d[i].get_text()
                rel = relevant(t)
                if rel:
                    relpages += 1
                    kir += len(P_KIRIAC.findall(t))
                json.dump({"page": i, "relevant": rel, "text": t}, f, ensure_ascii=False)
                f.write("\n")
        d.close()
        grand["pages"] += pc
        grand["relevant_pages"] += relpages
        grand["kiriac"] += kir
        print(f"{name:<58} {pc:>4} {relpages:>4} {kir:>4}")
    print("-" * 74)
    print(f"{'TOTAL':<58} {grand['pages']:>4} {grand['relevant_pages']:>4} {grand['kiriac']:>4}")
    print(f"cached page text -> {outdir}")


if __name__ == "__main__":
    main()
