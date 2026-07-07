#!/usr/bin/env python3
"""
ingest_sources.py -- Batch raw-ingest reference sources into the wiki (DR-011).

Driven by a JSON manifest. For each source:
  - text-layer PDF  -> extract page text (PyMuPDF), page-delimited
  - scanned PDF     -> OCR (RapidOCR, column-aware) [mode: ocr]
  - .txt            -> copy through
Optionally extract embedded images (mode-flagged) to assets/sources/<id>/ and embedded
hyperlinks to the source page's frontmatter.

Writes wiki/sources/<id>/text.md (+ links.md if any, + image manifest).
Resumable per source (skips if text.md exists unless --force).

Usage:
  python ingest_sources.py <manifest.json> wiki [--only <id>] [--force] [--dpi 200]
"""
import sys, os, re, json, argparse, time, hashlib

MIN_IMG_BYTES = 6000   # skip tiny/decorative images


def order_page_ocr(res, page_w):
    items = []
    for box, text, conf in res:
        xs = [p[0] for p in box]; ys = [p[1] for p in box]
        items.append(((min(xs)+max(xs))/2.0, min(ys), min(xs), text))
    if not items:
        return ""
    mid = page_w*0.5
    left = [i for i in items if i[0] < mid]; right = [i for i in items if i[0] >= mid]
    if len(left) >= 4 and len(right) >= 4 and len(right) >= 0.2*len(items):
        left.sort(key=lambda t:(t[1],t[2])); right.sort(key=lambda t:(t[1],t[2]))
        ordered = left+right
    else:
        ordered = sorted(items, key=lambda t:(t[1],t[2]))
    return "\n".join(t[3] for t in ordered)


def text_of_page(pg):
    """Reading-order text via blocks sorted by (column, y)."""
    blocks = pg.get_text("blocks")  # (x0,y0,x1,y1,text,bno,btype)
    tb = [b for b in blocks if b[6] == 0 and b[4].strip()]
    if not tb:
        return pg.get_text().strip()
    w = pg.rect.width
    mid = w*0.5
    left = [b for b in tb if (b[0]+b[2])/2 < mid]
    right = [b for b in tb if (b[0]+b[2])/2 >= mid]
    if len(left) >= 3 and len(right) >= 3 and len(right) >= 0.2*len(tb):
        left.sort(key=lambda b:(b[1], b[0])); right.sort(key=lambda b:(b[1], b[0]))
        ordered = left+right
    else:
        ordered = sorted(tb, key=lambda b:(b[1], b[0]))
    return "\n".join(b[4].strip() for b in ordered)


def extract_images(doc, src_id, vault, max_images=400):
    outdir = os.path.join(vault, "assets", "sources", src_id)
    os.makedirs(outdir, exist_ok=True)
    seen = set(); manifest = []
    count = 0
    for pno in range(doc.page_count):
        for img in doc[pno].get_images(full=True):
            xref = img[0]
            if xref in seen:
                continue
            seen.add(xref)
            try:
                ext = doc.extract_image(xref)
                data = ext["image"]; e = ext["ext"]
            except Exception:
                continue
            if len(data) < MIN_IMG_BYTES:
                continue
            name = f"p{pno+1:04d}_x{xref}.{e}"
            with open(os.path.join(outdir, name), "wb") as f:
                f.write(data)
            manifest.append({"file": name, "page": pno+1, "bytes": len(data)})
            count += 1
            if count >= max_images:
                json.dump(manifest, open(os.path.join(outdir, "_images.json"), "w"), indent=1)
                return count
    if manifest:
        json.dump(manifest, open(os.path.join(outdir, "_images.json"), "w"), indent=1)
    return count


def extract_links(doc):
    links = set()
    for pno in range(doc.page_count):
        for l in doc[pno].get_links():
            u = l.get("uri")
            if u:
                links.add(u)
    return sorted(links)


def frontmatter(src, npages, nimg, nlinks):
    return "\n".join([
        "---",
        f"id: sources/{src['id']}/text",
        "type: source-raw",
        f"source: {src['id']}",
        f"title: {json.dumps(src.get('title', src['id']), ensure_ascii=False)}",
        f"source_file: {json.dumps('input/references/'+src['file'])}",
        f"lang: {src.get('lang','')}",
        f"mode: {src.get('mode','text')}",
        f"pages: {npages}",
        f"images_extracted: {nimg}",
        f"links: {nlinks}",
        f"themes: {json.dumps(src.get('themes', []))}",
        "status: raw" + ("-ocr" if src.get("mode") == "ocr" else ""),
        "---", ""])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("manifest"); ap.add_argument("vault")
    ap.add_argument("--only"); ap.add_argument("--force", action="store_true")
    ap.add_argument("--dpi", type=int, default=200)
    args = ap.parse_args()
    import fitz
    sources = json.load(open(args.manifest, encoding="utf-8"))
    ocr = None

    for src in sources:
        if args.only and src["id"] != args.only:
            continue
        outdir = os.path.join(args.vault, "sources", src["id"])
        os.makedirs(outdir, exist_ok=True)
        textmd = os.path.join(outdir, "text.md")
        if os.path.exists(textmd) and not args.force:
            print(f"[skip] {src['id']} (exists)"); continue

        path = os.path.join("input/references", src["file"])
        t0 = time.time()

        if src.get("mode") == "txt":
            raw = open(path, encoding="utf-8", errors="replace").read()
            open(textmd, "w", encoding="utf-8").write(
                frontmatter(src, 1, 0, 0) + f"# {src.get('title', src['id'])}\n\n" + raw)
            print(f"[txt]  {src['id']} ({len(raw)} chars, {time.time()-t0:.0f}s)")
            continue

        doc = fitz.open(path); pc = doc.page_count
        nimg = 0
        if src.get("images"):
            nimg = extract_images(doc, src["id"], args.vault)
        links = extract_links(doc)

        pages_txt = []
        if src.get("mode") == "ocr":
            if ocr is None:
                from rapidocr_onnxruntime import RapidOCR
                import numpy as np
                ocr = RapidOCR(); globals()["np"] = np
            for i in range(pc):
                pix = doc[i].get_pixmap(dpi=args.dpi)
                import numpy as np
                arr = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, pix.n)
                if pix.n == 4:
                    arr = arr[:, :, :3]
                res, _ = ocr(arr)
                pages_txt.append(order_page_ocr(res, pix.width) if res else "")
                if (i+1) % 10 == 0:
                    print(f"   [{src['id']}] OCR {i+1}/{pc} ({time.time()-t0:.0f}s)", flush=True)
        else:
            for i in range(pc):
                pages_txt.append(text_of_page(doc[i]))

        body = "\n\n---\n\n".join(f"<!-- pdf page {i+1} -->\n\n{t}".rstrip()
                                 for i, t in enumerate(pages_txt))
        open(textmd, "w", encoding="utf-8").write(
            frontmatter(src, pc, nimg, len(links))
            + f"# {src.get('title', src['id'])} — raw text\n\n" + body + "\n")
        if links:
            open(os.path.join(outdir, "links.md"), "w", encoding="utf-8").write(
                f"# Links extracted from {src['id']}\n\n" + "\n".join(f"- {u}" for u in links) + "\n")
        doc.close()
        chars = sum(len(t) for t in pages_txt)
        print(f"[{src.get('mode','text')}] {src['id']} | {pc}pp {chars}chars "
              f"{nimg}img {len(links)}links ({time.time()-t0:.0f}s)")


if __name__ == "__main__":
    main()
