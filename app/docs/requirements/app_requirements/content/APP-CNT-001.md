---
id: APP-CNT-001
tier: application
title: Book structure from the wiki
status: Done
category: CNT
sources: [STRAT-OBJ-003]
applies_when: always
tags: [Content]
---

# APP-CNT-001 — Book structure from the wiki

## Intent
Readers expect chapters and sections in the book's order.

## Requirement
The app shall present all narrative sections grouped by chapter in `order`, with headings at their level.

## Acceptance criteria
- [x] Chapters and sections in book order
- [x] Section headings respect levels

## Verification
`test/book_test.dart`; wizard tests.
