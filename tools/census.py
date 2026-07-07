#!/usr/bin/env python3
"""
census.py -- Bull's Head / Moldavia-Wallachia postmark census from catalogue text.

Reads work/cat_txt/*.jsonl (pdf_scan.py). Postmark extraction is anchored on the
Kiriac figure number (the field's public postmark identifier) and on quoted markings
with cancellation context. For each postmark it captures: marking text, type, ink
colour, date, Kiriac fig, catalogue, page, and — by looking back for the nearest
denomination — whether it sits on a Bull's Head adhesive (`on_bulls_head`) and which
issue/denomination.

Outputs (work/census/):
  postmarks.json / postmarks.csv   one row per postmark occurrence
  lots.json                         lot-level records (denomination lots)
  summary.json                      aggregates

Usage: python census.py work/cat_txt work/census
"""
import sys, os, re, json, glob, csv, hashlib
from collections import Counter

ISSUE_I = {27, 54, 81, 108}
ISSUE_II = {5, 40, 80}
BH = ISSUE_I | ISSUE_II

DENOM = re.compile(r"\b(\d{1,3})\s*(?:pa\.?|parale)\b", re.I)
KIRIAC_PAREN = re.compile(r"\(\s*Kiriac[^)]*?(?:fig\.?|#\w+,?\s*fig\.?)?\s*\.?\s*(\d+[a-z]?)[^)]*\)", re.I)
QMARK = re.compile(r'"([^"]{2,60})"')
KIND = re.compile(r"(circular datestamp|circular date stamp|two line dated|two-line|double circle|"
                  r"framed [A-Za-z]+ handstamp|framed|boxed|negative seal|datestamp|date stamp|\bcds\b|"
                  r"grid|dotted|handstamp|manuscript|straight[- ]line|oval|Cyrillic)", re.I)
COLOR = re.compile(r"\bin\s+((?:deep|light|pale|greenish|bluish|milky|reddish)?[- ]?"
                   r"(?:red|blue|black|green|violet|brown|orange|carmine|rose))\b(?:\s*ink)?", re.I)
DATEP = re.compile(r"\(([^)]*(?:\d{1,2}[/.]\d|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|"
                   r"MAP|MAI|MAR|IAH|АПР)\b)[^)]*)\)")
CERT = re.compile(r"Cert(?:\.|ificate)?\s+([A-ZÉ][A-Za-zÀ-ÿ.'\- ]+?)\s*\((\d{4})\)")
MIVAL = re.compile(r"Mi\.?\s*=?\s*€\s*([\d'’.,]+)")
HEIMB = re.compile(r"(?:Heimb[üu]chler|Handbook)\b[^.]{0,60}?page\s+(\d+)", re.I)
FRANKISH = re.compile(r"franko|franco|фpahko|франко|recepisse|recipissa|retour|p\.p\.|porto", re.I)


def issue_of(d):
    return "I" if d in ISSUE_I else "II" if d in ISSUE_II else "?"


def nearest_denom(text, pos, back=600):
    seg = text[max(0, pos - back):pos]
    ds = [int(x) for x in DENOM.findall(seg) if int(x) in BH]
    return ds[-1] if ds else None


def clean(s):
    return re.sub(r"\s+", " ", s).strip()


# Feldman-style cancellation descriptions (no Kiriac number, often no quoted town)
PM_DESC = re.compile(
    r"((?:small |large |fine |part |light |neat |bold |superb |clear |good )*"
    r"(?:double[- ]?circle|single[- ]?circle|circular|framed|boxed|grid|dotted|"
    r"two[- ]?line|oval|straight[- ]?line)\s*"
    r"(?:d\.?s\.?|datestamp|date ?stamp|cds|cancellation|postmark|handstamp))"
    r"(?:[^.\n]{0,45}?\bin\s+((?:deep|light|pale|greenish|bluish)?[- ]?"
    r"(?:red|blue|black|green|violet|brown|orange|carmine|rose)))?", re.I)


def extract_postmarks(text, catalogue, page):
    out = []
    kir_spans = []
    for m in KIRIAC_PAREN.finditer(text):
        kir_spans.append(m.start())
        fig = m.group(1)
        back = text[max(0, m.start() - 240):m.start()]
        qs = list(QMARK.finditer(back))
        mark = clean(qs[-1].group(1)) if qs else ""
        seg = back[qs[-1].end():] if qs else back           # marking → (Kiriac)
        kind = KIND.search(seg) or KIND.search(back)
        color = COLOR.search(seg) or COLOR.search(back[-80:])
        date = DATEP.search(seg)
        denom = nearest_denom(text, m.start())
        marking_kind = "prepaid/handstamp" if FRANKISH.search(mark + seg) else \
                       (kind.group(1).lower() if kind else "")
        out.append({
            "catalogue": catalogue, "page": page, "kiriac_fig": fig, "source": "kiriac",
            "marking": mark, "type": (kind.group(1).lower() if kind else marking_kind),
            "color": (color.group(1).lower() if color else ""),
            "date": clean(date.group(1)) if date else "",
            "denomination": denom, "issue": issue_of(denom) if denom else "",
            "on_bulls_head": denom is not None,
            "context": clean(text[max(0, m.start() - 180):m.start() + 20]),
        })
    # description-based pass (for catalogues that don't cite Kiriac, e.g. Feldman).
    # Only where no Kiriac paren is nearby, the lot has a Bull's Head denom, and there
    # is a colour or cover/used context -> keeps it focused and avoids double-counting.
    for m in PM_DESC.finditer(text):
        if any(abs(m.start() - k) < 180 for k in kir_spans):
            continue
        denom = nearest_denom(text, m.start(), back=350)
        if denom is None:
            continue
        color = (m.group(2) or "").lower()
        win = text[max(0, m.start() - 120):m.start() + 60]
        if not color and not re.search(r"\b(cover|entire|used|cancelled|tied)\b", win, re.I):
            continue
        qs = list(QMARK.finditer(text[max(0, m.start() - 120):m.start()]))
        mark = clean(qs[-1].group(1)) if qs else ""
        date = DATEP.search(text[m.end():m.end() + 60])
        out.append({
            "catalogue": catalogue, "page": page, "kiriac_fig": "", "source": "desc",
            "marking": mark, "type": clean(m.group(1)).lower(),
            "color": color, "date": clean(date.group(1)) if date else "",
            "denomination": denom, "issue": issue_of(denom),
            "on_bulls_head": True,
            "context": clean(win),
        })
    return out


def extract_lots(text, catalogue, page):
    """Coarse lot records: each denomination mention with its surrounding sentence."""
    lots = []
    for m in DENOM.finditer(text):
        d = int(m.group(1))
        if d not in BH:
            continue
        win = text[m.start():m.start() + 700]
        certs = [{"expert": clean(e), "year": y} for e, y in CERT.findall(win)]
        mv = MIVAL.search(win)
        hb = HEIMB.search(win)
        lots.append({
            "catalogue": catalogue, "page": page,
            "denomination": d, "issue": issue_of(d),
            "on_cover": bool(re.search(r"\b(cover|entire|wrapper|letter)\b", win, re.I)),
            "color_paper": clean(text[m.end():m.end() + 60].split(",")[0]),
            "kiriac_figs": sorted(set(KIRIAC_PAREN.findall(win))),
            "certs": certs,
            "michel_value_eur": (mv.group(1).replace("’", "'") if mv else ""),
            "heimbuchler_page": hb.group(1) if hb else "",
            "text": clean(win)[:800],
        })
    return lots


# broad page filter (independent of the stored 'relevant' flag) so we catch pages the
# stricter scan filter skipped (e.g. first-issue denom pages with no 'Bull'/'Kiriac' word)
BROAD = re.compile(r"bull'?s?\s*head|cap de bour|ochsenk|moldau|kiriac|"
                   r"\b(5|27|40|54|80|81|108)\s*(?:pa\.?|parale)\b", re.I)


def main():
    indir, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    postmarks, lots = [], []
    seen_hashes = {}
    for jl in sorted(glob.glob(os.path.join(indir, "*.jsonl"))):
        catalogue = os.path.splitext(os.path.basename(jl))[0]
        recs = [json.loads(l) for l in open(jl, encoding="utf-8")]
        pages = [r for r in recs if BROAD.search(r["text"])]
        reltext = "".join(r["text"] for r in pages)
        if not reltext.strip():
            continue
        h = hashlib.sha256(reltext.encode("utf-8")).hexdigest()
        if h in seen_hashes:
            print(f"  (skip duplicate: {catalogue} == {seen_hashes[h]})")
            continue
        seen_hashes[h] = catalogue
        for r in pages:
            t = re.sub(r"[ \t]+", " ", r["text"])
            postmarks += extract_postmarks(t, catalogue, r["page"])
            lots += extract_lots(t, catalogue, r["page"])

    json.dump(postmarks, open(os.path.join(outdir, "postmarks.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    json.dump(lots, open(os.path.join(outdir, "lots.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    with open(os.path.join(outdir, "postmarks.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["catalogue", "page", "source", "kiriac_fig", "marking", "type", "color",
                    "date", "issue", "denomination", "on_bulls_head"])
        for p in postmarks:
            w.writerow([p["catalogue"], p["page"], p.get("source", ""), p["kiriac_fig"],
                        p["marking"], p["type"], p["color"], p["date"], p["issue"],
                        p["denomination"] or "", p["on_bulls_head"]])

    bh_pm = [p for p in postmarks if p["on_bulls_head"]]
    figs = Counter(p["kiriac_fig"] for p in postmarks)
    marks = Counter(p["marking"].upper() for p in postmarks if p["marking"])
    summary = {
        "postmark_occurrences": len(postmarks),
        "on_bulls_head": len(bh_pm),
        "unique_kiriac_figs": len(figs),
        "unique_markings": len(marks),
        "lots": len(lots),
        "lots_by_issue": dict(Counter(l["issue"] for l in lots)),
        "lots_by_denom": dict(sorted(Counter(l["denomination"] for l in lots).items())),
        "top_markings": marks.most_common(30),
        "kiriac_fig_counts": dict(sorted(figs.items(), key=lambda x: int(re.sub(r"\D", "", x[0]) or 0))),
    }
    json.dump(summary, open(os.path.join(outdir, "summary.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print(f"postmark occurrences: {len(postmarks)} (on Bull's Head adhesive: {len(bh_pm)})")
    print(f"unique Kiriac figs: {len(figs)} | unique markings: {len(marks)} | lots: {len(lots)}")
    print("top markings:", marks.most_common(12))


if __name__ == "__main__":
    main()
