---
id: sources/README
type: meta
title: {en: Raw sources}
status: living
---

# sources/ — raw ingested source text

Stage 1 of the pipeline ([[../AGENTS|AGENTS]], [[../meta/decisions/DR-011-raw-source-ingestion-stage|DR-011]]):
verbatim text of external documents, before any interpretation. Concepts in
[[../entities/|entities/]] are derived from here and **cite these pages** (DR-007).

- Text is **raw** (`status: raw-ocr` for scans): OCR artefacts and — for Romanian —
  lost diacritics are left as-is; they are corrected only when a concept is derived
  from a passage. Reading order is column-aware but not guaranteed on mixed layouts.
- Each file is page-delimited (`<!-- pdf page N -->`) with provenance to the source PDF.
- Produced by `tools/ingest_reference.py`.
- **Cleaned + translated variants** live alongside as `<name>.<lang>.md` (e.g. `.en.md`,
  `.ro.md`), `status: translated`, with diacritics restored and OCR noise removed — the
  raw file stays the verbatim baseline ([[../meta/decisions/DR-012-source-translations|DR-012]]).

## Sources

| Source | What | Language | Status |
|--------|------|----------|--------|
| [[kiriac-1974/chapter-1-postmarks-1858\|Kiriac 1974]] | *Catalogul mărcilor poștale românești* (Dragomir) — ToC, guideline, Ch. I classic postmarks 1858 | Romanian | raw-ocr + [[kiriac-1974/chapter-1-postmarks-1858.en\|EN]] / [[kiriac-1974/chapter-1-postmarks-1858.ro\|RO]] |
| [[istoria-postei-1916/text\|Istoria Poștei 1916]] | Minescu, *Istoria Poștelor Române* — the standard 1916 postal history (menzil relays, foreign post offices, the 1858 reform, 1862 unification) | Romanian | raw-ocr — **mined** into [[../entities/concepts/menzil-relay-system]], [[../entities/concepts/foreign-post-offices]], [[../entities/events/unification-of-posts-1862]], [[../entities/concepts/postal-history-romania]] |
| [[unirea-principatelor-1959-vol2/text\|Unirea docs, vol. II]] | *Documente privind Unirea Principatelor*, vol. II (1959) — documentary collection on the road to the 1859 Union | Romanian (some French/German docs) | raw (text-layer) — **mined** into [[../entities/events/ad-hoc-divans-1857]], [[../entities/events/paris-convention-1858]], [[../entities/concepts/caimacam-regency-moldavia]], [[../entities/events/union-of-principalities-1859]] |
| [[wertheimer-ghika-1944/text\|Wertheimer-Ghika 1944]] | Jacques Wertheimer-Ghika, *Documentele Poștei Române: Cartea mărcilor Cap de bou* — a primary-document study of the 1858 issue (transcribed Moldavian postal correspondence, per-town *marci* distribution tables, expeditor lists) | Romanian | raw-ocr (99 page **photos**) — **mined** into [[../entities/references/wertheimer-ghika-1944]], [[../entities/concepts/bull-head-authentication-and-fantasy-stamps]], [[../entities/concepts/bull-head-stamp-distribution-1858]], [[../entities/concepts/franco-porto-apparatus-1858]], [[../entities/concepts/bull-head-postmarks-from-documents]], [[../entities/events/beginnings-romanian-telegraph]] (+ deepened [[../entities/concepts/foreign-post-offices]]) |
| [[dragomir-stampilografie-1990/text\|Dragomir, Ștampilografie 1990]] | Kiriac Dragomir, *Ștampilografie Poștală (România: 1822–1910)* — **the** standard reference for Romanian postal handstamps/seals. Own device-coding scheme: **SM** (seals of Moldavia), **SPM** (Moldavian post-office stamps), **SV** (seals of Wallachia/Valahia), etc. — each keyed to a **Fig. N** illustration and grouped in **Plansă** plates. Covers Moldavia *and* Wallachia, 1822 onward (menzil-house seals, quarantine offices, FRANCO/PORTO). This is the public taxonomy the wiki's `PM52`/`M1`/`M2`/`M3`/`C1` pages were flagged as needing. | Romanian | raw-ocr (155 page **photos**), 840 figure crops — **to be mined** (per-device handstamp entities, both provinces) |
| [[carjan-manole-timbre-2006/text\|Cârjan & Manole 2006]] | Lazăr Cârjan & Mircea Gheorghe Manole, *Catalogul Timbrelor Poștale Românești, vol. I: 1858–1947* (Enciclopedia RAO, 2006) — modern illustrated stamp catalogue with valuations | Romanian | raw-ocr (31 page **photos**), 250 figure crops — **to be mined** (numbering + valuations, Bull's Head sections) |
| [[spineanu-catalog-marci-1984/text\|Spineanu 1984]] | Corneliu Spineanu (coord. Angela Harnaj), *Catalogul Mărcilor Poștale Românești 1858–1947*, vol. I (Direcția Generală a Poștelor și Telecomunicațiilor, 1984) — official state catalogue | Romanian | raw-ocr (12 page **photos**), 18 figure crops — **to be mined** |
| [[chirices-pascariu-catalog/text\|Chiricheș & Pascariu]] | Coriolan Chiricheș & Samuel Pascariu, *Catalogul Mărcilor Poștale Românești 1858–2000 (L.P. 1 – L.P. 1538)*, vol. I (AXA) — LP-numbered catalogue | Romanian | raw-ocr (8 page **photos**), 96 figure crops — **to be mined** |

> **Citation schemes differ by source.** *Istoria Poștei 1916* is cited by the book's
> **printed page numbers** (bare-number lines in the OCR); note the OCR misreads the
> leading "1" as "4" in some page-runs (137→"437"), so verify against the monotonic
> sequence. *Unirea vol. II* has a clean text layer and is cited by the
> `<!-- pdf page N -->` marker. *Wertheimer-Ghika 1944*, *Dragomir Ștampilografie 1990*,
> *Cârjan & Manole 2006*, *Spineanu 1984* and *Chiricheș & Pascariu* were all OCR'd from
> **page photos** (`tools/ocr_photos.py`); cite by the `<!-- photo N -->` marker (= photo
> order), and add the book's own printed page number where legible in the text.
>
> **Dragomir Ștampilografie 1990** additionally carries the author's own **device codes**
> — `SM##` (seal, Moldavia), `SPM##` (post-office stamp, Moldavia), `SV##` (seal, Valahia/
> Wallachia), with a two-digit year and optional variant letter (`SM58a`) — plus **`Fig. N`**
> illustration numbers and **`Plansă N`** plates. Cite a device by its code *and* the photo,
> e.g. *(Dragomir, SM22, photo 8)*. These codes are the canonical taxonomy for the new
> per-device handstamp entities. Note the raw OCR mangles them (`SPMc9a`, `SV5l`, `Sv33`);
> normalise against the illustration when deriving a concept.
