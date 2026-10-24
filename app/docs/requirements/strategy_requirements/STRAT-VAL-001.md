---
id: STRAT-VAL-001
tier: strategic
title: Quality gates are binding
status: Done
category: VAL
sources: [CH-VAL-1]
applies_when: always
tags: [Values, Quality]
---

# STRAT-VAL-001 — Quality gates are binding

## Intent
Quality is non-negotiable for the whole catalogue.

## Requirement
No build ships past a failed wizard gate; the release verdict is the only path to a signed bundle.

## Acceptance criteria
- [x] Wizard release mode exits 2 and produces no artefact when a gate fails

## Verification
`wizard.py --release` behaviour.
