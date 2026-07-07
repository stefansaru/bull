---
id: meta/style
type: meta
title:
  en: Style & language rules
status: living
---

# Style & language rules

How prose is written across the four languages. See [[conventions]] for notation
and [[decisions/DR-003-english-master]] for the master-language decision.

## Languages & layout

- **English is the master.** All content originates or is finalised in English;
  Romanian, French and German are translations kept in lockstep.
- In the current book each titled unit is laid out as a **2×2 quadrant**:

  | | |
  |---|---|
  | **EN** (top-left) | **RO** (top-right) |
  | **FR** (bottom-left) | **DE** (bottom-right) |

  Whether the *published* book keeps four languages is under review —
  see [[strategy/multilanguage-analysis]]. The wiki stores all four regardless, so
  any edition can be generated ([[decisions/DR-005-exporter-rebuilds-book]]).

- **Storage (DR-010):** the narrative `.md` page holds **English only**; RO/FR/DE live
  in a per-page **`.i18n.yml` sidecar**, each translation stamped with the `en_hash` of
  the English it was made from. `tools/i18n_status.py` reports coverage and flags any
  translation whose English has since changed. See [[frontmatter-schema]].
- **Publication order (DR-009):** English edition first; FR/DE/RO editions generated
  later from the sidecars. We already hold FR/DE/RO from the source book.

## Translation discipline

- When the English changes, mark affected languages stale
  (`translation_status: {ro: stale, …}`) until re-checked.
- Do **not** silently reconcile differences between languages; where the source
  languages disagree in meaning, record it (a translation defect or a genuine
  content difference) rather than papering over it.
- Proper names: keep Romanian diacritics (Iași, Ștefan, Vogoride); give an English
  gloss on first use where helpful (Iași (Jassy)).

## Prose

- Reference-work register: precise, sober, cite-as-you-go. Avoid unsourced
  superlatives ("the rarest") unless referenced (C-13).
- Keep the author's **aurochs throughline** (C-16) and emoji faceting (C-10); they
  are identity, not clutter.
- Numbers, dates, catalogue refs, dimensions per [[conventions]].
- Uncertainty is explicit: use `~` (approximation) and `?` (unknown) per
  [[glossary]]; debates use `status: debated` (C-14), not weasel words.

## Non-goals

- No silent editorialising during INGEST (verbatim first — C default,
  [[decisions/DR-004-verbatim-first]]).
- No new terminology outside [[glossary]] without adding it there first.
