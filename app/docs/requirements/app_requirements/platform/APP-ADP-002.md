---
id: APP-ADP-002
tier: application
title: Android TV
status: Partial
category: ADP
sources: [STRAT-OBJ-001, NORM-GPTV-01]
baseline_sources: [H-APP-ADP-002]
applies_when: always
tags: [TV]
---

# APP-ADP-002 — Android TV

## Intent
The book on the living-room screen.

## Requirement
D-pad navigation through rail, contents and reader; select activates; the reader scrolls with up/down from its buttons; visible focus everywhere; leanback entry and banner.

## Acceptance criteria
- [x] D-pad-only test passes
- [x] Leanback manifest entries
- [ ] 10-foot type scale
- [ ] Manual pass on a TV emulator

## Verification
`test/layout_test.dart`; manual.
