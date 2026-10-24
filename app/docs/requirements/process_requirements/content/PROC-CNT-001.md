---
id: PROC-CNT-001
tier: process
title: Content build from the wiki
status: Done
category: CNT
sources: [STRAT-OBJ-003]
applies_when: always
tags: [Content]
---

# PROC-CNT-001 — Content build from the wiki

## Intent
The pipeline reads, never writes, the wiki (except the rights registry skeleton).

## Requirement
Content is compiled by `bullwiz/content.py` and `bundle.py`; validation errors (duplicate order, missing titles, missing image files) block the run.

## Acceptance criteria
- [x] Validation step in the wizard
- [x] Wizard tests

## Verification
`wizard/tests/`.
