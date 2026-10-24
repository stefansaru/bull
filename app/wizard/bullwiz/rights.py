"""Image rights registry and release gate (NORM-COPY-01, APP-CNT-003, PROC-RGT-001).

Registry: wiki/assets/rights.yml, keyed by the image path relative to wiki/.

    images:
      assets/media/image219.jpg:
        status: pending        # pending | cleared | omit
        provenance: ""         # where the image comes from (own scan, book, auction lot…)
        licence: ""            # own work, public domain, permission (with reference), …
        note: ""

Only `cleared` images ship. `omit` is a recorded decision to leave the figure
out of the app. `pending` (or an image missing from the registry) blocks a
release; in a development run it is dropped with a warning instead.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import yaml

from . import paths

STATUSES = ("pending", "cleared", "omit")

HEADER = """\
# Image rights registry — read by app/wizard (NORM-COPY-01, PROC-RGT-001).
# One entry per image the narrative references, keyed by its path under wiki/.
# status: pending (default, blocks an app release) | cleared (ships) | omit (left out on purpose).
# A `cleared` entry must say where the image comes from (provenance) and on what basis it may be
# reproduced (licence). Keep evidence of any permission outside the repository and cite it in `note`.
# New entries are added by `py -3 app/wizard/wizard.py --rights-init`; existing ones are never changed.
"""


@dataclass
class Verdict:
    cleared: list[str]
    omitted: list[str]
    pending: list[str]
    invalid: list[str]          # cleared without provenance/licence, or unknown status

    @property
    def blocks_release(self) -> bool:
        return bool(self.pending or self.invalid)


def load(path: Path | None = None) -> dict[str, dict]:
    p = path or paths.RIGHTS
    if not p.exists():
        return {}
    data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    return {str(k): (v or {}) for k, v in (data.get("images") or {}).items()}


def init(referenced: list[str], path: Path | None = None) -> int:
    """Add a `pending` entry for every referenced image not yet in the registry."""
    p = path or paths.RIGHTS
    registry = load(p)
    added = 0
    for img in sorted(referenced):
        if img not in registry:
            registry[img] = {"status": "pending", "provenance": "", "licence": "", "note": ""}
            added += 1
    if added or not p.exists():
        body = yaml.safe_dump({"images": dict(sorted(registry.items()))},
                              allow_unicode=True, sort_keys=False, width=120)
        p.write_text(HEADER + body, encoding="utf-8", newline="\n")
    return added


def evaluate(referenced: list[str], registry: dict[str, dict]) -> Verdict:
    v = Verdict([], [], [], [])
    for img in referenced:
        entry = registry.get(img)
        status = (entry or {}).get("status", "pending")
        if status == "cleared":
            if str(entry.get("provenance", "")).strip() and str(entry.get("licence", "")).strip():
                v.cleared.append(img)
            else:
                v.invalid.append(img)
        elif status == "omit":
            v.omitted.append(img)
        elif status == "pending":
            v.pending.append(img)
        else:
            v.invalid.append(img)
    return v
