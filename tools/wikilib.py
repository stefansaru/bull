"""Shared helpers for tools that read or generate wiki pages.

Generated pages carry `generated_by: tools/<script>.py` in their frontmatter.
`write_generated` overwrites only pages that still carry that key: deleting the
key hands the page over to human editing, and the generator then leaves it alone.
"""

from __future__ import annotations

import re
import unicodedata
from pathlib import Path
from typing import Any

import yaml

REPO = Path(__file__).resolve().parents[1]
WIKI = REPO / "wiki"

WIKILINK = re.compile(r"\[\[(?P<target>[^\]|#]+)(?:#[^\]|]*)?(?:\|(?P<label>[^\]]+))?\]\]")


class HandOwnedPage(Exception):
    """Raised when a generator would overwrite a page a human has taken over."""


def split_frontmatter(raw: str) -> tuple[dict[str, Any], str]:
    if not raw.startswith("---"):
        return {}, raw
    end = raw.find("\n---", 3)
    if end == -1:
        return {}, raw
    meta = yaml.safe_load(raw[3:end]) or {}
    return meta, raw[end + 4:].lstrip("\n")


def read_page(path: Path) -> tuple[dict[str, Any], str]:
    return split_frontmatter(path.read_text(encoding="utf-8"))


def dump_frontmatter(meta: dict[str, Any]) -> str:
    return yaml.safe_dump(meta, allow_unicode=True, sort_keys=False, width=100000).rstrip("\n")


def write_generated(path: Path, meta: dict[str, Any], body: str, generator: str) -> bool:
    """Write a generated page. Returns True if the file changed.

    Refuses (HandOwnedPage) when the existing page has no `generated_by` key.
    """
    if path.exists():
        old_meta, _ = read_page(path)
        if not old_meta.get("generated_by"):
            raise HandOwnedPage(f"{path} has no generated_by key; it is maintained by hand")
    meta = {**meta, "generated_by": generator}
    text = f"---\n{dump_frontmatter(meta)}\n---\n\n{body.rstrip()}\n"
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")
    return True


def slug(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = re.sub(r"[^A-Za-z0-9]+", "-", text).strip("-").lower()
    return text or "x"


class LinkResolver:
    """Resolve Obsidian-style wikilinks to wiki page ids (path under wiki/, no suffix).

    Three forms are in use: relative (`../issues/issue-bull-1`), root-relative
    (`meta/glossary`) and bare (`glossary`, unique file stem).
    """

    def __init__(self, wiki: Path = WIKI):
        self.wiki = wiki.resolve()
        self.pages: set[str] = set()
        stems: dict[str, list[str]] = {}
        for p in self.wiki.rglob("*.md"):
            pid = p.resolve().relative_to(self.wiki).with_suffix("").as_posix()
            self.pages.add(pid)
            stems.setdefault(p.stem.lower(), []).append(pid)
        self.unique_stems = {k: v[0] for k, v in stems.items() if len(v) == 1}

    def resolve(self, target: str, from_page: Path) -> str | None:
        target = target.strip().removesuffix(".md").rstrip("/")
        if not target:
            return None
        here = from_page.resolve().parent
        try:
            rel = (here / target).resolve().relative_to(self.wiki).as_posix()
            if rel in self.pages:
                return rel
            if f"{rel}/README" in self.pages:
                return f"{rel}/README"
        except ValueError:
            pass
        if target in self.pages:
            return target
        if f"{target}/README" in self.pages:
            return f"{target}/README"
        return self.unique_stems.get(target.split("/")[-1].lower())
