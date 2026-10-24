"""Image rights registry and release gate (NORM-COPY-01, APP-CNT-003, PROC-RGT-001).

Registry: wiki/assets/rights.yml, keyed by the image path relative to wiki/.

    images:
      assets/media/image219.jpg:
        status: pending        # pending | cleared | omit
        source: references/books/dragomir-stampilografie-1990   # the reference it comes from (bull DR-014)
        locator: "fig. 412"    # page / figure / lot within that reference
        provenance: ""         # where the image comes from, when not covered by `source`
        licence: ""            # own work, public domain, permission (with reference), …
        note: ""

A reference page (wiki/entities/references/<kind>/<slug>.md) may declare
`assets:` (path prefixes of the images taken from it) and `rights_default:`
({status, licence, note}). An image whose own status is `pending` inherits its
source's default, so a whole source is cleared or omitted with one edit.

Only `cleared` images ship. `omit` is a recorded decision to leave the figure
out of the app. `pending` (or an image missing from the registry) blocks a
release; in a development run it is dropped with a warning instead.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

import yaml

from . import paths

STATUSES = ("pending", "cleared", "omit")

HEADER = """\
# Image rights registry — read by app/wizard (NORM-COPY-01, PROC-RGT-001, bull DR-014).
# One entry per image the wiki references, keyed by its path under wiki/.
# status: pending (default, blocks an app release) | cleared (ships) | omit (left out on purpose).
# source: the reference the image comes from (references/<kind>/<slug>); a `pending` image inherits
#   that reference's `rights_default`, so a whole source can be cleared or omitted at once.
# A `cleared` image needs provenance (or a source) and a licence (its own, or the source's default).
# Keep evidence of any permission outside the repository and cite it in `note`.
# New entries are added by `py -3 app/wizard/wizard.py --rights-init`; it only ever adds entries and
# fills an empty `source`; it never changes a status, provenance or licence.
"""


@dataclass
class Reference:
    id: str                                   # e.g. references/books/dragomir-stampilografie-1990
    title: str
    assets: list[str] = field(default_factory=list)
    default: dict = field(default_factory=dict)


@dataclass
class Verdict:
    cleared: list[str]
    omitted: list[str]
    pending: list[str]
    invalid: list[str]          # cleared without provenance/licence, or unknown status
    by_source: dict[str, dict[str, int]] = field(default_factory=dict)

    @property
    def blocks_release(self) -> bool:
        return bool(self.pending or self.invalid)


def load(path: Path | None = None) -> dict[str, dict]:
    p = path or paths.RIGHTS
    if not p.exists():
        return {}
    data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    return {str(k): (v or {}) for k, v in (data.get("images") or {}).items()}


def _frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    try:
        return yaml.safe_load(text[3:end]) or {}
    except yaml.YAMLError:
        return {}


def load_references(entities: Path | None = None) -> dict[str, Reference]:
    root = (entities or paths.ENTITIES) / "references"
    refs: dict[str, Reference] = {}
    for page in sorted(root.glob("*/*.md")):
        if page.name == "README.md":
            continue
        fm = _frontmatter(page)
        title = fm.get("title")
        if isinstance(title, dict):
            title = title.get("en") or next(iter(title.values()), page.stem)
        rid = page.relative_to(root.parent).with_suffix("").as_posix()
        refs[rid] = Reference(rid, str(title or page.stem),
                              [str(a) for a in fm.get("assets") or []],
                              dict(fm.get("rights_default") or {}))
    return refs


def source_for(image: str, refs: dict[str, Reference]) -> str | None:
    """The reference whose `assets:` prefix contains this image (longest prefix wins)."""
    best = max(((len(a), r.id) for r in refs.values() for a in r.assets if image.startswith(a)), default=None)
    return best[1] if best else None


def init(referenced: list[str], path: Path | None = None, refs: dict[str, Reference] | None = None) -> int:
    """Add a `pending` entry for every referenced image not yet in the registry, and fill
    an empty `source` from the references' `assets:`. Returns the number of entries added."""
    p = path or paths.RIGHTS
    refs = refs if refs is not None else load_references()
    registry = load(p)
    added = 0
    for img in sorted(referenced):
        if img not in registry:
            registry[img] = {"status": "pending", "source": "", "locator": "",
                             "provenance": "", "licence": "", "note": ""}
            added += 1
    filled = 0
    for img, entry in registry.items():
        if not entry.get("source"):
            src = source_for(img, refs)
            if src:
                entry["source"] = src
                filled += 1
    if added or filled or not p.exists():
        body = yaml.safe_dump({"images": dict(sorted(registry.items()))},
                              allow_unicode=True, sort_keys=False, width=120)
        p.write_text(HEADER + body, encoding="utf-8", newline="\n")
    return added


def effective(entry: dict | None, refs: dict[str, Reference]) -> tuple[str, bool]:
    """Return (status, documented) for one image after applying its source's default."""
    entry = entry or {}
    status = entry.get("status", "pending")
    ref = refs.get(str(entry.get("source") or ""))
    default = ref.default if ref else {}
    if status == "pending" and default.get("status") in ("cleared", "omit"):
        status = default["status"]
    provenance = str(entry.get("provenance", "")).strip() or (ref.title if ref else "")
    licence = str(entry.get("licence", "")).strip() or str(default.get("licence", "")).strip()
    return status, bool(provenance and licence)


def evaluate(referenced: list[str], registry: dict[str, dict],
             refs: dict[str, Reference] | None = None) -> Verdict:
    refs = refs or {}
    v = Verdict([], [], [], [])
    for img in referenced:
        entry = registry.get(img)
        status, documented = effective(entry, refs)
        src = str((entry or {}).get("source") or "") or "(no source)"
        counts = v.by_source.setdefault(src, {"cleared": 0, "omit": 0, "pending": 0, "invalid": 0})
        if status == "cleared":
            if documented:
                v.cleared.append(img)
                counts["cleared"] += 1
            else:
                v.invalid.append(img)
                counts["invalid"] += 1
        elif status == "omit":
            v.omitted.append(img)
            counts["omit"] += 1
        elif status == "pending":
            v.pending.append(img)
            counts["pending"] += 1
        else:
            v.invalid.append(img)
            counts["invalid"] += 1
    return v
