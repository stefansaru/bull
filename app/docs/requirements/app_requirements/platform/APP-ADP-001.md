---
id: APP-ADP-001
tier: application
title: Adaptive layouts
status: Done
category: ADP
sources: [STRAT-OBJ-001]
baseline_sources: [H-APP-ADP-001, H-APP-LIFE-005]
applies_when: always
tags: [Adaptive]
---

# APP-ADP-001 — Adaptive layouts

## Intent
One codebase, intentional layouts on every declared screen.

## Requirement
Width classes: compact < 600 dp (bottom navigation, reader as a page), medium 600–839 dp (navigation rail, reader as a page), expanded ≥ 840 dp (rail + two panes). Both orientations on phones and tablets; no orientation lock.

## Acceptance criteria
- [x] Breakpoints implemented by width, not device type
- [x] Every declared size covered by a widget test

## Verification
`test/layout_test.dart`.
