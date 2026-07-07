---
id: strategy/vision-mission-objectives
type: strategy
title:
  en: Vision, mission & objectives
status: draft
note: Co-authored with the user 2026-07-04; confirm/adjust the wording.
---

# Vision, mission & objectives

> Draft for the user to confirm. These frame every downstream decision; if the
> wording is off, fix it here first. See [[market-research]], [[target-audience]],
> [[multilanguage-analysis]], and [[../meta/requirements]] (REQ-S).

## Vision

*The definitive, trustworthy, and beautiful reference on the Moldavian Bull's Head
stamps of 1858 — where every claim is sourced, every debate is honest, and the story
of the aurochs, the nation, and the stamp is told as one.*

## Mission

To gather the scattered scholarship, images, and catalogue data on the *Cap de bour*
issues into a single, cross-linked, **referenced** knowledge base, and from it to
publish a study that a beginner can enjoy and a specialist can trust — closing the
gaps left by existing, mostly out-of-print and single-language works.

## What makes it different (value proposition)

1. **Sourced.** Every factual claim carries a reference ([[../meta/decisions/DR-007-references-for-claims]]);
   the field's existing books often don't.
2. **Honest about uncertainty.** Debated points (aurochs vs. wisent, disputed plating,
   dating) are shown as debates, not settled facts ([[../meta/decisions/DR-006-mark-debated-concepts]]).
3. **The aurochs throughline.** Natural history → heraldry → the stamp, as one
   narrative — not just a catalogue.
4. **Single source, many editions.** Built from a wiki, so it can ship as the right
   edition(s) for each audience without redundant labour ([[multilanguage-analysis]]).
5. **Image-first.** 1000+ images; layout serves the images, which are the point of a
   philatelic reference.

## Goals (outcomes)

- **G1 — Authority.** Be citable: reviewers and dealers reference it. Enabled by
  REQ-C3/C4/C5.
- **G2 — Accessibility.** Approachable to newcomers *and* useful to specialists
  ([[target-audience]]).
- **G3 — Heritage.** Do justice to the Romanian/Moldavian national story.
- **G4 — Sustainability.** A living substrate that absorbs new discoveries and
  re-publishes cheaply.

## Objectives (this build — measurable)

| # | Objective | Done when |
|---|-----------|-----------|
| O1 | Faithful ingestion of the current book into the wiki | Coverage audit passes (REQ-C1/C2); all sections present, verbatim, with provenance |
| O2 | Concept graph seeded | Every issue, denomination, handstamp, catalogue, place has an entity page (REQ-C6) |
| O3 | Claims referenced | `needs-ref` count trending to zero on core chapters (REQ-C3) |
| O4 | Language strategy decided | DR-009 accepted, grounded in research (REQ-L3, [[multilanguage-analysis]]) |
| O5 | Book regenerates from wiki | Exporter reproduces the book deterministically (REQ-B1/B2) |
| O6 | Auditable | `tools/audit.py` runs Stage A/B and produces a report ([[../meta/audit-procedure]]) |

## Non-goals (for now)

- Not a price guide kept current to the market (catalogue snapshots only).
- Not an exhaustive worldwide aurochs monograph — the animal serves the stamp.
- Not a web product yet (local wiki first; HTML edition is a later option).

## Open strategic questions

- **Q-lang** — how many languages does the *published* book ship in? (DR-009,
  [[multilanguage-analysis]] recommends English master + generated RO/DE/FR.)
- **Q-goal** — reference work vs. heritage art object? (Changes format & audience —
  [[multilanguage-analysis]] §hinges.)
- **Q-scope** — one book or a series? (The material may split by issue; revisit after
  ingestion sizing.)
- **Q-commercial** — sell (print-on-demand / PDF), or open/heritage? Affects licensing
  of images and references.
