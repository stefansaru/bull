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

from . import links, paths

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
    head: int = 0                                     # header rows of a table (before |---|)


@dataclass
class Section:
    id: str
    chapter: str
    chapter_label: str
    order: int
    level: int
    title: dict[str, str]
    units: list[Unit]
    page_id: str = ""
    year: str = ""


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
    """Strip wiki and markdown inline syntax; wikilinks become `⟦page-id|label⟧` links."""
    text = WIKILINK.sub(lambda m: links.wikilink(m.group("target"), m.group("label")), text)
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


def table_head(text: str) -> int:
    """Number of header rows: the rows above the |---| separator (0 if none)."""
    seen = 0
    for line in text.strip().splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in UNESCAPED_PIPE.split(line.strip("|"))]
        if all(re.fullmatch(r":?-{2,}:?", c) for c in cells if c):
            return seen
        seen += 1
    return 0


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
            current.head = table_head(block)
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
        token = links.current_page.set(page)
        title = {"en": links.strip(clean_inline(str((meta.get("title") or {}).get("en", page.stem))))}
        units = parse_units(page, body)
        apply_sidecar(page, title, units, [lang for lang in languages if lang != "en"])
        links.current_page.reset(token)
        title = {k: links.strip(v) for k, v in title.items()}
        sections.append(Section(
            id=str(meta.get("id", page.relative_to(root.parent).with_suffix("").as_posix())),
            chapter=page.parent.name,
            chapter_label=clean_inline(str(meta.get("chapter", page.parent.name))),
            order=int(meta.get("order", 0)),
            level=int(meta.get("level", 2)),
            title=title,
            units=units,
            page_id=page_id(page),
            year=year_of(title["en"]),
        ))
    sections.sort(key=lambda s: s.order)
    return sections


def page_id(page: Path) -> str:
    return page.resolve().relative_to(paths.WIKI.resolve()).with_suffix("").as_posix()


YEAR_RANGE = re.compile(r"^(?P<a>1[5-9]\d\d)(?:\s*[–-]\s*(?P<b>1[5-9]\d\d))?\b")
YEAR_MARKER = re.compile(r"📅\s*(?P<a>1[5-9]\d\d)(?:\s*[–-]\s*(?P<b>1[5-9]\d\d))?")


def year_of(title: str) -> str:
    """A section's time: a leading year or range in its title, or a 📅 year marker."""
    m = YEAR_RANGE.match(title.strip()) or YEAR_MARKER.search(title)
    if not m:
        return ""
    return f"{m.group('a')}–{m.group('b')}" if m.group("b") else m.group("a")


def summary_of(texts: list[str], limit: int = 240) -> str:
    """First paragraph, cut at a sentence (or word) boundary near `limit` characters."""
    for t in texts:
        for para in links.strip(t).split("\n"):
            para = para.strip()
            if not para or para.startswith(("#", "|")) or len(para) < 20:
                continue
            if len(para) <= limit:
                return para
            cut = para[:limit]
            end = max(cut.rfind(". "), cut.rfind("; "))
            return cut[:end + 1] if end > limit // 2 else cut[:cut.rfind(" ")] + " …"
    return ""


# Frontmatter keys that hold typed relations, in the order Related lists them, with the
# relation label the app shows (UIC-ART-05).
RELATION_KEYS = {"related": "related", "see": "see", "issue": "issue", "denominations": "denomination",
                 "handstamps": "handstamp", "series": "series", "in": "published in",
                 "narrative_refs": "in the book", "refs": "reference"}
PASS_THROUGH = {"color": ("hex", "family", "swatches"),
                "abbreviation": ("abbr", "forms", "category", "expansion")}


def entity_units(body: str, entity_id: str) -> list[dict[str, Any]]:
    """Split an entity body into heading / text / list / table units.

    Unit ids are positional (`<entity-id>#<n>`): stable while the page keeps its shape.
    """
    blocks: list[tuple[str, list[str]]] = []
    for line in body.strip().splitlines():
        s = line.strip()
        kind = ("blank" if not s else "heading" if s.startswith("#") else "table" if s.startswith("|")
                else "list" if re.match(r"^([-*+]|\d+\.)\s", s) else "text")
        if s.startswith("<!--") or kind == "blank":
            blocks.append(("blank", []))
            continue
        if kind == "heading" or not blocks or blocks[-1][0] != kind:
            blocks.append((kind, [line]))
        else:
            blocks[-1][1].append(line)
    units = []
    for kind, lines in blocks:
        if kind == "blank" or not lines:
            continue
        uid = f"{entity_id}#{len(units) + 1}"
        raw = "\n".join(lines)
        if kind == "table":
            rows = parse_table(raw)
            if rows:
                units.append({"uid": uid, "kind": "table", "rows": {"en": rows}, "head": table_head(raw)})
            continue
        if kind == "text":
            raw = " ".join(line.strip() for line in lines)             # one paragraph
        text = clean_block(raw)
        if text:
            units.append({"uid": uid, "kind": kind, "text": {"en": text}})
    return units


def wikilinks_of(value: Any) -> list[tuple[str, str | None]]:
    items = value if isinstance(value, list) else [value]
    found = []
    for item in items:
        if isinstance(item, str):
            found += [(m.group("target"), m.group("label")) for m in WIKILINK.finditer(item)]
    return found


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
        eid = str(meta.get("id", page.relative_to(root.parent).with_suffix("").as_posix()))
        etype = str(meta.get("type", page.parent.name))
        token = links.current_page.set(page)
        units = entity_units(body, eid)
        related = []
        for key, rel in RELATION_KEYS.items():
            for target, _label in wikilinks_of(meta.get(key)):
                pid = links.resolver().resolve(target, page)
                if pid:
                    related.append({"id": pid, "rel": rel})
        see = wikilinks_of(meta.get("see"))
        see_id = links.resolver().resolve(see[0][0], page) if see else None
        links.current_page.reset(token)
        entry: dict[str, Any] = {
            "id": eid,
            "page_id": page_id(page),
            "type": etype,
            # entities/references/books/x.md -> group "references", subgroup "books" (bull DR-014)
            "group": page.relative_to(root).parts[0],
            "subgroup": "/".join(page.relative_to(root).parts[1:-1]),
            "title": {k: links.strip(clean_inline(str(v))) for k, v in titles.items() if v},
            "summary": {"en": str(meta.get("summary") or "").strip()
                        or summary_of([u["text"]["en"] for u in units if u["kind"] == "text"])},
            "year": str(meta.get("year") or meta.get("date") or ""),
            "units": units,
            "related": related,
        }
        if meta.get("marker"):
            entry["marker"] = str(meta["marker"])
        if see_id:
            entry["see_id"] = see_id
        for key in PASS_THROUGH.get(etype, ()):
            if key in meta:
                entry[key] = meta[key]
        out.append(entry)
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
