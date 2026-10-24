---
id: PROC-RGT-001
tier: process
title: Clearing an image
status: Pending
category: RGT
sources: [NORM-COPY-01, STRAT-RSK-001]
applies_when: always
tags: [Copyright, Process]
---

# PROC-RGT-001 — Clearing an image

## Intent
How an image moves from pending to cleared or omit.

## Requirement
For each image the owner records `provenance` (own scan, book and page, auction lot), `licence` (own work, public domain with reason, permission reference) and sets `status`. Permission documents are kept outside the repo; `note` cites them. `--rights-init` adds new images as pending and never changes existing entries.

## Acceptance criteria
- [x] Procedure documented (docs/content-pipeline.md)
- [ ] All referenced images decided

## Verification
Rights gate counts.
