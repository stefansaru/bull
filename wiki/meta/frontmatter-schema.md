---
id: meta/frontmatter-schema
type: meta
title:
  en: Frontmatter schema
status: living
---

# Frontmatter schema

Every wiki page starts with YAML frontmatter. Two profiles: **narrative** and
**entity**. Unknown keys are allowed but discouraged; add them here first.

## Narrative page (English master)

The `.md` page holds **English only** (DR-003/DR-010). Each content unit is preceded
by a marker `<!-- u:UID kind:… -->` (UID = `u`+min source-block, sorts in document
order). Translations live in the sidecar (below), not here.

```yaml
---
id: narrative/04-1858/003-postal-reform-1858     # stable path-like id
type: narrative-section
chapter: "1858"                                  # H1 chapter label
order: 421                                        # global position for book export
level: 2                                           # heading level (1..3)
edition_master: en                                 # this file is the English master
title:
  en: "1858 📯 Postal Reform 🌍 Iași (Jassy)"     # RO/FR/DE title (if any) live in sidecar
markers: ["📅", "📯", "🌍"]                        # emoji facets from the heading
source_blocks: [612..615]                          # provenance into document_model
status: verbatim                                   # verbatim | reviewed | improved
---

## 1858 📯 Postal Reform 🌍 Iași (Jassy)

<!-- u:u00612 kind:quad -->
The Moldavian post reorganised …                   # English prose (master)

<!-- u:u00614 kind:figure -->
![image1.png](../../assets/media/image1.png)
*Figure 421: …*
```

## Translation sidecar (`<page>.i18n.yml`)

Mirrors the page basename. One entry per translatable UID; `en_hash` is the hash of
the English the translation was made from (staleness key — see
[[decisions/DR-010-translation-storage]] and `tools/i18n_status.py`).

```yaml
page: narrative/04-1858/003-postal-reform-1858
title: {ro: "…", fr: "…", de: "…"}                 # translated heading (optional)
units:
  u00612:
    kind: quad
    en_hash: 4d61116c                               # EN this was translated from
    ro: {status: ok,    text: "Poșta moldovenească …"}
    fr: {status: ok,    text: "La poste moldave …"}
    de: {status: stale, text: "Die moldauische Post …"}   # EN changed since -> recheck
  u00990:
    kind: text
    orphan_lang: ro                                  # non-English loose fragment, no EN yet
    status: orphan
    text: "…"
```

## Entity page

```yaml
---
id: entities/denominations/108-parale
type: denomination
title:
  en: "108 Parale"
  ro: "108 Parale"
  fr: "108 Parale"
  de: "108 Parale"
issue: "[[issue-bull-1]]"                          # typed relations
value_parale: 108
colors: ["[[black]]"]
paper: ["[[paper-type]]"]
catalogue_refs:
  michel: "…"
  scott: "…"
narrative_refs: ["[[108-parale]]"]                # narrative sections about it
source_blocks: [1830, 1831]
status: draft                                       # draft | reviewed | verified
---
```

## Keys every entity may carry (bull DR-015)

```yaml
summary: "One or two sentences."   # the app's preview text; else the first paragraph is used
related: ["[[other-page]]"]          # curated links, shown under Related artefacts
year: 1858                           # or a range "1858–1862": the app's date line
generated_by: tools/gen_x.py         # set by generators; delete it to take the page over by hand
```

## Colour page (`entities/colors/<slug>.md`, generated)

```yaml
type: color
title: {en: Carmine red, ro: Roşu carmin, fr: Rouge carmin, de: Karminrot}
family: red                          # blue | green | red | neutral
hex: '#A4343A'                       # the page swatch (first standard)
swatches:                            # one per standard the book names
- {system: pantone, code: '1807', name: Carmine Red, description: '', hex: '#A4343A'}
hex_source: author's book, colour table cell shading (screen approximation; the standard's code is authoritative)
```

`hex` values are read from the cell shading of the author's colour tables
(`tools/extract_swatches.py`). Systems: pantone, ral, ams, ams-std, ncs, web, other.

## Abbreviation page (`entities/abbreviations/abbr-<slug>.md`, generated)

```yaml
type: abbreviation
abbr: "MI Mi"                        # as printed in Table 2
forms: [MI, Mi]
category: catalogue                  # calendar | country | colour standard | catalogue | postal | money | handstamp | organisation | general
expansion: {en: …, ro: …, fr: …, de: …}
see: "[[../references/catalogues/michel]]"   # the fuller page, when one exists
```

Slugs carry an `abbr-` prefix so they never collide with catalogue or handstamp stems.

## Image rights registry (`assets/rights.yml`)

Images carry no frontmatter of their own. Their rights live in one registry keyed by
path under `wiki/`. The app pipeline (`app/wizard`) reads it and ships only `cleared`
images; the book exporter should honour it too once the *Q-commercial* decision is taken.
Full procedure: `app/docs/content-pipeline.md`.

```yaml
images:
  assets/media/image219.jpg:
    status: pending      # pending | cleared | omit
    source: references/books/dragomir-stampilografie-1990   # the reference it comes from (DR-014)
    locator: "fig. 412"  # page / figure / lot within that reference
    provenance: ""       # only when there is no `source`: own scan, archive, …
    licence: ""          # own work / public domain (why) / permission (ref) / licence name
    note: ""             # where the permission document is kept, caveats
```

A `pending` image inherits its source's `rights_default` (below). `cleared` needs a
provenance (its own, or the source's title) and a licence (its own, or the default).
`--rights-init` adds new images as `pending` and fills an empty `source` from the
references' `assets:` prefixes; it never changes a decision.

## Reference page (`entities/references/<kind>/<slug>.md`)

```yaml
---
id: entities/references/books/dragomir-stampilografie-1990
type: reference
ref_type: book            # see DR-014 for the values per folder
title: {en: "…", ro: "…"}
author: "…"
year: 1990
publisher: "…"
series: "[[lp]]"          # catalogue editions → their catalogue series
in: "[[…]]"               # articles → the journal, book or site they appear in
domains: [colnect.com]    # web/ and archives/ pages → matched by tools/link_report.py
reliability: secondary    # web/ and archives/: primary | primary-host | secondary | tertiary | unverified | archive-copy
assets: ["assets/sources/dragomir-stampilografie-1990/"]   # images taken from this reference
rights_default: {status: pending, licence: "", note: ""}    # inherited by those images
status: draft             # draft | reviewed | verified | needs-identification
---
```

A `needs-identification` reference cannot back a claim (DR-007) until its author,
date or origin is recorded.

## Conventions

- `title` is always a 4-language map; English is required, others optional.
- `order` is unique and monotonic across all narrative pages — it *is* book order.
- `status`: `verbatim` (untouched ingest) → `reviewed` (a human/agent checked it) →
  `improved` (deliberately edited, diff-tracked). Never silently jump to `improved`.
- Provenance (`source_blocks`) is never removed; it is how any page traces to source.
