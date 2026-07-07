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

## Conventions

- `title` is always a 4-language map; English is required, others optional.
- `order` is unique and monotonic across all narrative pages — it *is* book order.
- `status`: `verbatim` (untouched ingest) → `reviewed` (a human/agent checked it) →
  `improved` (deliberately edited, diff-tracked). Never silently jump to `improved`.
- Provenance (`source_blocks`) is never removed; it is how any page traces to source.
