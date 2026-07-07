---
id: meta/decisions/README
type: meta
title:
  en: Decision records
status: living
---

# Decision records (DR)

Every non-trivial decision — about the wiki, the book, strategy, or the pipeline —
is recorded here as a numbered DR, append-only, never renumbered
([[../../AGENTS|AGENTS]] rule 6). Discussions with the user end as a DR, not as lost
chat. Format follows the hermes model: a status table, then Context / Decision /
Alternatives / Consequences.

| DR | Title | Status |
|----|-------|--------|
| [[DR-001-wiki-not-just-book]] | Wiki is the source of truth, book is a rendering | accepted |
| [[DR-002-one-entity-one-file]] | One entity, one file | accepted |
| [[DR-003-english-master]] | English is the master language | accepted |
| [[DR-004-verbatim-first]] | Verbatim-first ingestion | accepted |
| [[DR-005-exporter-rebuilds-book]] | The book is generated, never hand-edited | accepted |
| [[DR-006-mark-debated-concepts]] | Mark debated concepts, don't resolve silently | accepted |
| [[DR-007-references-for-claims]] | Every claim carries a reference | accepted |
| [[DR-008-three-stage-pipeline]] | concepts → narrative → pagination | accepted |
| DR-009-published-languages | How many languages the *published* book uses | **open** (pending [[../../strategy/multilanguage-analysis]]) |

## Template

```
# DR-NNN — Title
| Field | Value |
|-------|-------|
| Status | proposed / accepted / superseded |
| Date | YYYY-MM-DD |
| Mode | INGEST / CONCEPT / … |
| Actor(s) | user + agent |
| Related | DR-xxx |

## Context
## Decision
## Alternatives considered
## Consequences
```
