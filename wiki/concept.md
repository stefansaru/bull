---
id: concept
type: meta
title:
  en: Bull's Head Wiki — Concept
status: living
---

# Bull's Head Wiki — Concept

> Seed document. Companion files: [[AGENTS]], [[ontology]], [[glossary]],
> [[frontmatter-schema]], [[style]], [[decisions/DR-001-wiki-not-just-book]].
> The user is the ultimate source of truth.

## 1. What this is

A local, AI-native **knowledge wiki** for the study of the **Moldavian "Bull's Head"
(*Cap de bour* / aurochs-head) postage stamps of 1858** — the first stamps of the
Romanian principalities. It is the normalised, cross-linked, versioned substrate
distilled from the author's 4-language A4 book
(`input/20251208-stamps-book.docx`, ~300 pages, 1049 images).

The wiki is the **source of truth**; the book is one **rendering** of it. A
deterministic exporter ([[decisions/DR-005-exporter-rebuilds-book]]) rebuilds the
original 4-language A4 quadrant book (EN top-left, RO top-right, FR bottom-left,
DE bottom-right) from the wiki. Other renderings (per-language editions, HTML) are
possible later from the same substrate.

## 2. Why a wiki and not just a book

A linear 4-language document cannot express what a philatelic study *is*: a graph.
A single stamp position links to its plate, its issue, its colours, its paper, its
cancellations, the covers it survives on, the forgers who copied it, and the
catalogues that price it. The book flattens that graph into reading order and
repeats facts across chapters. The wiki keeps the graph explicit and lets the book
be *generated* from it, so a fact is stated once and rendered many times.
See [[decisions/DR-001-wiki-not-just-book]].

## 3. Two co-existing structures (hybrid)

1. **Narrative** (`narrative/`) — the book, faithfully, in reading order. One page
   per section, all four languages co-located, images in place. This is the
   **verbatim baseline** ([[decisions/DR-004-verbatim-first]]); nothing is edited
   here without an explicit, reviewable improvement pass.
2. **Entities** (`entities/`) — the knowledge graph: issues, denominations,
   handstamps, places, people, catalogues, colours, paper, concepts. Entity pages
   synthesise and cross-reference; narrative pages `[[link]]` into them.

The two are joined by `[[wikilinks]]`. Provenance (`source_blocks`, `order`) on
every narrative page ties it back to the exact blocks of the source document, so
the exporter can reproduce book order and any claim can be traced to its origin.

## 4. Languages

English is the **master** language ([[decisions/DR-003-english-master]]). Romanian,
French and German are co-located translations on the same page. When English
changes, the translations are flagged stale until re-checked. The book was authored
Romanian-first in places; discrepancies between languages are recorded, not silently
resolved. See [[style]].

## 5. The domain in one breath

Moldavia, 1858. Under Ottoman suzerainty and recent Austrian/Russian occupation,
on the eve of union with Wallachia, the Moldavian post issues hand-made stamps
bearing the **aurochs head** — the ancient emblem of the land. Two issues appear:

- **🐃 1** (first issue): **27, 54, 81, 108 parale**.
- **🐃 2** (second issue): **5, 40, 80 parale**.

They are crudely printed, heavily forged, and historically enormous: symbols of an
emerging nation. The study spans the animal itself (natural + cultural history),
the 19th-century run-up, the postal reform of 1858, the handstamps
(**PM52, M1, M2, M3, C1**), each denomination plate-by-plate, and the reference
apparatus (catalogues, counties, cities, papers, colours). See [[index]] and
[[ontology]].

## 6. Status

Pass 1 — ingestion. Extractor + structuring built; narrative being generated
verbatim; entity graph being seeded from the outline and the author's glossary.
Improvement, gap-filling from external catalogues/references, and the finalised
book export follow.
