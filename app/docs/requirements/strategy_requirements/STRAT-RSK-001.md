---
id: STRAT-RSK-001
tier: strategic
title: Image rights may shrink the illustrated edition
status: Pending
category: RSK
sources: [CH-VAL-4, NORM-COPY-01]
applies_when: always
tags: [Risk]
---

# STRAT-RSK-001 — Image rights may shrink the illustrated edition

## Intent
Most images are not yet cleared; the first edition may ship with few images or wait for permissions.

## Requirement
The owner decides, per image source, whether to seek permission, replace with own photographs, or omit. Progress is tracked in `wiki/assets/rights.yml` and the release waits for the decision on every referenced image.

## Acceptance criteria
- [ ] Per-source decision recorded
- [ ] Shipping image count acceptable to the owner

## Verification
Rights gate counts in the wizard report.
