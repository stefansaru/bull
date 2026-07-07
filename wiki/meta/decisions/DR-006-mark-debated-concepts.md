---
id: meta/decisions/DR-006-mark-debated-concepts
type: decision
title: {en: "Mark debated concepts; don't resolve silently"}
status: accepted
---

# DR-006 — Mark debated concepts; don't resolve silently

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | CONCEPT |
| Actor(s) | user ("mark that certain concepts are unclear or debated") |
| Related | DR-007, ontology |

## Context
The field genuinely disagrees on points — e.g. whether the animal is an **aurochs or
a wisent**, disputed printing/plating counts, and Julian/Gregorian dating. Asserting
one side as settled would be dishonest and wrong.

## Decision
A concept in dispute gets `status: debated` with an explicit **positions** list:
each position, its evidence, and **who holds it** (with references). The narrative
presents the debate; it does not pick a winner unless the user decides to.

## Alternatives considered
- Pick the majority view silently. Rejected: unscholarly, hides uncertainty.

## Consequences
- Higher trust; audit checks that known controversies are `debated` (REQ-C4).
