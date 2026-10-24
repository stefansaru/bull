---
id: APP-LIFE-001
tier: application
title: Lifecycle conformance
status: Done
category: LIFE
sources: [STRAT-VAL-001]
baseline_sources: [H-APP-LIFE-001, H-APP-LIFE-002, H-APP-LIFE-003, H-APP-LIFE-004, H-APP-LIFE-005]
applies_when: always
tags: [Lifecycle]
---

# APP-LIFE-001 — Lifecycle conformance

## Intent
The Hermes lifecycle baselines, made concrete for a reader.

## Requirement
Persistent state: book language and last section. Restorable state: selected tab, open section. Cold start, close and reopen, background and resume, process death and rotation shall keep these.

## Acceptance criteria
- [x] H-APP-LIFE-001 cold start test
- [x] H-APP-LIFE-002 close/reopen test
- [x] H-APP-LIFE-003 background/resume test
- [x] H-APP-LIFE-004 restore test
- [x] H-APP-LIFE-005 rotation and language change tests

## Verification
`test/lifecycle_test.dart`.
