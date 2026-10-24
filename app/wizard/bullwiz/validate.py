"""Content validation before bundling (PROC-CNT-001)."""

from __future__ import annotations

from collections import Counter

from . import paths
from .content import Section


def validate(sections: list[Section], referenced: list[str]) -> tuple[list[str], list[str]]:
    """Return (errors, warnings). Errors block the run; warnings are reported."""
    errors: list[str] = []
    warnings: list[str] = []
    if not sections:
        errors.append("no narrative sections found under wiki/narrative/")
    dupes = [o for o, n in Counter(s.order for s in sections).items() if n > 1]
    if dupes:
        errors.append(f"duplicate `order` values: {sorted(dupes)[:10]}")
    for s in sections:
        if not s.title.get("en"):
            errors.append(f"{s.id}: missing English title")
        for u in s.units:
            if u.kind == "figure" and not u.images:
                warnings.append(f"{s.id} {u.uid}: figure unit without an image")
            elif u.kind != "figure" and not (u.text.get("en") or u.rows.get("en") or u.images):
                warnings.append(f"{s.id} {u.uid}: empty {u.kind} unit")
    missing = [i for i in referenced if not (paths.WIKI / i).exists()]
    for i in missing:
        errors.append(f"referenced image does not exist: {i}")
    return errors, warnings
