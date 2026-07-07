---
id: meta/decisions/DR-009-published-languages
type: decision
title: {en: "How many languages the published book uses"}
status: accepted
---

# DR-009 — Published languages of the book

| Field | Value |
|-------|-------|
| Status | **accepted** (2026-07-04) |
| Date | 2026-07-04 |
| Mode | RESEARCH → CLARIFY |
| Actor(s) | user + agent |
| Related | DR-003 (English master), DR-005 (exporter), DR-010 (translation storage), [[../../strategy/multilanguage-analysis]] |

## Context
The current book is four languages per A4 page (EN/RO/FR/DE, 2×2 quadrant). The user
questioned whether four is overkill. Research ([[../../strategy/multilanguage-analysis]])
found: the field publishes separate monolingual books; the definitive Bull's Head
reference (Heimbüchler) is bilingual DE–EN; the money/lingua franca is English; and a
wiki can auto-generate any edition cheaply.

## Recommendation (not yet decided)
**Retire the quadrant.** English-led master edition + auto-generated per-language
editions (RO, DE, FR), print-on-demand. Fallback if translation cost is high or the
goal is a heritage keepsake: **bilingual EN + RO**.

## Options on the table
- (a) English only. (b) **English master + generated RO/DE/FR editions (recommended).**
- (c) Bilingual EN+RO single object. (d) Keep 4-up quadrant.

## Decision
**Ship the English edition first (the flagship); generate French, German, and
Romanian editions later** from the same wiki. Retire the 4-up quadrant as the
*published* format (the wiki still stores all four languages; the quadrant remains
available as an internal proof/`--edition quad` build). Publication order:
**EN → (later) FR, DE, RO.**

## Consequences
- The exporter's default working target becomes `--edition en`; `fr/de/ro` and `quad`
  remain available and are produced when those editions are scheduled.
- The audit's per-edition language checks (REQ-L) run only against the English edition
  for now; other languages are validated when their editions are prepared.
- We already **hold** FR/DE/RO (ingested from the source book); they are not
  discarded — they are stored as translations of the English master and reused when
  those editions ship. **How** they are stored is DR-010.
- French is lowest priority per [[../../strategy/multilanguage-analysis]]; it may end
  up PDF-only or dropped if demand is absent.
