#!/usr/bin/env python3
"""
extract_swatches.py -- Read the colour swatches from the source book.

The author records each colour as a small table in the "🎨 Colors" chapter of
input/20251208-stamps-book.docx: every cell names a colour standard (Pantone, RAL,
AMS, ...) with a short description, and is shaded with that colour. tools/extract.py
keeps only cell text, so the shading (the hex value) is read here, straight from the
document XML.

Output: work/extract/swatches.json — one record per colour section, in book order.
Usage: python tools/extract_swatches.py [book.docx] [out.json]
"""
import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
HEX = re.compile(r"^[0-9A-Fa-f]{6}$")

EXPECTED_COLOURS = 22
EXPECTED_SWATCHES = 46


def para_text(p):
    return "".join(t.text or "" for t in p.iter(f"{W}t")).strip()


def para_style(p):
    s = p.find(f"{W}pPr/{W}pStyle")
    return s.get(f"{W}val") if s is not None else ""


def cell_swatch(tc):
    shd = tc.find(f"{W}tcPr/{W}shd")
    fill = shd.get(f"{W}fill") if shd is not None else None
    paras = [p for p in tc.findall(f"{W}p") if para_text(p)]
    if not paras:
        return None
    lines = [para_text(p) for p in paras]
    styles = {para_style(p) for p in paras}
    return {
        "standard": lines[0],
        "description": " ".join(lines[1:]),
        "hex": fill.upper() if fill and HEX.match(fill) else None,
        "text_on_swatch": "white" if any(s.endswith("White") for s in styles) else "dark",
    }


def extract(docx):
    with zipfile.ZipFile(docx) as z:
        root = ET.fromstring(z.read("word/document.xml"))
    body = root.find(f"{W}body")
    colours, current, in_chapter = [], None, False
    for el in body:
        if el.tag == f"{W}p":
            style, text = para_style(el), para_text(el)
            if style == "Heading1":
                if in_chapter:
                    break                       # the next chapter ends the colours
                in_chapter = "Colors" in text
                continue
            if in_chapter and style == "Heading2" and text.startswith("🎨"):
                current = {"heading": text, "swatches": []}
                colours.append(current)
        elif el.tag == f"{W}tbl" and in_chapter and current is not None:
            for tc in el.iter(f"{W}tc"):
                sw = cell_swatch(tc)
                if sw:
                    current["swatches"].append(sw)
    return colours


def main():
    docx = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO / "input" / "20251208-stamps-book.docx"
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else REPO / "work" / "extract" / "swatches.json"
    colours = extract(docx)
    swatches = [s for c in colours for s in c["swatches"]]
    missing = [s["standard"] for s in swatches if not s["hex"]]
    print(f"{len(colours)} colours, {len(swatches)} swatches, {len(missing)} without a fill")
    if len(colours) != EXPECTED_COLOURS or len(swatches) != EXPECTED_SWATCHES or missing:
        print("unexpected shape; check the colour chapter:", missing, file=sys.stderr)
        sys.exit(1)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({"source": docx.name, "colours": colours}, ensure_ascii=False, indent=1),
                   encoding="utf-8")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
