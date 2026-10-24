---
id: meta/discussion-log
type: meta
title:
  en: Discussion log
status: living
---

# Discussion log

Chronological record of substantive decisions and requests from working sessions, so
nothing important lives only in chat ([[../AGENTS|AGENTS]] rule 6). Decisions are
promoted to DRs ([[decisions/README]]); this log keeps the thread and the *asks*.

## 2026-07-04 — Session 1 (bootstrap)

**User asks.** Ingest `input/20251208-stamps-book.docx` (a finished 4-language A4
book) into a local wiki; build a means to export the wiki back into the book format;
refactor/improve/finalize. Later in the session, the user expanded scope:

- Extract **rules & conventions** from the document as an auditable list → [[conventions]].
- Do **market research**; identify **target audience, pain points**, and how the book
  addresses them → [[../strategy/market-research]], [[../strategy/target-audience]].
- Organize production as a **pipeline: concepts → narrative → pagination** →
  adopted, [[decisions/DR-008-three-stage-pipeline]].
- Be able to mark concepts **unclear/debated** → [[decisions/DR-006-mark-debated-concepts]].
- Provide **references for all claims** → [[decisions/DR-007-references-for-claims]].
- Define **mission / vision / objectives** → [[../strategy/vision-mission-objectives]].
- Define **requirements** and an **audit procedure** → [[requirements]], [[audit-procedure]].
- Investigate whether **multi-language even makes sense** → [[../strategy/multilanguage-analysis]].

**Decisions taken (via the clarifying questions).**
- Wiki model: **hybrid** (narrative + entity graph). → DR-001, DR-008.
- Master language: **English**, four languages co-located. → DR-003.
- Export target: **rebuild the 4-language A4 quadrant** (may change per multilanguage
  analysis). → DR-005, and DR-009 (open).
- Editorial latitude: **verbatim first, improve later**. → DR-004.

**Findings surfaced.**
- Source structure decoded: A4, 48 sections, ~2450 ordered blocks, 1049 images;
  content in 2×2 language tables + split table-pairs; emoji are a **semantic marker
  system** (the author's own legend → [[glossary]]).
- Domain backbone read directly from the outline: issues 🐃1/🐃2, denominations
  27/54/81/108 & 5/40/80 parale, handstamps PM52/M1/M2/M3/C1, reference chapters.
- **Multi-language:** research recommends **retiring the 4-up quadrant** in favour of
  an English master + auto-generated per-language editions; the definitive reference
  (Heimbüchler) is **bilingual DE–EN**. Decision **DR-009 is open** — awaiting the
  user. See [[../strategy/multilanguage-analysis]].

**Open items for the user.**
- Confirm vision/mission wording ([[../strategy/vision-mission-objectives]]).
- ~~Decide DR-009 (published languages).~~ → **Decided:** English first, FR/DE/RO later
  (DR-009 accepted).

## 2026-07-04 — Session 2 (languages, translations, auction census)

- **Language decision:** English edition first; FR/DE/RO later — [[decisions/DR-009-published-languages]] accepted.
- **Translation storage:** user chose **sidecar per page** — [[decisions/DR-010-translation-storage]].
  Migrated the existing FR/DE/RO out of pages into `.i18n.yml` sidecars, hash-linked to
  English (auto-staleness). `tools/i18n_status.py` reports coverage (RO 97% / FR 87% /
  DE 87% valid, 0 stale at baseline).
- **Auction catalogues:** user added 21 PDFs (1.4 GB) to `input/catalogues/`. Built the
  ingest+census pipeline (`pdf_scan.py`, `census.py`, `gen_census_wiki.py`): 4,575 pages
  → 186 relevant → **279 postmark occurrences (56 on Bull's Head), 147 Kiriac figures,
  135 markings, 176 lots**. Deliverables: [[../entities/references/auctions/README|reference pages]]
  (13 catalogues) + [[../entities/postmarks/census|postmark census]] with a Kiriac-figure
  concordance (feeds the PM52/M1 mapping).
- **Known gap:** Feldman + Sperati + Erivan catalogues have poor/scanned text layers →
  flagged for a future OCR pass.

## 2026-07-04 — Session 3 (OCR)

- **OCR:** installed RapidOCR (ONNX, pip, no admin); `tools/pdf_ocr.py` OCR'd the fully
  scanned **2006 David Feldman "Classic Romania"** (176 pages, ~11 min) → 34 relevant
  pages recovered.
- **Corrected the scan picture:** only that one catalogue was truly scanned. Erivan /
  corinphila-321 / Provera have text layers but **no Bull's Head content**; the Sperati
  sales have only sparse Romania mentions (relevant to the forgery chapter, not the
  postmark census).
- **Census broadened:** page filter now catches first-issue-denomination pages the strict
  scan skipped; added a description-based postmark pass for Feldman's Kiriac-less phrasing
  ("small double-circle ds in red"), each tagged `source: kiriac|desc`.
- **Result:** postmarks **279 → 329** (Bull's Head **56 → 98**), lots 176 → 489, markings
  135 → 159, reference pages 13 → 16. [[../entities/postmarks/census]] updated.
- **Remaining:** OCR isn't needed elsewhere; lot enrichment (Feldman certs/census refs use
  phrasing the regex misses); per-town postmark pages.

## 2026-07-04 — Session 4 (Kiriac 1974: raw ingest + concept derivation)

- **Pipeline formalized:** user stated `raw doc → raw text → concepts (w/ refs) →
  translations → pagination → generation` → [[decisions/DR-011-raw-source-ingestion-stage|DR-011]];
  new `sources/` area; AGENTS.md diagram updated.
- **Raw ingest:** Kiriac 1974 catalogue (622-pp scan) → `tools/ingest_reference.py`
  (RapidOCR, column-aware) → [[../sources/kiriac-1974/toc]], `/guideline`,
  `/chapter-1-postmarks-1858` (raw-ocr, Romanian, diacritics dropped — flagged).
- **Concept derivation:** structured Ch. I into **14 marking groups** →
  [[../entities/postmarks/kiriac-figures]] (type code, towns w/ diacritics restored,
  dims, ink, period, cited to Kiriac pages). 5 high-relevance to the 1858 Bull's Head
  (B.1/B.2 MOLDOVA datestamps, B.3 FRANCO, C.3 RECEPISSE, B.4/B.5 FOKSCHANI).
- **Key finding:** the 1974 Ch. I figure numbers (Fig. 37-119) are a **different system**
  from the auction-cited `Kiriac fig. 271-313` (Dragomir *Ștampilografie* 1990). Same
  devices, two numberings — map by device+town. Recorded on both pages.
- **Corroboration:** the B.1 datestamp towns/inks (Iași red-carmine only 28 Aug-18 Oct
  1858, etc.) match the auction census town-for-town — cross-validates both sources.
- **Remaining:** verify against the 1990 *Ștampilografie* (not yet in hand); derive the
  per-value stamp-characteristic figures (Fig. 104-119); build device→auction-fig concordance.

## 2026-07-04 — Session 5 (source translations + terminology glossary)

- **Pipeline extended:** raw sources now carry cleaned+translated sibling files
  (`<name>.en.md` / `.ro.md`) → [[decisions/DR-012-source-translations|DR-012]]; AGENTS +
  sources/README updated. Raw kept as verbatim baseline.
- **Kiriac Ch.I translated** (2 parallel agents, page-aligned): clean **Romanian**
  (4,054 diacritics restored) + faithful **English** →
  [[../sources/kiriac-1974/chapter-1-postmarks-1858.en]] / `.ro`. ~17k words each.
- **Catalogue Bull's Head lots → Romanian:** 45 substantive lots →
  [[../entities/references/compilations/bulls-head-lots]] (EN original + RO translation).
- **Terminology glossary (scoped):** 59 bilingual EN/RO terms from Kiriac Ch.1 (`K`) +
  catalogues (`C`) + book draft (`B`), 9 categories → [[terminology]]. Complements the
  symbols/abbreviations [[glossary]]; FR/DE columns deferred to those editions.
- **Method:** 4 background subagents (translation is well-suited to fan-out); outputs
  assembled by `tools/assemble_kiriac_translations.py`, `gen_glossary_terms.py`,
  `gen_lots_bilingual.py`.

## 2026-07-05 — Session 6 (context enrichment: ~19 thematic concept pages)

- **User goal clarified:** paint *why the Bull's Heads are meaningful* — heritage-led, all
  threads woven, legends labeled, curated-deep, wiki-first, web-supplemented for present-day
  → [[decisions/DR-013-heritage-thesis-and-enrichment|DR-013]], convention C-17, [[../strategy/enrichment-plan]].
- **Raw-ingested 14 new reference sources** (RO/FR/EN; ~1.35M words, ~1,411 images) via
  `tools/ingest_sources.py` (text-layer + RapidOCR for 3 scans + image/link extraction) →
  [[../sources/README|sources/]]. Only 2 were scanned; text-layer sources keep diacritics.
- **Derived ~19 cited concept pages** (heritage-led, every claim → source+page or numbered
  web ref; legends `[!legend]`; debates `debated`) across 4 threads + flagship + present-day:
  - *Aurochs/symbol:* [[../entities/concepts/aurochs]], aurochs-symbolism, moldavia-heraldry,
    aurochs-vs-wisent, [[../entities/events/dragos-founding-moldova]]
  - *Geopolitics:* geopolitics-1800s, [[../entities/events/1812-treaty-of-bucharest]],
    crimean-war-principalities, union-of-principalities-1859
  - *Postal:* postal-history-romania, [[../entities/places/atelia-timbrului]], old-post-buildings
  - *Philatelic:* scarcity-of-bull-heads, forgeries, [[../entities/people/famous-collectors]],
    early-philatelic-study
  - *Flagship + present-day:* why-bull-heads-matter, bull-heads-today, [[../entities/places/hanul-lui-manuc]]
- **Method:** ~19 background subagents, one per page, each reading its sources + writing a
  cited page directly. Aurochs thread run first as a style check; all held citation discipline.
- **Remaining:** promote pages draft→reviewed; weave concept links into the narrative chapters
  (feeds_chapter mapping in the enrichment plan); ingest the still-unmined big sources
  (Istoria Poștei 1916, Unirea vol. II) more deeply as needed.

## 2026-07-05 — Session 7 (deep-mining the two big sources: 6 cited pages)

- **User ask:** deeper mining of the two big still-unmined sources — *Istoria Poștei 1916*
  and *Unirea Principatelor* vol. II — **focus on concepts, no book export.**
- **Delivered 6 cited pages** (~10,200 words, all `status: draft`), one background subagent
  each, following the [[../strategy/enrichment-plan]] method + pass-2 status:
  - *Postal (Istoria Poștei 1916):* [[../entities/concepts/menzil-relay-system]],
    [[../entities/concepts/foreign-post-offices]], [[../entities/events/unification-of-posts-1862]].
  - *Geopolitics (Unirea vol. II):* [[../entities/events/ad-hoc-divans-1857]],
    [[../entities/events/paris-convention-1858]], [[../entities/concepts/caimacam-regency-moldavia]].
- **Two citation schemes confirmed & documented** in [[../sources/README]]: *Istoria* cited by
  the book's **printed** page numbers (bare-number lines; OCR reads leading "1" as "4" in some
  runs); *Unirea* by the `<!-- pdf page N -->` marker (clean text layer).
- **Integrity outcomes.** (a) Fixed a citation error in [[../entities/concepts/postal-history-romania]]:
  `p.437 / 437–438 / 438` → **137 / 137–138 / 138** (OCR "1"→"4" misread; verified against the
  monotonic printed-page sequence 135‑136‑137‑138‑140). (b) Subagents flagged, rather than
  asserted, facts the sources don't support — no "state monopoly" wording in Decree 615 (only
  the letter-post is state-run; passenger diligences were privatised); no on-stamp "Principatele
  Unite" legend (the 1862 joint design shows Eagle + aurochs head + post horn, values 3/6/30
  parale); the Paris Convention is *not* reproduced verbatim in vol. II (only quoted article-by-
  article in consular dispatches). Also fixed the *Istoria* source frontmatter `lang: fr` → `ro`.
- **Wired in:** [[../index]] "Context & story" (postal + geopolitics threads), [[../sources/README]].
- **Remaining:** promote drafts → reviewed; weave into narrative; the big sources still hold more
  (telegraph history, later postal legislation, the full Union primary-document set).

## 2026-07-05 — Session 8 (Wertheimer-Ghika 1944: photo-OCR + full concept mining)

- **User added** a **photographed** book: `input/references/1944-wertheimer-ghika-cartea-marcilor-cap-de-bou/`
  — 99 phone photos (~292 MB) of Jacques Wertheimer-Ghika, *Documentele Poștei Române: Cartea
  mărcilor „Cap de bou"* (Editura Cartea Românească, București, **1944**). Asked to OCR the whole
  raw text, then mine **every concept**. No book export.
- **New tool `tools/ocr_photos.py`** (photos, not PDFs): RapidOCR + the repo's column-aware
  line ordering; resumable per-image cache (`work/ocr/<id>.jsonl`); auto-orients landscape photos
  by best-confidence (0/90/270). → `sources/wertheimer-ghika-1944/text.md`, **99 photos, 143k chars,
  status: raw-ocr**, page-delimited `<!-- photo N -->` (cite by photo N + printed page where legible).
  97/99 photos carry solid text; only p1 (title), p99 (back cover) sparse; p15 is a garbled plate.
- **Mined into 6 new pages + 1 deepen** (one subagent each), all `status: draft`/`debated`, every
  claim cited by photo and verified against the photo markers:
  - [[../entities/references/books/wertheimer-ghika-1944]] (reference card),
    [[../entities/concepts/bull-head-authentication-and-fantasy-stamps]] *(debated — W-G vs. the
    "mărci fanteziste"; Moroiu/Aslan/Minescu polemic)*,
    [[../entities/concepts/bull-head-stamp-distribution-1858]] *(first issue: **24,064 printed**,
    only **2,419 sold** in its 2-month life; distribution via "expeditori din afară")*,
    [[../entities/concepts/franco-porto-apparatus-1858]] *(the Jurnalul franco-porto, recipise,
    chitanțe, blanchet de poștă)*,
    [[../entities/concepts/bull-head-postmarks-from-documents]] *(25 towns' FRANCO/PORTO/datestamps
    from the archives; cross-links census + Kiriac)*,
    [[../entities/events/beginnings-romanian-telegraph]] *(short honest stub — see gap below)*.
  - **Deepened** [[../entities/concepts/foreign-post-offices]] with a primary-evidence section
    (Austrian instructor-clerks, copied forms, German-spelled FRANCO marks; Alecsandri using the
    Russian post, 1859).
- **Integrity.** 0 broken links across all 7 pages; headline figures spot-checked against the OCR
  (24064, 2419, the Ismail 1858 seal). Agents kept OCR-uncertain proper names/figures **verbatim
  and flagged** rather than guessing; three garbled numeric grids marked `unverified`.
- **Coverage — verified complete (no re-shoot needed).** The 99 photos are **2-page spreads**: the
  cadence `printed page = 2×photo − 8` was confirmed visually (photo 15 = pp.22–23) and matches every
  agent's page citation through photo 96 (pp.184–185), then back cover (photo 99). Front matter →
  ~p.187 is captured continuously with no gaps. The book's ToC announces a Part IV telegraph chapter,
  but this volume contains **no such chapter** — it is genuinely absent (the five-part plan likely
  spans the wider *Documentele Poștei Române* series), not unphotographed. The only pages OCR can't
  turn into text are **illustration plates** (e.g. photo 15 = pp.22–23 PORTO-SCRISORI sheet; photo 96
  = pp.184–185 table) — captured sharply, but re-OCR/re-shoot won't read pictures; those need manual
  transcription if their data is wanted.
- **Wired in:** [[../index]] (postal, philatelic, postmarks, references, raw-sources), [[../sources/README]]
  (marked **mined**). Bibliography corrected from the title page: single author *Jacques
  Wertheimer-Ghika*.

## 2026-07-05 — Session 9 (evidence census + figure extraction)

- **User ask 1 — a census of every documented Bull's Head Issue I & II instance**, broadest scope
  ("any documented mention"), from **all cited sources**.
- Built [[../entities/census/bull-head-evidence-census]] via new tool `tools/gen_issue_census.py`
  (schema: issue · denom · evidence_type · on_cover · town · date · marking · provenance · value ·
  source · citation · note; data in `entities/census/data/records.csv|json`). Two layers:
  **auction** (587, converted from the existing `tools/census.py` lots+postmarks) + **mined**
  (425, one background subagent per source writing a validated JSON array to `work/issue-census/`).
  - Mined counts: other-sources 236 (botoșani 100, scăiceanu 73, philatelic-lit 28, magnus 21,
    timbrele 12, romanian-postal 2), book-narrative 69, kiriac-1974 68, wertheimer-ghika-1944 50,
    istoria-postei-1916 2. Dickinson/cercetări/bucureștiul = 0 (verified nothing on Bull's Heads).
  - **Total: 1,012 records** — Issue I 429, Issue II 551, `?` 32; 26 sources. Highlights folded in:
    Magnus's unique 27-parale specimen, Botoșani's Heimbüchler survival census, collection tallies
    (Ferrary/Caspary/Avery…), the Cristea 1958 inventory (397 specimens), the tête-bêche pairs, the
    24,064-printed/2,419-sold figures. Agents preserved each source's own (sometimes conflicting)
    numbers rather than reconciling; light dedup by design (each row = one documented mention).
  - Re-runnable: any new source adds a `work/issue-census/*.json` and re-runs the tool.
- **User ask 2 — detect & crop images from the references.** New tool `tools/extract_figures.py`:
  - `photos` mode (OpenCV) on the 99 Wertheimer photos → **212 crops** (165 individual stamps,
    4 whole plates, 43 figures) in `assets/sources/wertheimer-ghika-1944/figures/` + `_figures.json`
    manifest (photo·page·kind·bbox). Tuned closing 9×1 (recovers 28/30 stamps on the p.23 handstamp
    grid); text pages yield 0. Page-tagging near the gutter can be ±1 (cosmetic).
  - `pdf` mode: embedded rasters. **scaiceanu-2011** → 85 genuine figures (kept). Scanned PDFs
    (magnus, dickinson, **unirea 622**) yielded full-page *scans*, not figures → removed to avoid
    bloat. Magnus 1869 plates would need `photos`-style CV on rendered pages (offered, not yet done).
- **Wired in:** [[../index]] (Concepts → 📋 Evidence census). Census page cross-links
  [[../entities/postmarks/census]], [[../entities/references/compilations/bulls-head-lots]], the issue pages.
