---
id: meta/decisions/DR-001-wiki-not-just-book
type: decision
title: {en: "Wiki is the source of truth; the book is a rendering"}
status: accepted
---

# DR-001 — Wiki is the source of truth; the book is a rendering

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | BOOTSTRAP |
| Actor(s) | user + agent |
| Related | DR-005, DR-008 |

## Context
The author has a finished 4-language A4 book as a `.docx`. A linear multi-language
document repeats facts, is hard to maintain, and hides the graph structure of a
philatelic study. The user asked for a local wiki plus a means to export the book.

## Decision
The **local wiki is the single source of truth**. The book is one **rendering**
generated from it. Facts are stated once (in concepts), told once (in narrative),
and laid out by the exporter. See [[../../concept]].

## Alternatives considered
- Keep editing the `.docx` directly. Rejected: no graph, painful multi-language
  maintenance, no provenance, no audit.
- Wiki only, no book. Rejected: the user wants the book as a deliverable.

## Consequences
- Enables per-language/format editions from one substrate.
- Requires an exporter (DR-005) and discipline that nothing is authored in the
  book output.
