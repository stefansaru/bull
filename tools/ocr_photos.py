#!/usr/bin/env python3
"""
ocr_photos.py -- OCR a folder of page PHOTOS (jpg/png) into a raw source (DR-011).

For books that were photographed (not scanned to PDF). Runs RapidOCR (ONNX, CPU)
over every image in filename order, reusing the column-aware line ordering from
ingest_sources.py. Phone photos are shot in mixed orientation, so:
  - portrait images (h > w) are OCR'd as-is;
  - landscape images (w > h) are OCR'd at 0/90/270 and the variant with the highest
    summed detection confidence is kept (handles both 2-page spreads / wide tables,
    which read best at 0, and single pages shot sideways, which need 90/270).
The chosen rotation is recorded per page.

Writes wiki/sources/<id>/text.md, page-delimited `<!-- photo N: <file> (rotR) -->`,
frontmatter matching ingest_sources.py (type: source-raw, status: raw-ocr).
Resumable: caches per-image OCR to work/ocr/<id>.jsonl; re-run to resume; --force redoes.

Usage:
  python ocr_photos.py <image_dir> <id> wiki \
      --title "Wertheimer & Ghika, Cartea marcilor Cap de bou (1944)" \
      --lang ro --themes bull-head,postal-history --source-file input/references/<dir>
"""
import sys, os, re, json, argparse, time, glob

IMG_EXT = (".jpg", ".jpeg", ".png", ".tif", ".tiff", ".webp")


def order_page_ocr(res, page_w):
    """Column-aware reading order (copied from ingest_sources.py)."""
    items = []
    for box, text, conf in res:
        xs = [p[0] for p in box]; ys = [p[1] for p in box]
        items.append(((min(xs) + max(xs)) / 2.0, min(ys), min(xs), text))
    if not items:
        return ""
    mid = page_w * 0.5
    left = [i for i in items if i[0] < mid]; right = [i for i in items if i[0] >= mid]
    if len(left) >= 4 and len(right) >= 4 and len(right) >= 0.2 * len(items):
        left.sort(key=lambda t: (t[1], t[2])); right.sort(key=lambda t: (t[1], t[2]))
        ordered = left + right
    else:
        ordered = sorted(items, key=lambda t: (t[1], t[2]))
    return "\n".join(t[3] for t in ordered)


def frontmatter(sid, title, source_file, lang, themes, npages):
    return "\n".join([
        "---",
        f"id: sources/{sid}/text",
        "type: source-raw",
        f"source: {sid}",
        f"title: {json.dumps(title, ensure_ascii=False)}",
        f"source_file: {json.dumps(source_file)}",
        f"lang: {lang}",
        "mode: ocr-photos",
        f"pages: {npages}",
        "images_extracted: 0",
        "links: 0",
        f"themes: {json.dumps(themes)}",
        "status: raw-ocr",
        "---", ""])


def ocr_image(ocr, np, Image, path):
    """OCR one image; return (text, rotation_chosen, nlines, avgconf)."""
    im = Image.open(path).convert("RGB")
    w, h = im.size
    rotations = [0] if h >= w else [0, 90, 270]
    best = ("", 0, 0, 0.0, -1.0)  # text, rot, nlines, avgconf, sumconf
    for rot in rotations:
        arr = np.array(im.rotate(rot, expand=True) if rot else im)
        res, _ = ocr(arr)
        if not res:
            continue
        confs = [float(r[2]) for r in res]
        sumc = sum(confs)
        if sumc > best[4]:
            text = order_page_ocr(res, arr.shape[1])
            best = (text, rot, len(res), sumc / len(confs), sumc)
    return best[0], best[1], best[2], best[3]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image_dir"); ap.add_argument("id"); ap.add_argument("vault")
    ap.add_argument("--title", default=""); ap.add_argument("--lang", default="")
    ap.add_argument("--themes", default="")
    ap.add_argument("--source-file", default="")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    import numpy as np
    from PIL import Image
    from rapidocr_onnxruntime import RapidOCR

    files = sorted(f for f in glob.glob(os.path.join(args.image_dir, "*"))
                   if f.lower().endswith(IMG_EXT))
    if not files:
        print("no images found in", args.image_dir); sys.exit(1)

    cache_dir = os.path.join("work", "ocr"); os.makedirs(cache_dir, exist_ok=True)
    cache = os.path.join(cache_dir, args.id + ".jsonl")
    done = {}
    if os.path.exists(cache) and not args.force:
        for line in open(cache, encoding="utf-8"):
            try:
                r = json.loads(line); done[r["file"]] = r
            except Exception:
                pass

    ocr = RapidOCR()
    t0 = time.time(); results = []
    fh = open(cache, "w", encoding="utf-8")
    for i, path in enumerate(files):
        base = os.path.basename(path)
        if base in done:
            r = done[base]
        else:
            try:
                text, rot, n, conf = ocr_image(ocr, np, Image, path)
            except Exception as e:
                text, rot, n, conf = f"[OCR ERROR: {type(e).__name__}: {e}]", 0, 0, 0.0
            r = {"page": i + 1, "file": base, "rot": rot, "lines": n,
                 "conf": round(conf, 3), "text": text}
        results.append(r)
        fh.write(json.dumps(r, ensure_ascii=False) + "\n"); fh.flush()
        if (i + 1) % 5 == 0 or i + 1 == len(files):
            el = time.time() - t0
            print(f"  {i+1}/{len(files)} | {base} rot{r['rot']} "
                  f"{r['lines']}ln conf{r['conf']} | {el:.0f}s "
                  f"({el/(i+1):.1f}s/img)", flush=True)
    fh.close()

    themes = [t.strip() for t in args.themes.split(",") if t.strip()]
    src_file = args.source_file or args.image_dir
    body = "\n\n---\n\n".join(
        f"<!-- photo {r['page']}: {r['file']} (rot{r['rot']}, {r['lines']}ln "
        f"conf{r['conf']}) -->\n\n{r['text']}".rstrip() for r in results)
    outdir = os.path.join(args.vault, "sources", args.id); os.makedirs(outdir, exist_ok=True)
    title = args.title or args.id
    open(os.path.join(outdir, "text.md"), "w", encoding="utf-8").write(
        frontmatter(args.id, title, src_file, args.lang, themes, len(files))
        + f"# {title} — raw OCR text\n\n" + body + "\n")
    chars = sum(len(r["text"]) for r in results)
    print(f"done: {args.id} | {len(files)} photos | {chars} chars "
          f"| {time.time()-t0:.0f}s -> {outdir}/text.md")


if __name__ == "__main__":
    main()
