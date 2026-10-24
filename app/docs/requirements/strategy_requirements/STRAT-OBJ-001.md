---
id: STRAT-OBJ-001
tier: strategic
title: Phones, tablets and TVs, portrait and landscape
status: Partial
category: OBJ
sources: [CH-STR-2, jini-apps-DR-002]
applies_when: always
tags: [Objectives, Platforms]
---

# STRAT-OBJ-001 — Phones, tablets and TVs, portrait and landscape

## Intent
Version 1 covers the Android form factors; iPhone and iPad follow.

## Requirement
v1 supports Android phones and tablets in portrait and landscape, and Android TV / Google TV. iOS is a v1.x milestone.

## Acceptance criteria
- [x] Layouts for all declared sizes pass widget tests
- [ ] Manual pass on phone, tablet and TV emulators
- [ ] iOS platform added (v1.x)

## Verification
`test/layout_test.dart`; manual checklist.
