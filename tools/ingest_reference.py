#!/usr/bin/env python3
"""
ingest_reference.py -- OCR a scanned reference into raw wiki source text.

Stage 1 of the pipeline the user specified:
    raw document -> RAW TEXT -> raw concepts (w/ refs) -> translations -> pagination -> generation

Renders the requested page ranges, OCRs each page with **column-aware ordering**
(2-column catalogue pages are read left-column then right-column, not interleaved),
and writes one raw Markdown file per named section into the wiki `sources/` area,
with per-page delimiters and provenance frontmatter. Text is verbatim OCR
(`status: raw-ocr`); diacritics/'fixes' happen later in the concept stage.

Usage:
  python ingest_reference.py <pdf> <out_dir> \
      --sections "toc:1-16,guideline:17-26,chapter-1-postmarks-1858:28-59" \
      --source-id kiriac-1974 --lang ro --dpi 200
Page numbers in --sections are 1-indexed (as a human reads "pdf page N").
"""
import sys, os, re, json, argparse
import numpy as np
import fitz
from rapidocr_onnxruntime import RapidOCR


def parse_sections(spec):
    out = []
    for part in spec.split(","):
        label, rng = part.split(":")
        a, b = rng.split("-")
        out.append((label.strip(), int(a), int(b)))
    return out


def order_page(res, page_w):
    """Column-aware reading order. res: list of (box, text, conf)."""
    items = []
    for box, text, conf in res:
        xs = [p[0] for p in box]
        ys = [p[1] for p in box]
        cx = (min(xs) + max(xs)) / 2.0
        items.append((cx, min(ys), min(xs), text))
    if not items:
        return ""
    mid = page_w * 0.5
    left = [it for it in items if it[0] < mid]
    right = [it for it in items if it[0] >= mid]
    # only treat as 2-column when both sides are substantial
    if len(left) >= 4 and len(right) >= 4 and len(right) >= 0.2 * len(items):
        left.sort(key=lambda t: (t[1], t[2]))
        right.sort(key=lambda t: (t[1], t[2]))
        ordered = left + right
    else:
        ordered = sorted(items, key=lambda t: (t[1], t[2]))
    return "\n".join(t[3] for t in ordered)


def fm(source_id, label, pdf_pages, lang):
    return "\n".join([
        "---",
        f"id: sources/{source_id}/{label}",
        "type: source-raw",
        f"source: {source_id}",
        f"pdf_pages: {pdf_pages}",
        f"lang: {lang}",
        "ocr: true",
        "status: raw-ocr",
        "---", ""])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("out_dir")
    ap.add_argument("--sections", required=True)
    ap.add_argument("--source-id", required=True)
    ap.add_argument("--lang", default="ro")
    ap.add_argument("--dpi", type=int, default=200)
    args = ap.parse_args()

    sections = parse_sections(args.sections)
    os.makedirs(args.out_dir, exist_ok=True)
    cachedir = os.path.join(args.out_dir, ".raw")
    os.makedirs(cachedir, exist_ok=True)

    ocr = RapidOCR()
    d = fitz.open(args.pdf)
    pc = d.page_count

    # cache: OCR each needed page once
    needed = sorted({p for _, a, b in sections for p in range(a, b + 1)})
    page_text = {}
    cache_file = os.path.join(cachedir, "pages.jsonl")
    done = {}
    if os.path.exists(cache_file):
        for line in open(cache_file, encoding="utf-8"):
            r = json.loads(line)
            done[r["page1"]] = r["text"]

    import time
    t0 = time.time()
    with open(cache_file, "a", encoding="utf-8") as cf:
        for k, p1 in enumerate(needed):
            if p1 in done:
                page_text[p1] = done[p1]
                continue
            idx = p1 - 1
            if idx < 0 or idx >= pc:
                page_text[p1] = ""
                continue
            pix = d[idx].get_pixmap(dpi=args.dpi)
            img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, pix.n)
            if pix.n == 4:
                img = img[:, :, :3]
            res, _ = ocr(img)
            txt = order_page(res, pix.width) if res else ""
            page_text[p1] = txt
            json.dump({"page1": p1, "text": txt}, cf, ensure_ascii=False)
            cf.write("\n")
            cf.flush()
            if (k + 1) % 5 == 0:
                print(f"  OCR {k+1}/{len(needed)} pages ({time.time()-t0:.0f}s)", flush=True)

    # write section files
    for label, a, b in sections:
        chunks = []
        for p1 in range(a, b + 1):
            t = page_text.get(p1, "")
            chunks.append(f"<!-- pdf page {p1} -->\n\n{t}".rstrip())
        body = "\n\n---\n\n".join(chunks)
        path = os.path.join(args.out_dir, f"{label}.md")
        header = f"# {args.source_id} — {label} (pdf pages {a}-{b})\n\n"
        note = ("> Raw OCR (`status: raw-ocr`), verbatim, column-aware. Romanian "
                "diacritics are lost by the OCR model and reading order may be imperfect "
                "on mixed layouts — corrected in the concept stage, not here.\n\n")
        open(path, "w", encoding="utf-8").write(
            fm(args.source_id, label, f"{a}-{b}", args.lang) + header + note + body + "\n")
        print(f"wrote {path}  ({b-a+1} pages, {sum(len(page_text.get(p,'')) for p in range(a,b+1))} chars)")


if __name__ == "__main__":
    main()
