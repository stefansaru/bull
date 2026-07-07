---
id: meta/decisions/DR-010-translation-storage
type: decision
title: {en: "Translations stored in per-page sidecars, hash-linked to English"}
status: accepted
---

# DR-010 — Translation storage: per-page sidecars, hash-linked to English

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-07-04 |
| Mode | CONCEPT / NARRATE |
| Actor(s) | user (chose "Sidecar per page") |
| Related | DR-003 (English master), DR-009 (English first), style, frontmatter-schema |

## Context
English is the master and is edited first; the book ships in English first, other
languages later (DR-009). We already **hold** FR/DE/RO (ingested from the source
book). We need a store where English authoring stays clean and each translation can
be **automatically flagged stale** when its English source changes.

## Decision
Each narrative page is **English-only** (`.md`), with every content unit marked
`<!-- u:UID kind:… -->`. Translations live in a **mirrored sidecar** next to the page:
`…/<page>.i18n.yml`. Per unit UID the sidecar stores each language's `text`, a
`status`, and the **`en_hash`** — a whitespace-normalised hash of the English it was
translated from. A translation is **stale** when the page's current English hashes to
something different from the stored `en_hash` (checked by `tools/i18n_status.py`).
Non-English loose fragments are preserved in the sidecar as `orphan` units so nothing
is lost and the English page stays clean.

- UID = `u` + min source-block index (zero-padded) → sorts in document order.
- Exporter merges page (English + shared figures/tables) with the sidecar for the
  requested `--edition`.

## Alternatives considered
- **Inline, all four in one file** (the ingest default). Rejected: English authoring
  is noisier and staleness is per-page not per-unit.
- **Central translation memory keyed by English hash.** Deferred: most scalable and a
  natural *addition* later, but least browsable in Obsidian; sidecars are the primary
  store, a TM can be layered on top.

## Consequences
- Clean English pages; robust per-unit staleness; easy per-language export.
- A page + its sidecar must move/rename together (mirrored basename).
- `tools/i18n_status.py` reports coverage and staleness (feeds audit Stage D, REQ-L2).
