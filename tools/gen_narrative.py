#!/usr/bin/env python3
"""
gen_narrative.py -- Generate English-master narrative pages + translation sidecars.

Per DR-003 (English master), DR-009 (English edition first) and DR-010 (sidecar
translation storage):

  narrative/<NN-chapter>/<NNN-slug>.md         # ENGLISH master (+ shared figures/tables)
  narrative/<NN-chapter>/<NNN-slug>.i18n.yml   # RO/FR/DE for each translatable unit

Each content unit gets a stable UID (from provenance, sorts in document order) and an
English source-hash. The sidecar stores each translation's text + the en_hash it was
made from + a status, so a translation auto-flags stale when its English changes
(see tools/i18n_status.py). Non-English loose fragments are preserved in the sidecar
as language-tagged 'orphan' units (English page stays clean). Nothing is lost.

Usage: python gen_narrative.py work/extract wiki
"""
import sys, os, json, re
import yaml
sys.path.insert(0, os.path.dirname(__file__))
from i18n import uid_for, en_hash, sidecar_path

MEDIAPREFIX = "../../assets/media"


def slug(text, maxlen=60):
    t = re.sub(r"[^\w\s-]", "", text.strip().lower(), flags=re.U)
    t = re.sub(r"[\s_-]+", "-", t).strip("-")
    return (t[:maxlen].strip("-") or "section")


def esc_yaml(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def md_cell(s):
    return s.replace("\n", " ").replace("|", "\\|").strip()


def img_md(target):
    return f"![{os.path.basename(target)}]({MEDIAPREFIX}/{os.path.basename(target)})"


def render_table_md(u):
    rows = u.get("rows", [])
    if not rows:
        return ""
    out = []
    for img in u.get("images", []):
        out.append(img_md(img)); out.append("")
    ncol = max(len(r) for r in rows)
    hdr = list(rows[0]) + [""] * (ncol - len(rows[0]))
    out.append("| " + " | ".join(md_cell(c) for c in hdr) + " |")
    out.append("|" + "|".join(["---"] * ncol) + "|")
    for r in rows[1:]:
        r = list(r) + [""] * (ncol - len(r))
        out.append("| " + " | ".join(md_cell(c) for c in r) + " |")
    return "\n".join(out)


def build_page(sec):
    """Return (english_markdown_body, sidecar_dict). English + shared content go to
    the body with <!-- u:UID --> markers; translations go to the sidecar."""
    body = []
    side_units = {}
    for u in sec["units"]:
        uid = uid_for(u["source_blocks"])
        k = u["kind"]
        marker = f"<!-- u:{uid} kind:{k} -->"
        if k == "quad":
            body.append(marker)
            for img in u.get("images", []):
                body.append(img_md(img)); body.append("")
            # the exact English prose block written (en + any singles) is what we hash,
            # so the linter reconstructs and hashes the identical text (no false stale)
            en_parts = [u.get("en", "").strip()] + [s.strip() for s in u.get("singles", [])]
            en_block = "\n".join(p for p in en_parts if p)
            if en_block:
                body.append(en_block)
            body.append("")
            entry = {"kind": "quad", "en_hash": en_hash(en_block)}
            for lg in ("ro", "fr", "de"):
                txt = u.get(lg, "").strip()
                if txt:
                    entry[lg] = {"status": "ok", "text": txt}
            side_units[uid] = entry
        elif k == "text":
            lang = u.get("lang", "en")
            if lang in ("en", "?"):
                body.append(marker)
                body.append(u["text"].strip())
                body.append("")
            else:
                # non-English loose fragment -> sidecar orphan (keeps EN page clean)
                side_units[uid] = {"kind": "text", "orphan_lang": lang,
                                   "status": "orphan", "text": u["text"].strip()}
        elif k == "figure":
            body.append(marker)
            for img in u["targets"]:
                body.append(img_md(img))
            cap = u.get("caption", "").strip()
            if cap:
                body.append(""); body.append(f"*{cap}*")
            body.append("")
        elif k == "table":
            body.append(marker)
            body.append(render_table_md(u))
            body.append("")
    return "\n".join(body).rstrip() + "\n", side_units


def frontmatter(sec, page_id, chapter):
    t = sec["title"]
    fm = ["---", f"id: {page_id}", "type: narrative-section",
          f"chapter: {esc_yaml(chapter)}", f"order: {sec['order']}",
          f"level: {sec['level']}", "edition_master: en", "title:",
          f"  en: {esc_yaml(t['en'])}"]
    for k in ("ro", "fr", "de"):
        if t.get(k):
            fm.append(f"  {k}: {esc_yaml(t[k])}")
    if sec.get("markers"):
        fm.append("markers: [" + ", ".join(esc_yaml(m) for m in sec["markers"]) + "]")
    sb = sec["source_blocks"]
    fm.append(f"source_blocks: [{min(sb)}..{max(sb)}]" if sb else "source_blocks: []")
    fm.append("status: verbatim")
    fm.append("---")
    return "\n".join(fm)


def main():
    outdir, vault = sys.argv[1], sys.argv[2]
    data = json.load(open(os.path.join(outdir, "sections.json"), encoding="utf-8"))
    secs = data["sections"]
    narr = os.path.join(vault, "narrative")
    os.makedirs(narr, exist_ok=True)

    toc = ["---", "id: _toc", "type: meta", "title: {en: Table of contents}", "---", "",
           "# Table of contents", "",
           "Generated in reading order. English master; translations in `.i18n.yml` sidecars.", ""]
    chnum = 0
    cur_ch = ("00", "front-matter", "Front matter")
    counters = {}
    written = 0
    n_units = n_trans = 0

    for sec in secs:
        if sec["level"] == 1:
            chnum += 1
            cur_ch = (f"{chnum:02d}", slug(sec["title"]["en"]) or f"chapter-{chnum}", sec["title"]["en"])
        chdir = f"{cur_ch[0]}-{cur_ch[1]}"
        d = os.path.join(narr, chdir)
        os.makedirs(d, exist_ok=True)
        counters.setdefault(chdir, 0)
        counters[chdir] += 1
        base = f"{counters[chdir]:03d}-{slug(sec['title']['en'])}"
        page_id = f"narrative/{chdir}/{base}"
        path = os.path.join(d, base + ".md")

        body, side_units = build_page(sec)
        hashes = "#" * max(1, min(6, sec["level"] if sec["level"] > 0 else 1))
        page = (frontmatter(sec, page_id, cur_ch[2]) + "\n\n"
                + f"{hashes} {sec['title']['en']}\n\n" + body)
        open(path, "w", encoding="utf-8").write(page)

        # sidecar (only if there is any translation/orphan content)
        if side_units:
            side = {"page": page_id,
                    "title": {k: sec["title"][k] for k in ("ro", "fr", "de") if sec["title"].get(k)},
                    "units": side_units}
            with open(sidecar_path(path), "w", encoding="utf-8") as f:
                yaml.safe_dump(side, f, allow_unicode=True, sort_keys=False, width=100000)
            for uid, e in side_units.items():
                n_units += 1
                n_trans += sum(1 for lg in ("ro", "fr", "de") if isinstance(e.get(lg), dict))

        written += 1
        indent = "  " * max(0, sec["level"] - 1) if sec["level"] > 0 else ""
        toc.append(f"{indent}- [{sec['title']['en']}]({chdir}/{base}.md)")

    open(os.path.join(narr, "_toc.md"), "w", encoding="utf-8").write("\n".join(toc) + "\n")
    print(f"wrote {written} English pages + sidecars across {chnum} chapters -> {narr}")
    print(f"sidecar units: {n_units} | stored translations (ro+fr+de): {n_trans}")


if __name__ == "__main__":
    main()
