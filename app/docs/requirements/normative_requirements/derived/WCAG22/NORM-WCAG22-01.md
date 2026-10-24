---
id: NORM-WCAG22-01
tier: normative
title: WCAG 2.2 AA for the reading experience
status: Partial
category: WCAG22
sources: [WCAG 2.2, https://www.w3.org/TR/WCAG22/, retrieved 2026-10-25]
applies_when: always
tags: [Accessibility]
---

# NORM-WCAG22-01 — WCAG 2.2 AA for the reading experience

## Intent
A book app is used for long reading sessions by an audience that skews older.

## Requirement
Text contrast, target sizes, labels and text resizing shall meet WCAG 2.2 AA.

## Acceptance criteria
- [x] Tap target, label and contrast guidelines pass on the contents screen
- [ ] Same guidelines pass on the reader and settings screens
- [x] 200 % text tested on the reader

## Verification
`test/layout_test.dart`.
