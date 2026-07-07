---
id: meta/decisions/DR-002-one-entity-one-file
type: decision
title: {en: "One entity, one file"}
status: accepted
---

# DR-002 — One entity, one file

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | CONCEPT |
| Actor(s) | user + agent |
| Related | DR-001, ontology |

## Context
The same stamp/place/person recurs across many chapters. Duplicated pages drift.

## Decision
Each real-world entity has exactly one page in `entities/` ([[../ontology]]).
Narrative pages link to it; duplicates are merged, not forked.

## Alternatives considered
- Per-chapter local notes. Rejected: drift, no single truth.

## Consequences
- Clean graph; edits happen in one place.
- Requires care to detect and merge duplicates during ingest.
