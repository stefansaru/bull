---
id: PROC-TST-001
tier: process
title: Tests in the gate
status: Done
category: TST
sources: [STRAT-VAL-001]
baseline_sources: [H-PROC-TST-001]
applies_when: always
tags: [Testing]
---

# PROC-TST-001 — Tests in the gate

## Intent
Every baseline that can be automated is automated.

## Requirement
`flutter test` (model, search, layouts, TV, accessibility, lifecycle) and `pytest wizard/tests` run in every wizard run.

## Acceptance criteria
- [x] Lifecycle baselines automated
- [x] Wizard tests

## Verification
Wizard report.
