---
id: meta/conventions
type: meta
title:
  en: Conventions — authorial rules extracted from the book
status: living
source: extracted from input/20251208-stamps-book.docx
---

# Conventions

Rules and conventions the book already follows, **extracted from the source
document** by mining its text, plus conventions we adopt going forward. Each is
numbered `C-NN`, phrased so it can be **audited** (a generated book either complies
or does not). See [[meta/audit-procedure]] for how these are checked, and
[[meta/requirements]] for higher-level product requirements.

> Evidence counts below are from the ingested document model (Pass 1). Where the
> book is inconsistent, the convention states the intended rule and the audit flags
> deviations.

## Notation

| # | Convention | Evidence / notes | Audit check |
|---|------------|------------------|-------------|
| C-01 | **Digit grouping uses a backtick** `` ` `` as the thousands separator, e.g. `2`500`000`, `12`000`. | 84 occurrences; consistent authorial style. | No large number uses `,`/`.`/space grouping; groups are 3 digits. |
| C-02 | **Catalogue citations** follow `<CAT> <COUNTRY> <NUMBER>`, e.g. `MI RO 6326`, `MI BG 5383`. CAT ∈ {MI, SC, SG, YT, LP}. | 131 `MI …` refs. Country is an [[glossary]] code. | Every catalogue citation parses to this shape; CAT and COUNTRY are known codes. |
| C-03 | **Dimensions** are written with a space and unit, `29 mm`, `30 mm`; diameter uses `∅`. | 60 `mm` values. | Measurements carry an SI unit; no bare numbers for physical sizes. |
| C-04 | **Dates** may carry a calendar marker: `(J)` Julian, `(G)` Gregorian (see AD/AH/YBP in [[glossary]]). Old-style Moldavian dates are Julian. | 13 `(J)` markers. | Ambiguous historical dates state calendar; conversions note both. |
| C-05 | **Currency/denomination** written as `<n> parale` (also para, kreuzer, kopeck, piastre, ducat, lei). Casing: lowercase `parale` in prose. | 506 `… parale`. | Denominations use a known currency unit from [[glossary]]. |
| C-06 | **Quotation** uses low-high curly quotes `„…"` (Romanian/German style), not straight quotes. | 106 occurrences. | Quotes in RO/DE use `„…"`; audit flags `"…"`. |

## Structure & cross-referencing

| # | Convention | Evidence / notes | Audit check |
|---|------------|------------------|-------------|
| C-07 | **Figures are numbered** `Figure N` and captioned; prose cross-refers by number. | 934 `Figure N` strings. | Figure numbers are unique, sequential, and every referenced number exists. |
| C-08 | **Tables are numbered** `Table N` with a caption. | 79 `Table N`. | Table numbers unique/sequential; references resolve. |
| C-09 | **Sections cross-referenced** with `§` + number, e.g. `§1.`, `§3.2`. | 493 `§…`. | Every `§ref` resolves to an existing section. |
| C-10 | **Headings encode facets with emoji markers** from [[glossary]] (📅 date, 💰 currency, 🧭 map, 📯 postal, 🐃 aurochs, 🌍 place, 📖 catalogue, ⨀ handstamp). | Pervasive in H2/H3. | Markers used in headings are all defined in [[glossary]]; none invented. |
| C-11 | **Heading language pattern**: heading text is English; the immediately following line gives the other three as `Română \| Français \| Deutsch`. | Consistent (e.g. "Introducere \| Introduction \| Einführung"). | Each titled section has all four language titles (see [[style]]). |
| C-12 | **Place is tagged** after content with `🌍 <place>`; map/geopolitics with `🧭`. | Pervasive in timeline headings. | Place tags reference a [[entities/places|place]] entity. |

## Content policy (adopted going forward)

| # | Convention | Rationale | Audit check |
|---|------------|-----------|-------------|
| C-13 | **Every factual claim carries a reference.** Claims live in concepts with `refs:`; narrative inherits them. | Credibility of a reference work. [[decisions/DR-007-references-for-claims]] | No claim page/section marked `needs-ref`; sampled claims trace to a [[entities/references/auctions|reference]]. |
| C-14 | **Debated points are marked, not resolved.** `status: debated` with positions + who holds them (e.g. aurochs vs. wisent). | Scholarly honesty. [[decisions/DR-006-mark-debated-concepts]] | Known controversies appear as `debated`, not asserted as settled. |
| C-15 | **Four languages stay in lockstep or are flagged.** A section missing a language, or with stale translation vs. the English master, is a defect. | Consistency of the 4-up edition. | Per [[style]]; audit reports missing/stale translations. |
| C-16 | **The aurochs `🐃` is the throughline.** The animal marker threads natural history → heraldry → the stamp; keep the symbolic link explicit. | Editorial identity of the book. | Aurochs-tagged sections link to [[aurochs]]. |
| C-17 | **Legend vs. fact is labeled.** Anecdotes, traditions, and legends (e.g. Dragoș & the aurochs hunt) are marked as such (`legend` / `tradition` / `disputed`) and distinguished from documented, sourced fact. | Color without sacrificing credibility ([[decisions/DR-013-heritage-thesis-and-enrichment]]). | Story passages carry a legend/fact marker; documented claims cite a source. |

## Open convention questions (to confirm with the user)

- C-01 backtick grouping is unusual for an English-reading audience — keep, or switch
  to thin-space/`,` per edition? (Recorded pending; see [[strategy/multilanguage-analysis]].)
- Whether `parale` is capitalised in titles vs. lowercase in prose — normalise which way.
- Julian↔Gregorian: **resolved** by [[decisions/DR-015-ui-concept|DR-015]] — primary
  (source calendar, Julian for this material) + Gregorian in parentheses, with a
  tappable ᴶ⁄ᴳ tag in the app: `1 (13) June 1865`. Year ranges stay plain. Renotating
  the existing prose markers is a separate audited pass.
