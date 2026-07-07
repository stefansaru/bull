#!/usr/bin/env python3
"""
pdf_ocr.py -- OCR a scanned catalogue into the same cache format as pdf_scan.py.

Renders each page to an image, runs RapidOCR (ONNX, CPU), and writes
work/cat_txt/<name>.jsonl with {page, relevant, text, ocr:true} — so census.py can
consume OCR'd catalogues exactly like text-layer ones. Resumable: pages already in
the cache are skipped.

Usage:
  python pdf_ocr.py input/catalogues/<file>.pdf work/cat_txt [--dpi 200]
"""
import sys, os, re, json, argparse, time
import numpy as np
import fitz
from rapidocr_onnxruntime import RapidOCR

# broadened for OCR (spaces are often dropped by OCR)
P_BULL = re.compile(r"bull'?\s*s?\s*head|cap de bour|ochsenk|moldau|moldav|wallach|valach", re.I)
P_DENOM = re.compile(r"\b(\d{1,3})\s*(?:pa\.?|parale)\b", re.I)
P_KIRIAC = re.compile(r"kiriac", re.I)
P_PM = re.compile(r"datestamp|date stamp|\bds\b|cancel|postmark|oblit|franco|franko|"
                  r"double[- ]?circle|grid|handstamp", re.I)


def relevant(t):
    return bool((P_DENOM.search(t) and P_BULL.search(t)) or P_KIRIAC.search(t)
                or (P_BULL.search(t) and P_PM.search(t)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("outdir")
    ap.add_argument("--dpi", type=int, default=200)
    args = ap.parse_args()
    os.makedirs(args.outdir, exist_ok=True)
    name = os.path.splitext(os.path.basename(args.pdf))[0]
    cache = os.path.join(args.outdir, name + ".jsonl")

    done = {}
    if os.path.exists(cache):
        for line in open(cache, encoding="utf-8"):
            try:
                r = json.loads(line)
                if r.get("ocr"):
                    done[r["page"]] = line
            except Exception:
                pass

    ocr = RapidOCR()
    d = fitz.open(args.pdf)
    pc = d.page_count
    t0 = time.time()
    rel = 0
    with open(cache, "w", encoding="utf-8") as f:
        for i in range(pc):
            if i in done:
                f.write(done[i])
                if json.loads(done[i]).get("relevant"):
                    rel += 1
                continue
            pix = d[i].get_pixmap(dpi=args.dpi)
            img = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, pix.n)
            if pix.n == 4:
                img = img[:, :, :3]
            res, _ = ocr(img)
            text = "\n".join(r[1] for r in res) if res else ""
            r = relevant(text)
            if r:
                rel += 1
            json.dump({"page": i, "relevant": r, "text": text, "ocr": True}, f, ensure_ascii=False)
            f.write("\n")
            f.flush()
            if (i + 1) % 10 == 0:
                el = time.time() - t0
                print(f"  {i+1}/{pc} pages | {rel} relevant | {el:.0f}s "
                      f"({el/(i+1):.1f}s/pg)", flush=True)
    print(f"done: {name} | {pc} pages | {rel} relevant | {time.time()-t0:.0f}s -> {cache}")


if __name__ == "__main__":
    main()
