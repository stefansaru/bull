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

## Dragomir, *Ștampilografie Poștală* (1990) — [[../entities/references/books/dragomir-stampilografie-1990|reference]]

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
   - **`FV` form-frame range — summary vs captions.** The §1.3 summary sentence says the
     Wallachian transport forms are framed *Md. I – Md. XI*, but the individual figure
     captions run to **Md. XIII** (Fig. 119 = Md. XII, Fig. 120 = Md. XIII). The device
     page [[../entities/handstamps/FV]] uses the true maximum (XIII); the summary
     under-counts.
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

### Auxiliary sigillary classes (Part 2 — SAD / SAS / ST / SAV)

From deriving [[../entities/concepts/auxiliary-sigillary-stamps]] and its device pages
(photos 92–107; several plate pages are rotated and low-contrast):

10a. **Class letter `ST` is never actually used — the devices are coded `TL`.** The
   §2.4 header reads *ȘTAMPILE TELEGRAFICE («ST»)* (photo 96), but all 11 devices are
   coded `TL55…TL71` and the Planșa 13 caption itself reads *«TL»* (photo 102). The
   letter `ST` appears nowhere in the catalogue body.
10b. **Customs prefix `SAV` vs `SV`.** §2.5 is headed *«SAV»* (photos 103, 106), but the
   device descriptions code them `SV` (`SV.GALATI`, `SV.DORNA`, `SV.VIRCIOROVA`,
   `SV.SOVEJA`) while the cross-references and Planșa 14 caption use `SAV` — the *same*
   device appears as "SV.DORNA" in the text and "SAV.DORNA" on the plate. `SV` also
   collides with `SV` = *Sigilare-Valahia* (the postal seals) — see item 2.
10c. **Planșa 14 caption vs text — permuted figure↔office assignments (customs).** The
   descriptive text assigns Fig. 193 Dorna, 194 Cubei, 195 Vîlcov, 196 Bicaz, 197
   Soveja, 198 Cornu Luncii, 199 Tatar Bunar, 200 Kilia; the plate caption pairs the
   same figure numbers with a different order (e.g. caption Fig. 197 = Tatar Bunar vs
   text Fig. 197 = Soveja) (photo 107). ⚠
10d. **Customs "Linia convențională" numbering error.** The eastern-line sublist runs
   63(?), 69, 70, 71, 72 — the first should be **68**; as printed "63" duplicates
   Ștefănești (already #63) and **68 is missing** (photo 103).
10e. **Duplicate customs office entries.** BICAZ (Neamț) is listed at both **#46 and #49**;
   DĂRĂBANI (Dorohoi) at both **#58 and #62** (photos 103–104).
10f. **The section note's `SAV` numbers don't match the list positions.** `SAV 49` Cornu
   Luncii, `SAV 64` Cubei, `SAV 65` Tatar Bunar correspond to list positions #53, #71,
   #72 (photos 103, 107).
10g. **Planșa 12 caption vs text (village `SAS`).** Text: Fig. 181 Satul Păucești, 182
   Țintăreni, 183 Soveja; the plate caption appears to label Fig. 181 as *Satul Soveja*,
   duplicating Soveja (181 & 183) and dropping Păucești (photo 95). ⚠
10h. **`SAS` entry 1 legend interleaved with entry 2.** "1. Satul Haimanale (Fig. 179)"
   carries an exergue (*"ȚĂNUTUL No. 80 KAHUL 1859 … SATUL TOPORU"*) that belongs to
   entry 2 (Satul Toporu, Ținutul Cahul); the two entries' legends read as mixed (photo 95).
10i. **`SAS` Satul Podoleni described but not figured** — a full description, no Fig.
   number, absent from Planșa 12 (which runs Fig. 179–183 only).
10j. **Figure-number gap at 184.** §2.3 (Planșa 12) ends at Fig. 183 and §2.4 (Planșa 13)
   opens at Fig. 185; **Fig. 184** is not located in these sections. ⚠
10k. **Spelling: "ISPECTORATUL".** The `TL59` device prints *ISPECTORATUL GENERAL* in
   the body (photo 98) but *INSPECTORATUL* in the Planșa 13 caption and in the seal's
   own legend (photo 102) — a dropped N in the body text.

### Prefilatelice (Part 2 — PM / PV)

From deriving [[../entities/handstamps/PM52]], [[../entities/handstamps/PM57]],
[[../entities/handstamps/PV53]] et al. (photos 114–135):

14. **PM52 FRANKO — the counts don't reconcile (18/16 vs 19/17); Bolgrad missing.**
    §1.1.1 states *"se cunosc 18 ștampile"* and Plate 15 shows 18 figures (Fig. 205–222),
    but the same *Istoric* says that from 1856 *"se cunoaște existența a **19** ștampile
    'franco' pentru **17** birouri"* (Iași and Galați with two each). **Bolgrad** is
    named as a new 1856 franco office yet is absent from both the numbered list and
    Plate 15 (photos 114–115).
15. **`FRANKO` vs `FRANCO`.** The heading and the Cyrillic device read **ФРАНКО /
    FRANKO**, but the body codes the same device **"P52.FRANCO"** throughout (photo 114).
16. **`PM57` ≡ `M1` — the same dies catalogued under two codes.** §1.1.2 "Ștampilele
    prefilatelice MOLDOVA (PM57)" has **no plate or figures of its own**; it calls the
    marks *"ștampile M1.MOLDOVA"* and reuses Planșa 18 / Fig. 287 from the `M1` chapter.
    The identical devices appear twice in the book (photos 115, 118 vs 139).
17. **`PM57` provenance conflict.** The 1857 Vienna (Radnitzky) order is credited to
    **Teodor Balș** here (photo 115) but to **Teodor Ghica**, the diligence entrepreneur,
    in the `M1` chapter (photo 139) — same dies, two different commissioners.
18. **`PM57` count muddle / extra bureau.** The text mixes **nine** prephilatelic
    MOLDOVA marks with **six** "missing / in delivery", and asserts a **15th office
    (Tg. Neamț)** beyond Plate 18's stated 14 bureaus — the numbers are not reconciled
    (photo 118).
19. **`PV53` spelling drift.** Five towns are spelled two ways within the section —
    BUKURESTI/BUCURESTI, KIMPULUNG/KAMPULUNG, RIMNIKU VILCEA/RĂMNIKU VALCEA,
    TIRGOVISTE/TARGOVISTE, PLOESCI/PLOESTI (photos 129–130).
20. **`PV53` duplicated item number.** The Planșa 17 note claims *"7 scrisori"* but the
    enumerated letters run 1, 2, 3, 4, 5, **6, 6** (Fig. 265 and 266) — a duplicated "6"
    (photo 129).
21. **`PV53` plate assignment ambiguity.** The datestamps are assigned to **Planșa 16**
    and the covering letters to **Planșa 17**; which plate carries the 26 impressions is
    not stated explicitly (photo 129).
22. **Figure-number gap 233–259.** In the photographed run the FRANKO letters end at
    **Fig. 230** and PV53 material resumes at **Fig. 260**; ≈27 figures (233–259) are
    unaccounted for in the captured pages (photos 128–129). ⚠ (may be uncaptured pages
    rather than a book error).
23. **`PV55` text vs figure.** §1.2.3 mentions a legend *"jos, în caractere majuscule
    latine"*, but Fig. 267–268 both show **Cyrillic** legends — the phrase likely
    mis-scopes the neighbouring round `PV59`/`PV62` marks (photos 133, 135). ⚠

> **Scope note — post-classic classes not in the photographed source.** The captured
> 155 photos run through §2.3 (the `M3` Franco obliterators, Cuza issue) and **stop at
> the classic obliterators `M1`/`M2`/`M3`**. The **post-classic service classes** of
> the *ABREVIERI* key — `B` (postclasice), `CFR`, `PA`, `OB`/`OBt`, `OS`, `OT`, `SMR`,
> `NFR`, `R`, `A`, `S`, `D`, `DR`, `GN`, `GR`, `H`, `SD`, `AS`, `BA` — appear **only in
> the front-matter key** (photos 8–9), not as catalogued device chapters in the
> photographed pages. Per-device pages for those classes **cannot be built from this
> source**; they would need the later pages of the book (or a later volume). This
> covers the whole of Dragomir's **1822–~1872 classic/pre-classic** material, which is
> the wiki's focus.

---

## The three stamp catalogues (2006 / 1984 / undated)

From mining the Bull's Head valuations ([[../entities/references/compilations/bull-head-catalogue-valuations|comparison]]):

24. **First-issue date disagreement.** [[../entities/references/catalogues/carjan-manole-timbre-2006|Cârjan-Manole 2006]]
    gives the first issue as **15 July 1858**, while
    [[../entities/references/catalogues/spineanu-catalog-marci-1984|Spineanu 1984]] and
    [[../entities/references/catalogues/chirices-pascariu-catalog|Chiricheș-Pascariu]] give **22 July
    1858** (the date used elsewhere in this wiki — see [[../entities/issues/issue-bull-1]]).
25. **Second-issue end-date disagreement.** For the *end* of the second issue,
    Cârjan-Manole gives **1 May 1862** while Spineanu gives **5 May 1862**
    (Chiricheș-Pascariu: "1862 May"). A one-day-vs-five slip, each faithful to its
    catalogue; noted on [[../entities/references/compilations/bull-head-catalogue-valuations|the comparison]].
26. **Cârjan-Manole internal price inconsistency.** Its issue-II **summary table** gives
    40 parale = 400/300 and 80 parale = 1 675/800, contradicting its own **dedicated
    per-stamp pages** (450/350 and 850/700). The dedicated pages are taken as
    authoritative on the comparison page; the discrepancy is noted there.
27. **Chiricheș-Pascariu price unit not legible.** The magnitudes suggest a converted
    EUR-like unit, but the unit is not stated on the photographed pages — values are
    recorded with a "⚠ verify" caveat.
28. **Terminology drift.** The stamps' subject is called *Cap de bour* in most sources
    but *Cap de zimbru* (bison) in places — the aurochs/wisent question the wiki tracks
    as `debated` at [[../entities/concepts/aurochs-vs-wisent]].

---

## See also
- [[../entities/references/books/dragomir-stampilografie-1990]] — the handstamp reference + code key
- [[../entities/references/compilations/bull-head-catalogue-valuations]] — the cross-catalogue comparison
- [[decisions/DR-006-mark-debated-concepts]] · [[decisions/DR-007-references-for-claims]]
