---
id: meta/errata
type: meta
title:
  en: "Source errata — inconsistencies in the reference works"
status: living
---

# Source errata — inconsistencies in the reference works

A running log of **internal inconsistencies, errors and ambiguities** found in the
source works as concepts are derived from them. The point is not to disparage the
sources — several are foundational — but to record, transparently, where a source
contradicts itself or where a claim rests on a doubtful reading, so downstream
concept pages can flag `debated`/`needs-ref` honestly (see
[[decisions/DR-006-mark-debated-concepts|DR-006]], [[decisions/DR-007-references-for-claims|DR-007]]).

Each entry: **what** the problem is, **where** (page/photo/figure/code), and **why**
it is inconsistent or uncertain. Distinguish a genuine **source error** (the book
contradicts itself) from an **OCR/reading artefact** (our transcription is unsure).

---

## Dragomir, *Ștampilografie Poștală* (1990) — [[../entities/references/dragomir-stampilografie-1990|reference]]

Kiriac Dragomir's handstamp catalogue is the foundational source for the pre-stamp
markings, but the photographed copy shows the following issues. Citations are to
[[../sources/dragomir-stampilografie-1990/text|the raw OCR]] by photo.

### Classification / code system
1. **`FM`/`FV` — the code letter "F" is never expanded.** By analogy with the class
   prefixes one reads *Franco Moldova / Valahia*, but §1.3's text and figures document
   the **sigillary handstamps on the leased road-post's transport forms** (eagle +
   post-cart), *not* "FRANCO"-lettered prepayment marks; the word *Franco* is not used
   as the section's subject (photos 44, 57). The wiki treats "Franco M/V" as a **code
   gloss only** and describes the documented content as transport-form seals — see
   [[../entities/concepts/franco-porto-handstamps]]. The true FRANCO/PORTO prepayment
   apparatus is a different thing ([[../entities/concepts/franco-porto-apparatus-1858]]);
   the obliterating FRANCO is `M3`.
2. **`SV` is an overloaded code.** In the *ABREVIERI* `SV` = *Sigilare Valahia* (a
   marking class) **and** `SV` = *Suceava* (a county in the JUDEȚE list) (photo 8).
   Disambiguated only by position/context.
3. **Auxiliary classes absent from the main key.** `SAD` (districtuale), `SAS`
   (sătești), `ST` (telegrafice) and `SAV` (vamale) are used as class codes in Part 2
   but are **not listed in the *ABREVIERI*** indicative table (photo 8).

### Duplicate / conflicting figure numbers
4. **Fig. 87 is used twice** — for the **Călărași** station seal (§1.2.5, feather-seals)
   *and* for the **Rusi de Vede** post-captain (§1.2.4). One of the two is a
   print/typesetting error; verify against the plates.
5. **Fig. 93 is printed for two devices** — the **Mirila** and the **Movilița**
   post-captains' seals (§1.2.4). Same issue.

### Devices referenced but not fully catalogued
6. **`SM57`** appears only as a **column in TABEL I** (photo 13); Dragomir gives it no
   descriptive paragraph or figure, so its device is undocumented beyond the table
   listing (~1857 directorate row).

### Legend spellings / reading
7. **"DESPORTIREA" → DESPĂRȚIREA** — a Wallachian road-office legend prints/OCRs as
   *DESPORTIREA*; the intended word is *Despărțirea* (the "division/section" of a road).
8. **Garbled device codes in the OCR** (transcription artefacts, not source errors):
   `SPMc9a` = **SPM59a**, `SV5l` = **SV51**, `Sv33` = **SV33**, `SPMc62c` = **SPM62c**.
   Codes were normalised against the illustrations when deriving concepts.

### Metadata
9. **Imprint year unconfirmed.** The wiki dates the book **1990** (the date carried by
   earlier references to "the 1990 *Ștampilografie*"); the copyright page is not among
   the legible photos. Content spans 1822–1910 regardless.

*(Further Dragomir issues will be appended as the remaining sections — PM/PV
prefilatelice and the auxiliary SAD/SAS/ST/SAV classes — are derived.)*

---

## The three stamp catalogues (2006 / 1984 / undated)

From mining the Bull's Head valuations ([[../entities/references/bull-head-catalogue-valuations|comparison]]):

10. **First-issue date disagreement.** [[../entities/references/carjan-manole-timbre-2006|Cârjan-Manole 2006]]
    gives the first issue as **15 July 1858**, while
    [[../entities/references/spineanu-catalog-marci-1984|Spineanu 1984]] and
    [[../entities/references/chirices-pascariu-catalog|Chiricheș-Pascariu]] give **22 July
    1858** (the date used elsewhere in this wiki — see [[../entities/issues/issue-bull-1]]).
11. **Cârjan-Manole internal price inconsistency.** Its issue-II **summary table** gives
    40 parale = 400/300 and 80 parale = 1 675/800, contradicting its own **dedicated
    per-stamp pages** (450/350 and 850/700). The dedicated pages are taken as
    authoritative on the comparison page; the discrepancy is noted there.
12. **Chiricheș-Pascariu price unit not legible.** The magnitudes suggest a converted
    EUR-like unit, but the unit is not stated on the photographed pages — values are
    recorded with a "⚠ verify" caveat.
13. **Terminology drift.** The stamps' subject is called *Cap de bour* in most sources
    but *Cap de zimbru* (bison) in places — the aurochs/wisent question the wiki tracks
    as `debated` at [[../entities/concepts/aurochs-vs-wisent]].

---

## See also
- [[../entities/references/dragomir-stampilografie-1990]] — the handstamp reference + code key
- [[../entities/references/bull-head-catalogue-valuations]] — the cross-catalogue comparison
- [[decisions/DR-006-mark-debated-concepts]] · [[decisions/DR-007-references-for-claims]]
</content>
