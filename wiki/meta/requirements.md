---
id: meta/requirements
type: meta
title:
  en: Requirements — auditable
status: living
---

# Requirements

Numbered, auditable requirements for the wiki and the generated book. Each has an
ID, a MoSCoW priority (**M**ust / **S**hould / **C**ould / **W**on't-yet), and an
audit hook (how [[meta/audit-procedure]] verifies it). Conventions `C-NN` in
[[conventions]] are the fine-grained notation rules; these are the higher-level
product/content/technical requirements.

## Content requirements (REQ-C)

| ID | Pri | Requirement | Audit hook |
|----|-----|-------------|-----------|
| REQ-C1 | M | Ingestion is **complete**: every block of the source doc is represented in the wiki (narrative) or deliberately excluded with a reason. | Coverage report: `source_blocks` union = all blocks; list exclusions. |
| REQ-C2 | M | Ingestion is **faithful**: verbatim text preserved; no silent edits at `status: verbatim`. | Diff sampled pages vs. source; status transitions are diff-tracked. |
| REQ-C3 | M | **Every factual claim is referenced** (C-13). | Sample N claims; each resolves to a [[entities/references|reference]]. Zero `needs-ref`. |
| REQ-C4 | M | **Debated points are marked** `debated` with positions + holders (C-14), never asserted as settled. | Known controversies (aurochs vs. wisent, etc.) are `debated`. |
| REQ-C5 | S | **No factual errors**: dates, catalogue numbers, denominations, plating claims are internally consistent and match cited sources. | Cross-check sampled facts against references; consistency checks. |
| REQ-C6 | S | Each **denomination and handstamp** has a complete entity page (identity, colours, paper, catalogue refs, cancellations, figures). | Entity completeness checklist per [[ontology]]. |
| REQ-C7 | C | Coverage of the **forgery problem** is thorough (these stamps were heavily forged) — genuine vs. forgery criteria referenced. | Forgery sections exist per issue and cite expertising sources. |

## Language requirements (REQ-L)

| ID | Pri | Requirement | Audit hook |
|----|-----|-------------|-----------|
| REQ-L1 | M | English master is present and complete for every section. | No section lacks EN. |
| REQ-L2 | S | Each published-edition language is complete and **in lockstep** with EN (C-15); stale translations flagged. | `translation_status` clean for the edition's languages. |
| REQ-L3 | M | The **set of published languages is a decided policy**, not an accident. | A DR records the language decision (see [[strategy/multilanguage-analysis]]). |

## Book / pagination requirements (REQ-B)

| ID | Pri | Requirement | Audit hook |
|----|-----|-------------|-----------|
| REQ-B1 | M | The book is **generated from the wiki**, deterministically and re-runnably; no hand-edits to the output ([[decisions/DR-005-exporter-rebuilds-book]]). | Re-running the exporter reproduces byte-comparable structure. |
| REQ-B2 | M | Book **order** matches wiki `order`; nothing dropped or reordered. | Exported heading sequence == sorted `order`. |
| REQ-B3 | M | **A4** page size; the chosen layout (4-up quadrant or per-language) is applied consistently. | Page geometry + layout check. |
| REQ-B4 | S | **Figures/tables numbered and referenced** correctly in output (C-07..C-09); every reference resolves. | Reference-resolution pass over the output. |
| REQ-B5 | S | Original **styles preserved** (headings, captions, colours) via `styles.xml`. | Style diff vs. source template. |
| REQ-B6 | C | Output available as **.docx and PDF**. | Both artifacts build. |

## Technical / process requirements (REQ-T)

| ID | Pri | Requirement | Audit hook |
|----|-----|-------------|-----------|
| REQ-T1 | M | **Provenance** on every narrative page (`source_blocks`) traces to the source document. | Every narrative page has non-empty, valid `source_blocks`. |
| REQ-T2 | M | The wiki is the **single source of truth**; the pipeline is `concepts → narrative → pagination` ([[AGENTS]]). | No fact originates in narrative/pagination without a concept. |
| REQ-T3 | S | **Decisions are recorded** as DRs; discussions are not left in chat only. | Each accepted decision has a DR. |
| REQ-T4 | S | The build is **reproducible** on a clean checkout (documented commands). | Fresh run from `tools/` produces the book. |
| REQ-T5 | C | Media are **de-duplicated and referenced**; unused media flagged. | Media reference report. |

## Strategy requirements (REQ-S)

| ID | Pri | Requirement | Audit hook |
|----|-----|-------------|-----------|
| REQ-S1 | M | The book has a stated **audience, mission, and value proposition** ([[strategy/vision-mission-objectives]]). | Docs exist and are current. |
| REQ-S2 | S | Content is mapped to **audience pain points** ([[strategy/target-audience]]). | Each pain point has addressing content. |
| REQ-S3 | S | The **language strategy** is grounded in research ([[strategy/market-research]], [[strategy/multilanguage-analysis]]). | Backed by cited findings. |

> Requirements are living. Add new ones here (next free ID); never renumber.
