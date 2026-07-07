#!/usr/bin/env python3
"""
export_book.py -- Rebuild the book from the wiki/structured model (PAGINATION stage).

v1: rebuilds the 4-language A4 quadrant book as a .docx using python-docx:
  - A4 page geometry.
  - Headings in reading order.
  - Each 4-language content unit as a 2x2 table:
        EN (top-left)  | RO (top-right)
        FR (bottom-left) | DE (bottom-right)
  - Figures embedded; reference tables rendered as tables.

It reads work/extract/sections.json (the structured intermediate whose order and
provenance mirror the wiki narrative). A later iteration can read the wiki markdown
directly (DR-005); the ordering/ids are identical, so output is equivalent.

Editions (DR-009): --edition quad|en|ro|fr|de
  quad = 4-up (default, current book);  a single lang code = per-language edition.

Usage:
  python export_book.py work/extract output/bull-book.docx [--edition quad]
"""
import sys, os, json, argparse
from docx import Document
from docx.shared import Mm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

A4_W, A4_H = Mm(210), Mm(297)


def set_a4(section):
    section.page_width, section.page_height = A4_W, A4_H
    section.left_margin = section.right_margin = Mm(15)
    section.top_margin = section.bottom_margin = Mm(15)


def add_quad(doc, u, mediadir, edition):
    langs = [("en", u.get("en", "")), ("ro", u.get("ro", "")),
             ("fr", u.get("fr", "")), ("de", u.get("de", ""))]
    imgs = u.get("images", [])
    if edition != "quad":
        txt = dict(langs).get(edition, "").strip()
        if txt:
            for line in txt.split("\n"):
                doc.add_paragraph(line)
        _add_images(doc, imgs, mediadir)
        return
    # 2x2 table
    _add_images(doc, imgs, mediadir)
    tbl = doc.add_table(rows=2, cols=2)
    tbl.style = "Table Grid"
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cellmap = [(0, 0, langs[0]), (0, 1, langs[1]), (1, 0, langs[2]), (1, 1, langs[3])]
    for r, c, (code, text) in cellmap:
        cell = tbl.cell(r, c)
        cell.text = ""
        first = True
        for line in (text.strip().split("\n") if text.strip() else [""]):
            p = cell.paragraphs[0] if first else cell.add_paragraph()
            first = False
            run = p.add_run(line)
            run.font.size = Pt(9)
    doc.add_paragraph()


def _add_images(doc, imgs, mediadir):
    for img in imgs:
        path = os.path.join(mediadir, os.path.basename(img))
        if os.path.exists(path):
            try:
                doc.add_picture(path, width=Mm(80))
                doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
            except Exception:
                pass


def add_figure(doc, u, mediadir):
    _add_images(doc, u.get("targets", []), mediadir)
    cap = u.get("caption", "").strip()
    if cap:
        p = doc.add_paragraph()
        r = p.add_run(cap)
        r.italic = True
        r.font.size = Pt(8)
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER


def add_table(doc, u, mediadir):
    _add_images(doc, u.get("images", []), mediadir)
    rows = u.get("rows", [])
    if not rows:
        return
    ncol = max(len(r) for r in rows)
    t = doc.add_table(rows=0, cols=ncol)
    t.style = "Table Grid"
    for r in rows:
        cells = t.add_row().cells
        for i in range(ncol):
            cells[i].text = (r[i] if i < len(r) else "").replace("\n", " ")
    doc.add_paragraph()


def add_text(doc, u, edition):
    # single-language loose paragraph: include in quad edition and matching lang edition
    if edition == "quad" or edition == u.get("lang") or u.get("lang") == "?":
        doc.add_paragraph(u["text"])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("indir")
    ap.add_argument("outfile")
    ap.add_argument("--edition", default="en",       # English edition first (DR-009)
                    choices=["quad", "en", "ro", "fr", "de"])
    args = ap.parse_args()

    data = json.load(open(os.path.join(args.indir, "sections.json"), encoding="utf-8"))
    mediadir = os.path.join(args.indir, "media")
    secs = data["sections"]

    doc = Document()
    set_a4(doc.sections[0])

    for sec in secs:
        lvl = sec["level"]
        title = sec["title"]["en"] or "(untitled)"
        if lvl <= 0:
            h = doc.add_heading(title, level=1)
        else:
            h = doc.add_heading(title, level=min(lvl, 4))
        # multilingual subtitle line (RO | FR | DE) in quad edition
        if args.edition == "quad":
            sub = " | ".join(x for x in (sec["title"].get("ro"), sec["title"].get("fr"),
                                         sec["title"].get("de")) if x)
            if sub:
                p = doc.add_paragraph(sub)
                p.runs[0].italic = True
        for u in sec["units"]:
            k = u["kind"]
            if k == "quad":
                add_quad(doc, u, mediadir, args.edition)
            elif k == "figure":
                add_figure(doc, u, mediadir)
            elif k == "table":
                add_table(doc, u, mediadir)
            elif k == "text":
                add_text(doc, u, args.edition)

    os.makedirs(os.path.dirname(os.path.abspath(args.outfile)), exist_ok=True)
    doc.save(args.outfile)
    print(f"wrote {args.outfile} | edition={args.edition} | {len(secs)} sections")


if __name__ == "__main__":
    main()
