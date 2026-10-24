---
id: APP-ACC-001
tier: application
title: Accessibility for long reading
status: Partial
category: ACC
sources: [NORM-WCAG22-01]
baseline_sources: [H-APP-ACC-001, H-APP-ACC-002]
applies_when: always
tags: [Accessibility]
---

# APP-ACC-001 — Accessibility for long reading

## Intent
Readers use large text and screen readers.

## Requirement
Guidelines (tap targets, labels, contrast) pass; text scale up to 200 % keeps every screen usable; headings are marked for screen readers.

## Acceptance criteria
- [x] Guideline tests on contents
- [x] 200 % text on reader
- [ ] TalkBack pass

## Verification
`test/layout_test.dart`; manual TalkBack.
