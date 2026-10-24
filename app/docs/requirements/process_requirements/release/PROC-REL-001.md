---
id: PROC-REL-001
tier: process
title: Release
status: Pending
category: REL
sources: [STRAT-VAL-001]
baseline_sources: [H-PROC-REL-001, H-PROC-REL-002, H-APP-QAL-003]
applies_when: always
tags: [Release]
---

# PROC-REL-001 — Release

## Intent
From a passing verdict to the store.

## Requirement
Release builds come only from `wizard.py --release`; the AAB goes to internal testing first (phone, tablet, TV smoke test), then production by explicit owner action; `released_to_store` is set in `docs/release_log.jsonl`. Tagging is manual until the first release.

## Acceptance criteria
- [x] Wizard release mode
- [ ] Internal track smoke test recorded
- [ ] Git tag automation

## Verification
Release log.
