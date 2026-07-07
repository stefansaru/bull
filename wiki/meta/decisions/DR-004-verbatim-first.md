---
id: meta/decisions/DR-004-verbatim-first
type: decision
title: {en: "Verbatim-first ingestion"}
status: accepted
---

# DR-004 — Verbatim-first ingestion

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | INGEST |
| Actor(s) | user (chose "Verbatim first, improve later") |
| Related | DR-001, style, conventions |

## Context
The book is finished and the author's voice matters. Improving during ingest risks
losing intent and makes it impossible to audit the wiki against the original.

## Decision
Source content lands **verbatim** with `status: verbatim` and `source_blocks`
provenance. Improvements are **separate, diff-visible passes** that raise status to
`reviewed`/`improved`. No silent editing.

## Alternatives considered
- Improve as we go / aggressive rewrite. Rejected by the user for the baseline;
  available later as explicit passes.

## Consequences
- A faithful baseline exists to audit against (REQ-C2).
- Two-phase effort: ingest then improve.
