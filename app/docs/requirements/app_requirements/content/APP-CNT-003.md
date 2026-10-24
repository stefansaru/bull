---
id: APP-CNT-003
tier: application
title: Only cleared images ship
status: Done
category: CNT
sources: [NORM-COPY-01]
applies_when: always
tags: [Content, Copyright]
---

# APP-CNT-003 — Only cleared images ship

## Intent
Rights enforcement belongs in the pipeline, not in memory.

## Requirement
The bundle shall contain only images whose rights entry is `cleared`; figures whose image is not cleared are left out with their caption.

## Acceptance criteria
- [x] Wizard bundles only cleared images
- [x] Uncleared images removed from an existing bundle

## Verification
`wizard/tests/test_wizard.py`.
