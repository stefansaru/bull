---
id: meta/ontology
type: meta
title:
  en: Ontology — entity types & relations
status: living
---

# Ontology

The entity types of the Bull's Head wiki and how they relate. Every page in
`entities/` has a `type` from this list. Narrative pages reference entities by
`[[wikilink]]`. Grounded in the author's own glossary ([[glossary]]).

## Entity types

| type | folder | what it is | key examples |
|------|--------|-----------|--------------|
| `issue` | `entities/issues/` | A distinct printing/emission of Bull's Head stamps | [[issue-bull-1]] (🐃 1), [[issue-bull-2]] (🐃 2) |
| `denomination` | `entities/denominations/` | A face value within an issue | 27, 54, 81, 108 parale (issue 1); 5, 40, 80 parale (issue 2) |
| `position` | `entities/denominations/` | A single plate position of a denomination (sub-page) | e.g. 108-parale position 1..N |
| `handstamp` | `entities/handstamps/` | A cancellation / hand stamp device | [[PM52]], [[M1]], [[M2]], [[M3]], [[C1]] |
| `place` | `entities/places/` | Geographic entity (county, city, country) | Iași, Moldavia, Bucharest, counties |
| `person` | `entities/people/` | A historical actor | Dragoș, Stephen the Great, Grigore Ghica, Vogoride |
| `catalogue` | `entities/catalogues/` | A philatelic/numismatic reference catalogue | [[Michel]] (MI), [[Scott]] (SC), [[Stanley-Gibbons]] (SG), [[Yvert-Tellier]] (YT), [[LP]] |
| `reference` | `entities/references/` | A cited bibliographic source | books, articles, archives |
| `color` | `entities/colors/` | A colour used, with standards (RAL/AMS) | blacks, blues, etc. |
| `concept` | `entities/concepts/` | A thing/idea with its own page | [[aurochs]], [[aurochs-vs-wisent]], paper types, currencies, calendars |
| `event` | narrative | A dated historical event (usually a narrative H2) | postal reform 1858, treaties, wars |

## Core relations (expressed via wikilinks + frontmatter)

```
issue        --has_denomination-->  denomination
denomination --has_position------>  position
denomination --printed_in-------->  color
denomination --printed_on-------->  concept(paper type)
stamp/cover  --cancelled_by------>  handstamp
denomination --catalogued_as----->  catalogue (with catalogue number)
narrative    --depicts----------->  any entity   (figures)
narrative    --cites------------->  reference
event        --located_in-------->  place
event        --involves---------->  person
```

Relations live as `entities:` / typed keys in frontmatter *and* as inline
`[[links]]` in prose, so both a human and a graph view see them.

## Naming conventions

- Entity file slugs are kebab-case, English: `issue-bull-1.md`, `108-parale.md`,
  `PM52.md` (handstamp codes kept as-authored), `michel.md`.
- Denomination pages: `<value>-parale.md`; positions as `## Position N` sections or
  `<value>-parale/pos-NN.md` if a denomination grows too large.
- One entity = one file. Merge duplicates; never fork a second page for the same
  thing ([[decisions/DR-002-one-entity-one-file]]).

## The emoji marker system

The author encodes metadata in headings with emoji (see [[glossary]]). These are
**not decoration** — they are a faceting system. The structuring pass records them
as `markers:` in page frontmatter so pages can be filtered by facet (all `📯`
postal events, all `💰` currency notes, etc.).
