---
id: NORM-COPY-01
tier: normative
title: Reproduced images and texts must be cleared
status: Pending
category: COPY
sources: [Legea 8/1996 (drepturi de autor), https://legislatie.just.ro/Public/DetaliiDocument/7816, retrieved 2026-10-25, Directive 2001/29/EC art. 2]
applies_when: always
tags: [Copyright, Content, Release]
---

# NORM-COPY-01 — Reproduced images and texts must be cleared

## Intent
Selling the app makes every reproduced photograph, scan and text a commercial use. Many wiki images come from copyrighted reference works and auction catalogues.

## Requirement
No image or third-party text shall ship in a sold build unless its provenance is recorded and its reproduction is covered by ownership, the public domain, a licence or a written permission.

## Acceptance criteria
- [x] Every referenced image has an entry in `wiki/assets/rights.yml`
- [x] Only `cleared` entries with provenance and licence ship (wizard rights gate)
- [ ] Every image the release needs is cleared or deliberately omitted
- [ ] Permissions are archived outside the repository and cited in `note`

## Verification
Wizard rights gate (`bullwiz/rights.py`, `wizard/tests/test_wizard.py`).
