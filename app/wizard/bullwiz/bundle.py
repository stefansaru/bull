"""Write the content bundle the Flutter app loads (assets/content/)."""

from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from PIL import Image

from . import paths
from . import links
from .content import Section, summary_of

SCHEMA = 2

INDEX_TITLES = {
    "index/images": {"en": "Images", "ro": "Imagini", "fr": "Images", "de": "Bilder"},
    "index/abbreviations": {"en": "Abbreviations", "ro": "Abrevieri", "fr": "Abréviations", "de": "Abkürzungen"},
    "index/colours": {"en": "Colours", "ro": "Culori", "fr": "Couleurs", "de": "Farben"},
    "index/calendars": {"en": "Calendars", "ro": "Calendare", "fr": "Calendriers", "de": "Kalender"},
}
CALENDAR_CONCEPTS = [links.JULIAN, links.GREGORIAN, links.DUAL_DATE]


@dataclass
class BundleResult:
    languages: list[str]
    sections: int
    entities: int
    images_shipped: int
    images_dropped: int
    size_mb: float


def git_commit() -> str:
    try:
        return subprocess.run(["git", "-C", str(paths.REPO), "rev-parse", "--short", "HEAD"],
                              capture_output=True, text=True, check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def bundled_name(src: str) -> str:
    """'assets/media/image219.jpg' -> 'img/media__image219.webp'.

    Flat on purpose: a Flutter asset directory entry is not recursive, so one
    folder means one pubspec line however the wiki organises its images.
    """
    rel = Path(src).relative_to("assets") if src.startswith("assets/") else Path(src)
    return "img/" + "__".join(rel.with_suffix(".webp").parts)


def convert_image(src: Path, dst: Path, max_edge: int, quality: int) -> None:
    if dst.exists() and dst.stat().st_mtime >= src.stat().st_mtime:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as im:
        im = im.convert("RGBA") if im.mode in ("P", "LA") else im
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGB")
        im.thumbnail((max_edge, max_edge), Image.Resampling.LANCZOS)
        im.save(dst, "WEBP", quality=quality, method=6)


def unit_json(unit, languages: list[str], shipped: set[str]) -> dict[str, Any] | None:
    pick = lambda d: {k: v for k, v in d.items() if k in languages and v}  # noqa: E731
    images = [bundled_name(i) for i in unit.images if i in shipped]
    if unit.kind == "figure":
        if not images:
            return None                      # a caption without its picture says nothing
        return {"uid": unit.uid, "kind": "figure", "images": images, "caption": pick(unit.caption)}
    out: dict[str, Any] = {"uid": unit.uid, "kind": unit.kind, "text": pick(unit.text)}
    if unit.rows:
        out["rows"] = pick(unit.rows)
        if unit.head:
            out["head"] = unit.head
    if images:
        out["images"] = images
    if not out["text"] and not out.get("rows") and not images:
        return None
    return out


def entity_json(e: dict[str, Any], languages: list[str]) -> dict[str, Any]:
    pick = lambda d: {k: v for k, v in d.items() if k in languages and v}  # noqa: E731
    out = {k: v for k, v in e.items() if k not in ("page_id", "see_id") and v not in ("", [], {})}
    out["title"] = pick(e["title"])
    if e.get("summary"):
        out["summary"] = pick(e["summary"])
    if "expansion" in e:
        out["expansion"] = pick(e["expansion"])
    return out


def write(sections: list[Section], entities: list[dict[str, Any]], languages: list[str],
          shipped_images: list[str], cfg: dict[str, Any], out: Path | None = None) -> BundleResult:
    out = out or paths.BUNDLE
    if out.exists():
        # Images no longer cleared must not linger in the bundle.
        keep = {(out / bundled_name(i)).resolve() for i in shipped_images}
        for f in (out / "img").glob("*") if (out / "img").exists() else []:
            if f.is_file() and not f.name.startswith(".") and f.resolve() not in keep:
                f.unlink()
    # The folder must exist even with no cleared image: pubspec declares it.
    (out / "img").mkdir(parents=True, exist_ok=True)

    shipped = set(shipped_images)
    for img in shipped_images:
        convert_image(paths.WIKI / img, out / bundled_name(img),
                      int(cfg.get("image_max_edge", 2048)), int(cfg.get("image_quality", 82)))

    chapters: list[dict[str, Any]] = []
    dropped = 0
    sec_json = []
    images: list[dict[str, Any]] = []
    for s in sections:
        units = []
        for u in s.units:
            j = unit_json(u, languages, shipped)
            dropped += sum(1 for i in u.images if i not in shipped)
            if j is None:
                continue
            units.append(j)
            for file in j.get("images", []):
                images.append({"id": Path(file).stem, "number": len(images) + 1, "file": file,
                               "caption": j.get("caption", {}), "unit": u.uid, "section": s.id})
        if not chapters or chapters[-1]["id"] != s.chapter:
            chapters.append({"id": s.chapter, "label": s.chapter_label, "sections": []})
        chapters[-1]["sections"].append(s.id)
        summary = summary_of([u.text.get("en", "") for u in s.units if u.kind in ("text", "quad")])
        entry = {"id": s.id, "chapter": s.chapter, "order": s.order, "level": s.level,
                 "title": {k: v for k, v in s.title.items() if k in languages},
                 "summary": {"en": summary} if summary else {}, "units": units}
        if s.year:
            entry["year"] = s.year
        sec_json.append(entry)

    calendar_sections = [s.id for s in sections if s.chapter.endswith("-calendar")]
    entity_ids = {e["id"] for e in entities}
    indexes = [{"id": iid, "title": {k: v for k, v in t.items() if k in languages}}
               for iid, t in INDEX_TITLES.items()]
    indexes[-1]["items"] = [i for i in CALENDAR_CONCEPTS if i in entity_ids] + calendar_sections

    doc = {
        "schema": SCHEMA,
        "generated": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source_commit": git_commit(),
        "languages": languages,
        "chapters": chapters,
        "sections": sec_json,
        "entities": [entity_json(e, languages) for e in entities],
        "images": images,
        "indexes": indexes,
    }
    (out / "content.json").write_text(json.dumps(doc, ensure_ascii=False, separators=(",", ":")),
                                      encoding="utf-8")
    size = sum(f.stat().st_size for f in out.rglob("*") if f.is_file()) / 1_048_576
    return BundleResult(languages, len(sec_json), len(entities), len(shipped), dropped, round(size, 1))


def clean(out: Path | None = None) -> None:
    shutil.rmtree(out or paths.BUNDLE, ignore_errors=True)
