---
id: meta/decisions/DR-008-three-stage-pipeline
type: decision
title: {en: "Pipeline: concepts -> narrative -> pagination"}
status: accepted
---

# DR-008 — Pipeline: concepts → narrative → pagination

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | BOOTSTRAP |
| Actor(s) | user ("concepts -> the narrative -> the pagination, 3 steps") |
| Related | DR-001, DR-005, AGENTS |

## Context
The user framed production as three steps: concepts, then narrative, then
pagination. This maps cleanly onto the hybrid wiki (entities + narrative) plus the
exporter.

## Decision
Adopt the **three-stage pipeline** as the backbone ([[../../AGENTS]]):
1. **Concepts** — `entities/`: what is known, with claims + references + debates.
2. **Narrative** — `narrative/`: how it is told, in reading order, 4 languages.
3. **Pagination** — `tools/export_book.py`: how it looks on the page.
Upstream is never skipped; facts flow forward only.

## Alternatives considered
- Write prose directly and lay it out (no concept layer). Rejected: recreates the
  book's duplication and unsourced-claim problems.

## Consequences
- Clear separation of concerns and mode boundaries.
- Slightly more upfront structure before prose is written.
