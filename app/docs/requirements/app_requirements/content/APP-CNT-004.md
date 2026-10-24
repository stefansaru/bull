---
id: APP-CNT-004
tier: application
title: Fully offline
status: Done
category: CNT
sources: [NORM-GDPR-01, STRAT-VAL-003]
baseline_sources: [H-APP-LIFE-006]
applies_when: always
tags: [Content, Resilience]
---

# APP-CNT-004 — Fully offline

## Intent
A book should open on a plane.

## Requirement
All content is bundled; no feature needs the network.

## Acceptance criteria
- [x] No network calls in the app

## Verification
Code review; no INTERNET permission.
