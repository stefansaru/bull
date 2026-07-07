---
id: meta/decisions/DR-011-raw-source-ingestion-stage
type: decision
title: {en: "Explicit raw-text ingestion stage; sources/ area"}
status: accepted
---

# DR-011 — Explicit raw-text ingestion stage; `sources/` area

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | INGEST |
| Actor(s) | user (stated the pipeline) + agent |
| Related | DR-008 (concepts→narrative→pagination), DR-007 (references), DR-010 (translations) |

## Context
When ingesting an external reference (e.g. the scanned **Kiriac 1974** catalogue) we
need the *raw text* first, before any interpretation, so concepts can be built on top
with traceable references. The user specified the full pipeline:

> raw document → **raw text** → raw concepts (with references) → translations →
> pagination → document generation.

## Decision
Add an explicit **RAW-TEXT ingestion stage** in front of the concept stage, and a
new wiki area **`sources/`** to hold verbatim ingested source text:

```
raw document ─▶ [1 RAW TEXT]  sources/<id>/   (OCR/extract, verbatim, status: raw-ocr)
             ─▶ [2 CONCEPTS]  entities/…       (derived, each claim -> reference into sources/)
             ─▶ [3 NARRATIVE] narrative/       (prose that cites concepts)
             ─▶ [4 TRANSLATIONS] *.i18n.yml     (DR-010)
             ─▶ [5 PAGINATION] tools/export     (layout)
             ─▶ [6 GENERATION] output/          (docx/pdf)
```

- `sources/<id>/` holds the raw text (page-delimited, provenance to the source PDF).
  It is **verbatim/raw** — OCR artefacts and (for Romanian) lost diacritics are left
  as-is and fixed only when a concept is derived from a passage.
- Concepts derived from a source **cite it** (`refs:` → `[[sources/<id>/...]]` + page),
  satisfying DR-007. This makes the Kiriac figure numbers, town markings, etc. traceable
  to the authoritative catalogue page.

## Alternatives considered
- Derive concepts straight from OCR without storing raw text. Rejected: no verbatim
  audit trail; can't re-derive or verify against the exact source wording.
- Put raw text under `entities/references/<id>/`. Rejected: raw source text is a
  pipeline artefact, not a bibliographic entity; the reference entity *links* to it.

## Consequences
- New `sources/` tree; `tools/ingest_reference.py` produces it (OCR + column-aware order).
- Concept extraction becomes a distinct, reviewable step over stored raw text.
- Raw text may be large and imperfect; that is expected and flagged (`status: raw-ocr`).
