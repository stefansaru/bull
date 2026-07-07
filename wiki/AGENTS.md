---
id: AGENTS
type: meta
title:
  en: Working contract — how to work in this wiki
status: living
---

# AGENTS — working contract

How any agent (or human) works inside the Bull's Head wiki. Read [[concept]] first.
The user is the ultimate source of truth; when uncertain about intent, **ask**
(don't invent — see [[meta/requirements|REQ]] and [[decisions/DR-004-verbatim-first]]).

## The pipeline: raw text → concepts → narrative → translations → pagination → generation

The book is produced in ordered stages ([[decisions/DR-008-three-stage-pipeline]],
refined by [[decisions/DR-011-raw-source-ingestion-stage]]). Each has its own home
and artifacts. Never skip upstream.

```
 raw doc ─▶ ┌──────────┐ ─▶ ┌──────────┐ ─▶ ┌───────────┐ ─▶ ┌────────────┐ ─▶ ┌───────────┐ ─▶ ┌──────────┐
            │ 1 RAW    │    │ 2 CONCEPTS│    │ 3 NARRATIVE│    │4 TRANSLATE │    │5 PAGINATION│    │6 GENERATE│
            │ sources/ │    │ entities/ │    │ narrative/ │    │ *.i18n.yml │    │ tools/     │    │ output/  │
            │ verbatim │    │ graph +   │    │ prose that │    │ per-lang   │    │ export;    │    │ .docx /  │
            │ OCR/txt  │    │ claims +  │    │ cites      │    │ (DR-010)   │    │ layout     │    │ pdf      │
            │ (raw-ocr)│    │ refs      │    │ concepts   │    │            │    │            │    │          │
            └──────────┘    └───────────┘    └───────────┘    └────────────┘    └───────────┘    └──────────┘
            *the source*   *what's known*   *how it's told*  *in each lang*    *how it looks*   *the artifact*
```

1. **RAW TEXT** — `sources/<id>/`: verbatim text of an external document (OCR/extract),
   page-delimited, provenance to the source PDF. Left raw (OCR artefacts, lost Romanian
   diacritics) — fixed only when a concept is derived. [[decisions/DR-011-raw-source-ingestion-stage]]
2. **CONCEPTS** — `entities/`: the knowledge graph; every claim cites a source
   (`refs:` into `sources/` with a page — DR-007).
3. **NARRATIVE** — `narrative/`: English-master prose that cites concepts.
4. **TRANSLATIONS** — narrative prose via `*.i18n.yml` sidecars hash-linked to English
   ([[decisions/DR-010-translation-storage]]); raw **sources** via cleaned+translated
   sibling files `sources/<id>/<name>.<lang>.md` ([[decisions/DR-012-source-translations]]).
5. **PAGINATION** — `tools/export_book.py`: layout into the physical book.
6. **GENERATION** — `output/`: the `.docx`/PDF artifact.

1. **CONCEPTS** — the knowledge graph in `entities/`. Every fact lives here once:
   an entity, its properties, its relations, its **claims**, and the **references**
   backing each claim. Concepts may be flagged `status: debated` when the field
   disagrees (see below). This stage answers *what do we know and how sure are we?*

2. **NARRATIVE** — `narrative/`: the book's prose in reading order, one page per
   section, four languages co-located, images in place. Narrative **cites**
   concepts via `[[wikilinks]]`; it does not originate facts, it *tells* them. This
   stage answers *how do we tell it?*

3. **PAGINATION** — `tools/export_book.py`: deterministically lays the narrative out
   into the physical book (4-language A4 quadrant, or a per-language edition) as
   `.docx`/PDF, reusing the source `styles.xml`. This stage answers *how does it
   look on the page?* No knowledge is created here.

## Modes

| Mode | Purpose |
|------|---------|
| INGEST | Bring source material in, normalise, place verbatim, record provenance. |
| CONCEPT | Create/curate entity pages, claims, references, mark debates. |
| NARRATE | Write/refine narrative pages; keep them citing concepts. |
| PAGINATE | Run/adjust the exporter; validate layout. |
| RESEARCH | Gather external evidence (catalogues, references, market/strategy). |
| AUDIT | Validate a generated book against [[meta/requirements]] + [[meta/conventions]] using [[meta/audit-procedure]]. |
| CLARIFY | Ask the user to resolve ambiguity; may interrupt any mode. |

## Rules of engagement

1. **Verbatim first.** New source content lands unedited with `status: verbatim`
   and `source_blocks` provenance. Improvements are separate, diff-visible passes
   that raise status to `reviewed`/`improved`. [[decisions/DR-004-verbatim-first]]
2. **One entity, one file.** No duplicate concept pages. [[decisions/DR-002-one-entity-one-file]]
3. **Every claim is referenced.** A factual assertion carries a reference
   ([[meta/conventions]] §references; unreferenced claims are auditable defects).
4. **Debates are marked, not resolved.** When sources disagree (e.g. aurochs vs.
   wisent), set `status: debated`, list the positions and who holds them, don't pick
   silently. [[decisions/DR-006-mark-debated-concepts]]
5. **English is master.** Translations follow; flag them stale when EN changes.
   [[decisions/DR-003-english-master]]
6. **Everything we decide is written down.** Discussions with the user become DRs
   under `meta/decisions/` and/or notes in the relevant strategy/meta page — not
   left in chat. [[decisions/README]]
7. **The book is generated, never hand-edited.** Fix the wiki, re-run pagination.
   [[decisions/DR-005-exporter-rebuilds-book]]

## Where things live

- `concept.md`, `AGENTS.md`, `index.md` — orientation.
- `meta/` — ontology, glossary, conventions, requirements, audit procedure, style,
  decisions.
- `strategy/` — vision/mission/objectives, market research, audience, the
  multi-language analysis.
- `entities/` — the concept graph.
- `narrative/` — the book prose (per chapter/section).
- `assets/media/` — the 1049 images.
- `../tools/` — extractor, structurer, generators, exporter (code, outside the vault).
