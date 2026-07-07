---
id: meta/decisions/DR-007-references-for-claims
type: decision
title: {en: "Every claim carries a reference"}
status: accepted
---

# DR-007 — Every claim carries a reference

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | CONCEPT |
| Actor(s) | user ("provide references for all our claims") |
| Related | DR-006, references, audit-procedure |

## Context
This is a reference work; its authority depends on sourcing. Many existing books
leave claims unsourced, which the author wants to fix.

## Decision
Every factual claim is backed by a [[../../entities/references|reference]]. Claims
carry `refs:` in concept frontmatter and inline citations in prose. Unreferenced
claims are marked `needs-ref` and treated as **audit defects** (REQ-C3).

## Alternatives considered
- Reference selectively. Rejected: leaves the credibility gap the book exists to
  close.

## Consequences
- A living bibliography in `entities/references/`.
- Ingest may surface many `needs-ref` items to backfill — that is expected.
