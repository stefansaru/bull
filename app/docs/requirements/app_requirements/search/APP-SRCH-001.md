---
id: APP-SRCH-001
tier: application
title: Full-text search
status: Done
category: SRCH
sources: [STRAT-VAL-002]
applies_when: always
tags: [Search]
---

# APP-SRCH-001 — Full-text search

## Intent
Readers look for a town, a postmark, a value.

## Requirement
Search shall match titles, text, captions and table cells in the reader's language and open the section on tap.

## Acceptance criteria
- [x] Search across section text
- [x] Opens the result

## Verification
`test/book_test.dart`.
