---
id: meta/audit-procedure
type: meta
title:
  en: Audit procedure — validating a generated book
status: living
---

# Audit procedure

A repeatable procedure to validate a generated book against [[meta/requirements]]
and [[meta/conventions]]. Run it before any release. Produces a dated audit report
under `strategy/audits/` (or `meta/audits/`) with a pass/fail per check and a list
of defects. Model: like a compliance audit — evidence compared against requirements.

## When to run

- Before exporting a "release" build of the book.
- After any bulk ingest or bulk edit.
- On demand when the user asks "is the book valid?".

## Inputs

- The generated book artifact(s) (`.docx`/PDF).
- The wiki at the audited commit.
- `document_model.json` (source provenance) for coverage/faithfulness checks.

## Procedure

### Stage A — Structural & provenance (automated)

1. **Coverage (REQ-C1).** Union of all `source_blocks` across narrative pages ==
   the set of source blocks, minus a declared exclusion list. Report orphans.
2. **Provenance (REQ-T1).** Every narrative page has non-empty, resolvable
   `source_blocks`.
3. **Order (REQ-B2).** Exported heading sequence equals wiki pages sorted by
   `order`. No gaps/dupes in `order`.
4. **Reference resolution (REQ-B4, C-07..C-09).** Every `Figure N`, `Table N`, `§ref`
   in the output resolves to an existing target. List danglers.
5. **Media (REQ-T5).** Every referenced image exists in `assets/media/`; list
   unused media.

### Stage B — Notation conformance (automated + spot-check)

6. Run the **conventions linter** over the output for C-01..C-12: backtick grouping,
   catalogue-citation shape, units on dimensions, calendar markers, emoji markers all
   defined in [[glossary]], quote style. Report each violation with location.

### Stage C — Content integrity (sampled, human/agent)

7. **Faithfulness (REQ-C2).** Sample N=20 `verbatim` sections; diff against source
   blocks; expect no unexplained edits.
8. **References (REQ-C3).** Sample N=30 factual claims; each must resolve to a
   [[entities/references|reference]]. Count `needs-ref`; target zero.
9. **Debates (REQ-C4).** Confirm each known controversy (aurochs vs. wisent; disputed
   plating/printing counts; disputed dates) is `status: debated` with positions.
10. **Facts (REQ-C5).** Cross-check sampled dates, catalogue numbers, denominations,
    and dimensions against the cited references; flag mismatches.

### Stage D — Language (per published edition)

11. **Completeness & staleness (REQ-L1/L2).** Run `tools/i18n_status.py wiki` — every
    translatable unit in the edition's language must be `ok` (present and `en_hash`
    matches). Report `stale` (English changed since translating) and `missing` counts;
    the English edition requires none, other editions require zero `stale` before ship.
12. **Lockstep (C-15).** Spot-check that translations match the English master in
    meaning for N=15 sections. Orphan fragments (non-English loose units) are triaged:
    give them an English master or drop them.

### Stage E — Build & layout

13. **Determinism (REQ-B1/T4).** Re-run the exporter on a clean checkout; structure
    is reproduced.
14. **Layout (REQ-B3/B5).** A4 geometry; chosen layout applied; styles match template.

## Output: audit report format

```
# Audit YYYY-MM-DD (commit <hash>)
Edition: <languages> | Build: <artifact>
Result: PASS | PASS WITH DEFECTS | FAIL

## Requirement results
REQ-C1 Coverage ....... PASS  (0 orphan blocks)
REQ-C3 References ...... DEFECT (7 needs-ref) -> see defects
...

## Convention results (C-01..C-16)
C-02 Catalogue cites ... DEFECT (3 malformed) -> [locations]
...

## Defects (ranked)
1. [REQ-C3] §7.2 "rarest 81 parale" unreferenced -> add ref or soften.
...

## Sign-off
Auditor: <name>  Date: ...  Next audit: ...
```

## Severity & gating

- **Blocker**: any Must (M) requirement failing, or coverage/provenance broken.
- **Major**: notation violations at scale; unreferenced claims above threshold.
- **Minor**: cosmetic, isolated.
- A release requires **zero blockers**; majors are listed with an accepted-risk note
  or fixed.

> The automated stages (A, B, E) should become a `tools/audit.py` script; C and D
> stay partly human/agent-judged. See [[meta/requirements]] for the ID map.
