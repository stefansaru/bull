---
id: PROC-REPO-005
tier: process
title: Zero-to-release wizard
status: Done
category: REPO
sources: [CH-VIS, CH-GOAL-5]
baseline_sources: [H-PROC-REPO-005]
applies_when: always
tags: [Repository, Automation]
---

# PROC-REPO-005 — Zero-to-release wizard

## Intent
The app's automated pipeline.

## Requirement
`py -3 app/wizard/wizard.py --release` runs doctor → content → validate → rights → bundle → pub get → analyze → tests → bump → signed AAB → signature check → release log, with an HTML verdict.

## Acceptance criteria
- [x] Single command
- [x] Blocked gate → exit 2, no artefact
- [x] HTML report

## Verification
`wizard.py --release` run.
