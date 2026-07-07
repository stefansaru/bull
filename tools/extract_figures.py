#!/usr/bin/env python3
"""
extract_figures.py -- Detect & crop illustrations from reference sources.

Two modes:

  photos  -- for a PHOTOGRAPHED book (a folder of page photos). Detects figure
             regions inside each page image with OpenCV and crops them: individual
             stamps/marks (small roundish ink blobs) AND whole plates/figures
             (clusters or large illustrations). Handles 2-page spreads by assigning
             each crop to the left/right printed page via the known cadence.

  pdf     -- for a text-layer PDF: extracts EMBEDDED raster images (PyMuPDF), the
             same way ingest_sources.py does.

Output: wiki/assets/sources/<id>/figures/<crop>.jpg  +  _figures.json manifest.

Usage:
  python extract_figures.py photos <image_dir> <id> wiki [--page0 PHOTO --page-num N]
  python extract_figures.py pdf    <pdf_path>  <id> wiki
"""
import sys, os, re, json, glob, argparse

MIN_IMG_BYTES = 6000


# ---------- photos (OpenCV figure detection) ----------

def detect_figures(img, cv2, np):
    """Return (stamps, plates, bigfigs) as lists of (x,y,w,h) on the full image."""
    h, w = img.shape[:2]
    g = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    th = cv2.adaptiveThreshold(g, 255, cv2.ADAPTIVE_THRESH_MEAN_C,
                               cv2.THRESH_BINARY_INV, 51, 15)
    # close just enough to fill each stamp ring+interior into one blob WITHOUT
    # bridging to neighbours (9x1 tuned on the p.23 handstamp grid: 28/30 stamps)
    k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    closed = cv2.morphologyEx(th, cv2.MORPH_CLOSE, k, iterations=1)
    n, lab, stats, cent = cv2.connectedComponentsWithStats(closed, 8)
    stamps, bigfigs = [], []
    for i in range(1, n):
        x, y, ww, hh, area = stats[i]
        if ww > 0.95 * w or hh > 0.95 * h:
            continue
        fill = area / (ww * hh + 1e-6)
        ar = ww / (hh + 1e-6)
        # individual stamp/mark: roundish, mid-sized, solidly filled
        if 55 <= ww <= 340 and 55 <= hh <= 340 and 0.45 < ar < 2.2 and fill > 0.35 \
                and area > 3500:
            stamps.append((x, y, ww, hh))
        # large standalone illustration (facsimile doc, seal, form)
        elif area > 120000 and 0.2 < ar < 5 and fill > 0.30:
            bigfigs.append((x, y, ww, hh))
    # plates = clusters of >=4 stamps (union bbox of a proximity group)
    plates = cluster_boxes(stamps, gap=90, min_members=4)
    return stamps, plates, bigfigs


def cluster_boxes(boxes, gap, min_members):
    """Group boxes whose expanded rects overlap; return union bbox of big groups."""
    if not boxes:
        return []
    parent = list(range(len(boxes)))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]; a = parent[a]
        return a

    def union(a, b):
        parent[find(a)] = find(b)

    def near(A, B):
        ax, ay, aw, ah = A; bx, by, bw, bh = B
        return not (ax - gap > bx + bw or bx - gap > ax + aw or
                    ay - gap > by + bh or by - gap > ay + ah)
    for i in range(len(boxes)):
        for j in range(i + 1, len(boxes)):
            if near(boxes[i], boxes[j]):
                union(i, j)
    groups = {}
    for i in range(len(boxes)):
        groups.setdefault(find(i), []).append(boxes[i])
    out = []
    for g in groups.values():
        if len(g) >= min_members:
            xs = [b[0] for b in g]; ys = [b[1] for b in g]
            xe = [b[0] + b[2] for b in g]; ye = [b[1] + b[3] for b in g]
            out.append((min(xs), min(ys), max(xe) - min(xs), max(ye) - min(ys)))
    return out


def pad_crop(img, box, pad=0.10):
    h, w = img.shape[:2]
    x, y, ww, hh = box
    px, py = int(ww * pad), int(hh * pad)
    x0, y0 = max(0, x - px), max(0, y - py)
    x1, y1 = min(w, x + ww + px), min(h, y + hh + py)
    return img[y0:y1, x0:x1]


def page_of(photo_idx, cx, mid, page0, page_num):
    """Printed page for a crop, from the verified spread cadence.
    Anchor: photo `page0` left half = printed page `page_num` (even)."""
    base = page_num + 2 * (photo_idx - page0)   # left (even) page of this spread
    pg = base if cx < mid else base + 1
    return max(0, pg)                            # 0 = front matter (before pagination)


def run_photos(image_dir, sid, vault, page0, page_num):
    import cv2, numpy as np
    files = sorted(f for f in glob.glob(os.path.join(image_dir, "*"))
                   if f.lower().endswith((".jpg", ".jpeg", ".png")))
    outdir = os.path.join(vault, "assets", "sources", sid, "figures")
    os.makedirs(outdir, exist_ok=True)
    manifest = []
    nstamp = nplate = nbig = 0
    for idx, path in enumerate(files, start=1):
        img = cv2.imread(path)
        if img is None:
            continue
        h, w = img.shape[:2]; mid = w / 2
        stamps, plates, bigfigs = detect_figures(img, cv2, np)
        # plates first
        for pi, box in enumerate(plates, 1):
            cx = box[0] + box[2] / 2
            pg = page_of(idx, cx, mid, page0, page_num)
            name = f"p{pg:03d}_photo{idx:02d}_plate{pi:02d}.jpg"
            cv2.imwrite(os.path.join(outdir, name), pad_crop(img, box, 0.03))
            manifest.append({"file": name, "photo": idx, "page": pg, "kind": "plate",
                             "bbox": [int(v) for v in box]}); nplate += 1
        for fi, box in enumerate(bigfigs, 1):
            cx = box[0] + box[2] / 2
            pg = page_of(idx, cx, mid, page0, page_num)
            name = f"p{pg:03d}_photo{idx:02d}_fig{fi:02d}.jpg"
            cv2.imwrite(os.path.join(outdir, name), pad_crop(img, box, 0.05))
            manifest.append({"file": name, "photo": idx, "page": pg, "kind": "figure",
                             "bbox": [int(v) for v in box]}); nbig += 1
        # individual stamps
        si = 0
        for box in sorted(stamps, key=lambda b: (b[1] // 120, b[0])):
            si += 1
            cx = box[0] + box[2] / 2
            pg = page_of(idx, cx, mid, page0, page_num)
            name = f"p{pg:03d}_photo{idx:02d}_stamp{si:02d}.jpg"
            cv2.imwrite(os.path.join(outdir, name), pad_crop(img, box, 0.15))
            manifest.append({"file": name, "photo": idx, "page": pg, "kind": "stamp",
                             "bbox": [int(v) for v in box]}); nstamp += 1
    json.dump(manifest, open(os.path.join(outdir, "_figures.json"), "w",
              encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"[photos] {sid}: {len(files)} pages -> {nstamp} stamps, {nplate} plates, "
          f"{nbig} figures  ({len(manifest)} crops) -> {outdir}")


# ---------- pdf (embedded raster extraction) ----------

def run_pdf(pdf_path, sid, vault):
    import fitz
    doc = fitz.open(pdf_path)
    outdir = os.path.join(vault, "assets", "sources", sid)
    os.makedirs(outdir, exist_ok=True)
    seen = set(); manifest = []
    for pno in range(doc.page_count):
        for img in doc[pno].get_images(full=True):
            xref = img[0]
            if xref in seen:
                continue
            seen.add(xref)
            try:
                ext = doc.extract_image(xref)
                data, e = ext["image"], ext["ext"]
            except Exception:
                continue
            if len(data) < MIN_IMG_BYTES:
                continue
            name = f"p{pno+1:04d}_x{xref}.{e}"
            open(os.path.join(outdir, name), "wb").write(data)
            manifest.append({"file": name, "page": pno + 1, "bytes": len(data)})
    if manifest:
        json.dump(manifest, open(os.path.join(outdir, "_images.json"), "w"), indent=1)
    print(f"[pdf] {sid}: {len(manifest)} embedded images -> {outdir}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["photos", "pdf"])
    ap.add_argument("path"); ap.add_argument("id"); ap.add_argument("vault")
    ap.add_argument("--page0", type=int, default=15)     # anchor photo
    ap.add_argument("--page-num", type=int, default=22)  # its left (even) printed page
    args = ap.parse_args()
    if args.mode == "photos":
        run_photos(args.path, args.id, args.vault, args.page0, args.page_num)
    else:
        run_pdf(args.path, args.id, args.vault)


if __name__ == "__main__":
    main()
