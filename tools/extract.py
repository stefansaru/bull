#!/usr/bin/env python3
"""
extract.py -- Faithful, ordered extraction of the Bull's Head stamps book.

Reads a .docx (zip) and walks word/document.xml in document order, emitting an
ordered "document model" (JSON) of typed blocks:

  - heading      : a heading paragraph (level from Heading1..9 / Title), possibly
                   multilingual (the book writes headings inline as
                   "EnglishRomanian | French | German").
  - quad         : a 2x2 language content table -> {en, ro, fr, de} rich text.
  - kv           : a small 2x2 metadata table (label in 4 langs) + trailing value.
  - table        : any other table, captured as rows x cells (4-lang aware if 2xN).
  - para         : a loose paragraph outside any table (verbatim).
  - image        : a drawing/pict; resolves r:embed -> rels -> word/media/<file>.

Text is captured with light inline markers:
  - paragraph breaks inside a cell become "\n"
  - <w:br/> -> "\n", <w:tab/> -> "\t"
Media are copied out to <outdir>/media/ (deduped by source name).

Usage:
  python extract.py <book.docx> <outdir>
"""
import sys, os, re, json, zipfile, shutil
from lxml import etree

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
A = "http://schemas.openxmlformats.org/drawingml/2006/main"
NS = {"w": W, "r": R, "a": A}


def q(tag):
    return f"{{{W}}}{tag}"


def local(el):
    return etree.QName(el).localname


# ---- text extraction ------------------------------------------------------

def para_text(p):
    """Verbatim text of a <w:p>, with tabs/breaks preserved. No trailing NL."""
    parts = []
    for node in p.iter():
        ln = local(node)
        if ln == "t":
            parts.append(node.text or "")
        elif ln == "tab":
            parts.append("\t")
        elif ln == "br":
            parts.append("\n")
        elif ln == "cr":
            parts.append("\n")
    return "".join(parts)


def para_style(p):
    ppr = p.find(q("pPr"))
    if ppr is None:
        return None
    st = ppr.find(q("pStyle"))
    if st is None:
        return None
    return st.get(q("val"))


HEADING_RE = re.compile(r"^(Heading|Title$|Subtitle$)")


def heading_level(style):
    if not style:
        return None
    if style == "Title":
        return 0
    m = re.match(r"Heading(\d)", style)
    if m:
        return int(m.group(1))
    if style == "Subtitle":
        return 2
    if style == "Heading3NONUMBERS":
        return 3
    return None


def cell_text(tc):
    """All paragraphs in a table cell joined by newline. Verbatim."""
    lines = []
    for p in tc.findall(q("p")):
        lines.append(para_text(p))
    return "\n".join(lines).strip("\n")


def cell_images(tc, rels):
    return collect_images(tc, rels)


# ---- image resolution -----------------------------------------------------

def load_rels(z):
    data = z.read("word/_rels/document.xml.rels")
    root = etree.fromstring(data)
    rels = {}
    for rel in root:
        rid = rel.get("Id")
        target = rel.get("Target")
        rels[rid] = target
    return rels


def collect_images(el, rels):
    """Find image r:embed / r:id references under el, resolve to media targets."""
    out = []
    for node in el.iter():
        ln = local(node)
        # DrawingML blip
        if ln == "blip":
            rid = node.get(f"{{{R}}}embed") or node.get(f"{{{R}}}link")
            if rid and rid in rels:
                out.append(rels[rid])
        # VML imagedata (v:imagedata r:id)
        if ln == "imagedata":
            rid = node.get(f"{{{R}}}id")
            if rid and rid in rels:
                out.append(rels[rid])
    return out


# ---- table classification -------------------------------------------------

def grid(tbl):
    """Return rows -> list of cells (tc elements) for direct children only."""
    rows = []
    for tr in tbl.findall(q("tr")):
        cells = tr.findall(q("tc"))
        rows.append(cells)
    return rows


def is_quad(rows):
    """2x2 (or 4x2 with blank spacer rows) language table.
    The book uses row0=[EN,RO], (blank), row1=[FR,DE], (blank)."""
    # collect non-empty rows that have exactly 2 cells
    two = [r for r in rows if len(r) == 2]
    return len(two) >= 2


def classify_table(tbl, rels):
    rows = grid(tbl)
    ncells = [len(r) for r in rows]
    # Build text matrix
    textrows = [[cell_text(c) for c in r] for r in rows]
    imgrows = [[cell_images(c, rels) for c in r] for r in rows]
    return rows, ncells, textrows, imgrows


# ---- main walk ------------------------------------------------------------

def walk(body, rels):
    blocks = []
    for child in body:
        ln = local(child)
        if ln == "p":
            style = para_style(child)
            lvl = heading_level(style)
            imgs = collect_images(child, rels)
            txt = para_text(child)
            if lvl is not None and txt.strip():
                blocks.append({"type": "heading", "level": lvl,
                               "style": style, "text": txt})
            elif imgs:
                blocks.append({"type": "image", "targets": imgs,
                               "caption": txt.strip(), "style": style})
                if txt.strip():
                    # image paragraph may also carry caption text
                    pass
            elif txt.strip():
                blocks.append({"type": "para", "style": style, "text": txt})
            # else: empty spacer paragraph -> skip
        elif ln == "tbl":
            rows, ncells, textrows, imgrows = classify_table(child, rels)
            flat_imgs = [t for r in imgrows for c in r for t in c]
            two_rows = [r for r in textrows if len(r) == 2]
            # Heuristic: 2x2 language block
            if len(two_rows) >= 2 and all(len(r) <= 2 for r in textrows):
                # order: first 2-cell row = EN/RO, next = FR/DE (ignore blank rows)
                langrows = [r for r in textrows if len(r) == 2]
                en = ro = fr = de = ""
                if len(langrows) >= 1:
                    en, ro = langrows[0][0], langrows[0][1]
                if len(langrows) >= 2:
                    fr, de = langrows[1][0], langrows[1][1]
                # single-cell rows (e.g. "1858") captured as extra
                singles = [r[0] for r in textrows if len(r) == 1 and r[0].strip()]
                blk = {"type": "quad", "en": en, "ro": ro, "fr": fr, "de": de}
                if singles:
                    blk["singles"] = singles
                if flat_imgs:
                    blk["images"] = flat_imgs
                blocks.append(blk)
            else:
                blocks.append({"type": "table", "rows": textrows,
                               "ncells": ncells, "images": imgrows,
                               "flat_images": flat_imgs})
    return blocks


def main():
    src, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    mediadir = os.path.join(outdir, "media")
    os.makedirs(mediadir, exist_ok=True)

    z = zipfile.ZipFile(src)
    rels = load_rels(z)
    doc = z.read("word/document.xml")
    root = etree.fromstring(doc)
    body = root.find(q("body"))

    blocks = walk(body, rels)

    # Copy referenced media
    referenced = set()
    for b in blocks:
        for key in ("targets", "images"):
            v = b.get(key)
            if isinstance(v, list):
                for item in v:
                    if isinstance(item, str):
                        referenced.add(item)
                    elif isinstance(item, list):
                        for sub in item:
                            if isinstance(sub, list):
                                referenced.update(sub)
                            else:
                                referenced.add(sub)
        for item in b.get("flat_images", []) or []:
            referenced.add(item)
    copied = 0
    names = set(z.namelist())
    for tgt in sorted(referenced):
        arc = "word/" + tgt if not tgt.startswith("word/") else tgt
        arc = arc.replace("word/word/", "word/")
        if arc in names:
            base = os.path.basename(tgt)
            with z.open(arc) as fsrc, open(os.path.join(mediadir, base), "wb") as fdst:
                shutil.copyfileobj(fsrc, fdst)
            copied += 1

    with open(os.path.join(outdir, "document_model.json"), "w", encoding="utf-8") as f:
        json.dump({"source": os.path.basename(src),
                   "block_count": len(blocks),
                   "media_referenced": len(referenced),
                   "media_copied": copied,
                   "blocks": blocks}, f, ensure_ascii=False, indent=1)

    # Stats
    from collections import Counter
    c = Counter(b["type"] for b in blocks)
    print("blocks:", len(blocks), dict(c))
    print("media referenced:", len(referenced), "copied:", copied)


if __name__ == "__main__":
    main()
