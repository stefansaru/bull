---
id: meta/decisions/DR-005-exporter-rebuilds-book
type: decision
title: {en: "The book is generated, never hand-edited"}
status: accepted
---

# DR-005 — The book is generated, never hand-edited

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | PAGINATE |
| Actor(s) | user (chose "Rebuild 4-language A4 quadrant") |
| Related | DR-001, DR-008, DR-009 |

## Context
The user wants to export the wiki back into the book format. If the output is
hand-tweaked, the wiki stops being the source of truth.

## Decision
A deterministic **exporter** (`tools/export_book.py`) rebuilds the book from the
wiki, reusing the source `styles.xml`. Fix the wiki, re-run the exporter; never edit
the output. Initial target: the 4-language A4 quadrant (the user's current format);
the same substrate can emit per-language editions (see DR-009).

## Alternatives considered
- Manual DTP in Word. Rejected: breaks single-source, unauditable.

## Consequences
- Re-runnable, auditable builds (REQ-B1).
- Layout logic must live in code.
