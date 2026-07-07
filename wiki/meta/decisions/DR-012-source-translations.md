---
id: meta/decisions/DR-012-source-translations
type: decision
title: {en: "Sources carry cleaned + translated language variants"}
status: accepted
---

# DR-012 — Sources carry cleaned + translated language variants

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | INGEST / TRANSLATE |
| Actor(s) | user ("translate the raw text into english and romanian") + agent |
| Related | DR-011 (raw text), DR-010 (narrative translations), DR-003 (English master) |

## Context
Raw sources are single-language and imperfect: **Kiriac 1974** is Romanian with OCR-lost
diacritics; the **auction catalogues** are English. To use them across the EN/RO (later
FR/DE) book, we need clean, translated versions — without discarding the raw text
(which stays as the audit baseline, DR-011).

## Decision
Each raw source file `sources/<id>/<name>.md` (`status: raw-ocr`) may gain **cleaned +
translated sibling files** `<name>.<lang>.md` (e.g. `.en.md`, `.ro.md`), `status:
translated`, each with provenance back to the raw file and the same `<!-- pdf page N -->`
markers so passages line up. The raw file is never edited; cleanup/diacritic-restoration
happens in the translated variants.

This is the **translation stage applied to sources** — the counterpart of the narrative
`.i18n.yml` sidecars (DR-010), which translate authored prose. Concepts and narrative
may cite either the raw or a translated variant (prefer the translated for readable
quotes; the raw remains the verbatim baseline).

## Alternatives considered
- Overwrite the raw with a cleaned version. Rejected: loses the verbatim OCR baseline
  and the ability to re-derive/verify.
- Store translations as sidecars like the narrative. Rejected for sources: source text
  is long-form and language-parallel by page; sibling files are simpler to read/diff than
  per-unit YAML here.

## Consequences
- `sources/<id>/` grows `.en.md` / `.ro.md` variants; `sources/README` lists them.
- Pipeline stage list (AGENTS) notes translation also covers sources.
- FR/DE source variants can be added later the same way.
