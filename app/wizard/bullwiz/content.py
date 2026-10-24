"""Compile the bull wiki into the app's content bundle (PROC-CNT-001).

The wiki stays the single source (STRAT-OBJ-003). This module only reads it:
narrative pages become ordered chapters and sections, entity pages become
browsable reference pages, translation sidecars supply the other languages,
and figures are kept only when the rights registry clears their image.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml

from . import paths

UNIT_MARKER = re.compile(r"^<!--\s*u:(?P<uid>u\d+)\s+kind:(?P<kind>[\w-]+)\s*-->\s*$")
IMAGE = re.compile(r"!\[[^\]]*\]\((?P<path>[^)\s]+)\)")
CAPTION = re.compile(r"^\*(?P<text>.+)\*\s*$")
WIKILINK = re.compile(r"\[\[(?P<target>[^\]|]+)(?:\|(?P<label>[^\]]+))?\]\]")
MDLINK = re.compile(r"(?<!!)\[(?P<label>[^\]]+)\]\([^)]+\)")
EMPHASIS = re.compile(r"(\*\*|__|\*|_)(?=\S)(.+?)(?<=\S)\1")
UNESCAPED_PIPE = re.compile(r"(?<!\\)\|")


@dataclass
class Unit:
    uid: str
    kind: str
    text: dict[str, str] = field(default_factory=dict)
    rows: dict[str, list[list[str]]] = field(default_factory=dict)
    images: list[str] = field(default_factory=list)   # wiki-relative paths (assets/...)
    caption: dict[str, str] = field(default_factory=dict)


@dataclass
class Section:
    id: str
    chapter: str
    chapter_label: str
    order: int
    level: int
    title: dict[str, str]
    units: list[Unit]


def split_frontmatter(raw: str) -> tuple[dict[str, Any], str]:
    if not raw.startswith("---"):
        return {}, raw
    end = raw.find("\n---", 3)
    if end == -1:
        return {}, raw
    meta = yaml.safe_load(raw[3:end]) or {}
    body = raw[end + 4:].lstrip("\n")
    return meta, body


def clean_inline(text: str) -> str:
    """Strip wiki and markdown inline syntax down to readable text."""
    def wikilink(m: re.Match[str]) -> str:
        if m.group("label"):
            return m.group("label")
        return m.group("target").rstrip("/").split("/")[-1].replace("-", " ")

    text = WIKILINK.sub(wikilink, text)
    text = MDLINK.sub(lambda m: m.group("label"), text)
    text = EMPHASIS.sub(lambda m: m.group(2), text)
    return text.replace("`", "")


def clean_block(text: str) -> str:
    lines = []
    for line in text.strip().splitlines():
        line = IMAGE.sub("", line).rstrip()
        if line.startswith("<!--"):
            continue
        lines.append(clean_inline(line))
    return "\n".join(lines).strip()


def parse_table(text: str) -> list[list[str]]:
    rows = []
    for line in text.strip().splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip().replace("\\|", "|") for c in UNESCAPED_PIPE.split(line.strip("|"))]
        if all(re.fullmatch(r":?-{2,}:?", c) for c in cells if c):
            continue                                   # header separator row
        rows.append([clean_inline(c) for c in cells])
    return rows


def resolve_image(page: Path, ref: str) -> str | None:
    """Return the image path relative to wiki/ (e.g. 'assets/media/image1.png')."""
    target = (page.parent / ref).resolve()
    try:
        return target.relative_to(paths.WIKI.resolve()).as_posix()
    except ValueError:
        return None


def parse_units(page: Path, body: str) -> list[Unit]:
    units: list[Unit] = []
    current: Unit | None = None
    buf: list[str] = []

    def flush() -> None:
        if current is None:
            return
        block = "\n".join(buf)
        for img in IMAGE.finditer(block):
            resolved = resolve_image(page, img.group("path"))
            if resolved and resolved not in current.images:
                current.images.append(resolved)
        if current.kind == "figure":
            caps = [CAPTION.match(line.strip()) for line in block.splitlines()]
            caption = next((c.group("text") for c in caps if c), "")
            if caption:
                current.caption["en"] = clean_inline(caption)
        elif current.kind == "table":
            current.rows["en"] = parse_table(block)
            rest = "\n".join(line for line in block.splitlines() if not line.strip().startswith("|"))
            if rest.strip():
                current.text["en"] = clean_block(rest)
        else:
            current.text["en"] = clean_block(block)
        units.append(current)

    for line in body.splitlines():
        marker = UNIT_MARKER.match(line.strip())
        if marker:
            flush()
            current = Unit(uid=marker.group("uid"), kind=marker.group("kind"))
            buf = []
        elif current is not None:
            buf.append(line)
    flush()
    return units


def apply_sidecar(page: Path, title: dict[str, str], units: list[Unit], languages: list[str]) -> None:
    sidecar = page.with_name(page.stem + ".i18n.yml")
    if not sidecar.exists():
        return
    data = yaml.safe_load(sidecar.read_text(encoding="utf-8")) or {}
    for lang, value in (data.get("title") or {}).items():
        if lang in languages and value:
            title[lang] = clean_inline(str(value))
    entries = data.get("units") or {}
    for unit in units:
        entry = entries.get(unit.uid) or {}
        for lang in languages:
            tr = entry.get(lang)
            if not isinstance(tr, dict) or tr.get("status") != "ok" or not tr.get("text"):
                continue
            text = str(tr["text"])
            if unit.kind == "figure":
                unit.caption[lang] = clean_inline(text.strip().strip("*"))
            elif unit.kind == "table":
                rows = parse_table(text)
                if rows:
                    unit.rows[lang] = rows
                else:
                    unit.text[lang] = clean_block(text)
            else:
                unit.text[lang] = clean_block(text)


def load_sections(languages: list[str], narrative: Path | None = None) -> list[Section]:
    root = narrative or paths.NARRATIVE
    sections = []
    for page in sorted(root.glob("*/*.md")):
        meta, body = split_frontmatter(page.read_text(encoding="utf-8"))
        if meta.get("type") != "narrative-section":
            continue
        title = {"en": clean_inline(str((meta.get("title") or {}).get("en", page.stem)))}
        units = parse_units(page, body)
        apply_sidecar(page, title, units, [lang for lang in languages if lang != "en"])
        sections.append(Section(
            id=str(meta.get("id", page.relative_to(root.parent).with_suffix("").as_posix())),
            chapter=page.parent.name,
            chapter_label=clean_inline(str(meta.get("chapter", page.parent.name))),
            order=int(meta.get("order", 0)),
            level=int(meta.get("level", 2)),
            title=title,
            units=units,
        ))
    sections.sort(key=lambda s: s.order)
    return sections


def load_entities(entities: Path | None = None) -> list[dict[str, Any]]:
    root = entities or paths.ENTITIES
    out = []
    for page in sorted(root.rglob("*.md")):
        if page.name.lower() == "readme.md":
            continue
        meta, body = split_frontmatter(page.read_text(encoding="utf-8"))
        titles = meta.get("title") or {}
        if not isinstance(titles, dict):
            titles = {"en": str(titles)}
        body = re.sub(r"^#\s+.*\n", "", body, count=1)          # title is shown separately
        out.append({
            "id": str(meta.get("id", page.relative_to(root.parent).with_suffix("").as_posix())),
            "type": str(meta.get("type", page.parent.name)),
            # entities/references/books/x.md -> group "references", subgroup "books" (bull DR-014)
            "group": page.relative_to(root).parts[0],
            "subgroup": "/".join(page.relative_to(root).parts[1:-1]),
            "title": {k: clean_inline(str(v)) for k, v in titles.items() if v},
            "text": {"en": clean_block(body)},
        })
    return out


def coverage(sections: list[Section], lang: str) -> float:
    """Share of translatable units that have an 'ok' translation in `lang`."""
    total = done = 0
    for s in sections:
        for u in s.units:
            if u.kind == "figure":
                if "en" in u.caption:
                    total += 1
                    done += lang in u.caption
            elif u.text.get("en") or u.rows.get("en"):
                total += 1
                done += lang in u.text or lang in u.rows
    return done / total if total else 0.0


def referenced_images(sections: list[Section]) -> list[str]:
    seen: dict[str, None] = {}
    for s in sections:
        for u in s.units:
            for img in u.images:
                seen.setdefault(img, None)
    return list(seen)
