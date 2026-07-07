#!/usr/bin/env python3
"""
gen_issue_census.py -- Build the Bull's Head Issue I & II EVIDENCE CENSUS.

A unified ledger of every *documented* instance of a Cap de bou (Bull's Head)
stamp of the first (1858: 27/54/81/108 parale) or second (1858-1861: 5/40/80
parale) issue, drawn from all cited sources. One row per documented instance,
tagged by evidence type, each carrying a source + citation (DR-007).

Two input layers, merged:
  1. AUCTION layer (already extracted) -- work/census/lots.json + postmarks.json
     (from tools/census.py over the auction catalogues).
  2. MINED layer -- work/issue-census/*.jsonl, one JSON record per line, written
     by the per-source mining agents. Schema = RECORD_FIELDS below.

Outputs:
  wiki/entities/census/bull-head-evidence-census.md   the census page (dashboard + tables)
  wiki/entities/census/data/records.csv | records.json  the full queryable dataset

Usage: python gen_issue_census.py wiki
Re-run any time; it is deterministic and idempotent.
"""
import sys, os, re, json, csv, glob
from collections import Counter, defaultdict

RECORD_FIELDS = ["rec_id", "issue", "denom", "evidence_type", "on_cover",
                 "town", "date", "marking", "provenance", "value",
                 "source_id", "citation", "note"]

EVIDENCE_TYPES = {"auction-lot", "cover", "specimen", "on-piece", "block-strip-pair",
                  "postmark-occurrence", "archival-usage", "quantity", "plate-illustration",
                  "essay-proof", "forgery-reference", "mention"}

DENOMS_I = {"27", "54", "81", "108"}
DENOMS_II = {"5", "40", "80"}


def clean(s):
    return re.sub(r"\s+", " ", str(s or "")).strip()


def rec(**kw):
    r = {f: "" for f in RECORD_FIELDS}
    r.update({k: v for k, v in kw.items() if k in RECORD_FIELDS})
    r["issue"] = clean(r["issue"]).upper().replace("ISSUE", "").strip() or "?"
    r["denom"] = clean(r["denom"]).replace("pa", "").replace("parale", "").strip()
    for k in ("town", "marking", "provenance", "note", "citation", "source_id", "date", "value"):
        r[k] = clean(r[k])
    r["on_cover"] = bool(r["on_cover"]) if r["on_cover"] != "" else ""
    return r


def load_auction(records):
    """Auction lots + Bull's Head postmark occurrences -> records."""
    lots_p = "work/census/lots.json"
    pm_p = "work/census/postmarks.json"
    n = 0
    if os.path.exists(lots_p):
        for i, l in enumerate(json.load(open(lots_p, encoding="utf-8"))):
            if not l.get("issue"):
                continue
            snippet = clean(l.get("text", ""))[:180]
            certs = ", ".join(
                (c.get("expert", "") + (f" {c.get('year','')}" if c.get("year") else "")).strip()
                if isinstance(c, dict) else str(c)
                for c in (l.get("certs", []) or []))
            note = snippet
            if certs:
                note = f"[cert: {certs}] " + note
            if l.get("heimbuchler_page"):
                note = f"[Heimb. p.{l['heimbuchler_page']}] " + note
            records.append(rec(
                rec_id=f"auc-lot-{i:04d}",
                issue=l["issue"], denom=str(l.get("denomination", "")),
                evidence_type="cover" if l.get("on_cover") else "auction-lot",
                on_cover=l.get("on_cover", False),
                value=l.get("michel_value_eur", ""),
                source_id=l.get("catalogue", ""),
                citation=f"p.{l.get('page','')}",
                note=note))
            n += 1
    if os.path.exists(pm_p):
        for i, p in enumerate(json.load(open(pm_p, encoding="utf-8"))):
            if not p.get("on_bulls_head"):
                continue
            mk = clean(p.get("marking", ""))
            town = re.split(r"[/,]", mk)[0].strip() if mk else ""
            cit = f"p.{p.get('page','')}"
            if p.get("kiriac_fig"):
                cit += f", Kiriac fig.{p['kiriac_fig']}"
            note = " ".join(x for x in [p.get("type", ""), p.get("color", "")] if x)
            records.append(rec(
                rec_id=f"auc-pm-{i:04d}",
                issue=p.get("issue", "?"), denom=str(p.get("denomination", "")),
                evidence_type="postmark-occurrence",
                town=town, date=p.get("date", ""), marking=mk,
                source_id=p.get("catalogue", ""), citation=cit, note=note))
            n += 1
    return n


def load_mined(records):
    n = 0
    # JSON arrays (preferred: agent-written, validated as one document)
    for fp in sorted(glob.glob("work/issue-census/*.json")):
        try:
            arr = json.load(open(fp, encoding="utf-8"))
        except Exception as e:
            print(f"  [warn] skip {fp}: {e}"); continue
        for d in (arr if isinstance(arr, list) else []):
            records.append(rec(**d)); n += 1
    # JSONL fallback
    for fp in sorted(glob.glob("work/issue-census/*.jsonl")):
        for line in open(fp, encoding="utf-8"):
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            records.append(rec(**d)); n += 1
    return n


def issue_of(r):
    if r["issue"] in ("I", "II"):
        return r["issue"]
    if r["denom"] in DENOMS_I:
        return "I"
    if r["denom"] in DENOMS_II:
        return "II"
    return "?"


def render(records, vault):
    for r in records:
        r["issue"] = issue_of(r)
    by_issue = Counter(r["issue"] for r in records)
    by_denom = Counter(r["denom"] for r in records if r["denom"])
    by_type = Counter(r["evidence_type"] for r in records)
    by_source = Counter(r["source_id"] for r in records)

    outdir = os.path.join(vault, "entities", "census")
    datadir = os.path.join(outdir, "data")
    os.makedirs(datadir, exist_ok=True)
    # data files
    with open(os.path.join(datadir, "records.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=RECORD_FIELDS); w.writeheader()
        for r in records:
            w.writerow(r)
    json.dump(records, open(os.path.join(datadir, "records.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    def tbl(rows):
        out = ["| Issue | Denom | Type | Town | Date | Source | Cite | Note |",
               "|---|---|---|---|---|---|---|---|"]
        for r in rows:
            note = r["note"][:120].replace("|", "\\|")
            src = r["source_id"][:28]
            out.append(f"| {r['issue']} | {r['denom']} | {r['evidence_type']} | "
                       f"{r['town'][:18]} | {r['date']} | {src} | {r['citation']} | {note} |")
        return "\n".join(out)

    DENOM_ORDER = ["27", "54", "81", "108", "5", "40", "80", ""]
    lines = []
    lines.append("---")
    lines.append("id: entities/census/bull-head-evidence-census")
    lines.append("type: census")
    lines.append("title: {en: Bull's Head evidence census (Issue I & II)}")
    lines.append(f"records: {len(records)}")
    lines.append("status: living")
    lines.append("---\n")
    lines.append("# Bull's Head evidence census — Issue I & II\n")
    lines.append("> Every **documented** instance of a *Cap de bou* stamp of the first "
                 "(1858 — 27/54/81/108 parale) or second (1858–1861 — 5/40/80 parale) issue, "
                 "gathered from the cited sources. One row = one documented instance, tagged by "
                 "**evidence type**, each with a source + citation (DR-007). Built by "
                 "`tools/gen_issue_census.py`; full data in "
                 "[`data/records.csv`](data/records.csv).\n")
    lines.append("> **Companions:** [[../postmarks/census]] (the auction *postmark* census this "
                 "draws on) · [[../references/bulls-head-lots]] · [[../issues/issue-bull-1]] · "
                 "[[../issues/issue-bull-2]].\n")
    lines.append("## Dashboard\n")
    lines.append(f"- **{len(records)} records** — Issue **I: {by_issue.get('I',0)}**, "
                 f"Issue **II: {by_issue.get('II',0)}**, unattributed: {by_issue.get('?',0)}.")
    lines.append("- **By denomination:** " + " · ".join(
        f"{d}pa: {by_denom.get(d,0)}" for d in DENOM_ORDER if d and by_denom.get(d)))
    lines.append("- **By evidence type:** " + " · ".join(
        f"{t}: {c}" for t, c in by_type.most_common()))
    lines.append("- **By source:** " + " · ".join(
        f"{s or '—'}: {c}" for s, c in by_source.most_common()))
    lines.append("\n## Method & caveats\n")
    lines.append("- **Auction layer** (`auc-*` ids) is the mechanical extraction from the auction "
                 "catalogues (`tools/census.py`): lot- and postmark-level records. Verify against "
                 "the source page before citing a specific claim.")
    lines.append("- **Mined layer** is hand-read from the narrative/document sources by source "
                 "(each row cites a photo/page). Diacritics restored on quotation (DR-011).")
    lines.append("- One physical item may appear as several rows (e.g. a cover *and* its postmark). "
                 "Deduplication is deliberately light — each row is a distinct *documented mention*.")
    lines.append("- `?` issue = denomination not stated in the source.\n")

    # Non-auction (mined) records shown in full, grouped by issue -> denom
    mined = [r for r in records if not r["rec_id"].startswith("auc-")]
    lines.append(f"## Documented records from the narrative & document sources ({len(mined)})\n")
    if mined:
        for iss in ("I", "II", "?"):
            grp = [r for r in mined if r["issue"] == iss]
            if not grp:
                continue
            label = {"I": "Issue I (1858)", "II": "Issue II (1858–1861)", "?": "Issue unattributed"}[iss]
            lines.append(f"### {label} — {len(grp)}\n")
            grp.sort(key=lambda r: (DENOM_ORDER.index(r["denom"]) if r["denom"] in DENOM_ORDER else 9,
                                    r["source_id"], r["town"]))
            lines.append(tbl(grp) + "\n")
    else:
        lines.append("*(none yet — mining in progress)*\n")

    # Auction layer summarized (full detail in CSV)
    lines.append(f"## Auction layer — summary ({len([r for r in records if r['rec_id'].startswith('auc-')])})\n")
    lines.append("Full rows in [`data/records.csv`](data/records.csv). Covers & lots by "
                 "denomination, from [[../references/README|the catalogues]]:\n")
    auc = [r for r in records if r["rec_id"].startswith("auc-")]
    ac = "| Denom | Issue | Lots/covers | Postmark occ. |\n|---|---|---|---|\n"
    for d in [x for x in DENOM_ORDER if x]:
        lots = sum(1 for r in auc if r["denom"] == d and r["evidence_type"] in ("auction-lot", "cover"))
        pms = sum(1 for r in auc if r["denom"] == d and r["evidence_type"] == "postmark-occurrence")
        iss = "I" if d in DENOMS_I else "II"
        if lots or pms:
            ac += f"| {d}pa | {iss} | {lots} | {pms} |\n"
    lines.append(ac)

    open(os.path.join(outdir, "bull-head-evidence-census.md"), "w", encoding="utf-8").write(
        "\n".join(lines) + "\n")
    return by_issue, by_type, by_source


def main():
    vault = sys.argv[1] if len(sys.argv) > 1 else "wiki"
    records = []
    na = load_auction(records)
    nm = load_mined(records)
    bi, bt, bs = render(records, vault)
    print(f"census: {len(records)} records ({na} auction + {nm} mined)")
    print(f"  by issue: {dict(bi)}")
    print(f"  by type:  {dict(bt)}")
    print(f"  sources:  {len(bs)}")


if __name__ == "__main__":
    main()
