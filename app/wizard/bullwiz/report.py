"""HTML run report with a single release verdict (PROC-REL-001)."""

from __future__ import annotations

import html
from datetime import datetime
from pathlib import Path

from . import paths

COLOURS = {"pass": "#1e7a3c", "warn": "#9a6a00", "fail": "#b3261e", "skip": "#6b6b6b"}


def write(steps: list, verdict: str, mode: str, out: Path | None = None) -> Path:
    out = out or paths.REPORTS / "wizard-report.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    for s in steps:
        detail = "<br>".join(html.escape(line) for line in s.detail[:40])
        if len(s.detail) > 40:
            detail += f"<br>… {len(s.detail) - 40} more"
        rows.append(
            f"<tr><td>{html.escape(s.name)}</td>"
            f"<td style='color:{COLOURS[s.status]};font-weight:600'>{s.status.upper()}</td>"
            f"<td>{'gate' if s.gate else 'advisory'}</td><td>{detail}</td></tr>")
    colour = "#1e7a3c" if verdict.startswith("PASS") else "#b3261e"
    out.write_text(f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Bull app — wizard report</title>
<style>body{{font:15px/1.5 system-ui,sans-serif;margin:24px;max-width:1100px}}
table{{border-collapse:collapse;width:100%}}td,th{{border:1px solid #ccc;padding:6px 8px;vertical-align:top;text-align:left}}
.v{{font-size:28px;font-weight:700;color:{colour}}}</style></head><body>
<h1>Bull app — wizard report</h1>
<p>{datetime.now():%Y-%m-%d %H:%M} · mode: <b>{html.escape(mode)}</b></p>
<p class="v">Release verdict: {verdict}</p>
<table><tr><th>Step</th><th>Result</th><th>Kind</th><th>Detail</th></tr>{''.join(rows)}</table>
</body></html>""", encoding="utf-8")
    return out
