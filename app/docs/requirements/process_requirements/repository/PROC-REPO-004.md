---
id: PROC-REPO-004
tier: process
title: doctor with --fix
status: Done
category: REPO
sources: [CH-STR-4]
baseline_sources: [H-PROC-REPO-004]
applies_when: always
tags: [Repository, Tooling]
---

# PROC-REPO-004 — doctor with --fix

## Intent
A machine one command away from a working build.

## Requirement
`doctor.sh` / `doctor.ps1` wrap `doctor.py`: gates and advisory checks, `--fix` for local remediation, prompted system installs, `--release` for signing.

## Acceptance criteria
- [x] Wrappers and implementation
- [x] --fix: pip, pub get, key.properties template
- [x] Prompted winget/brew installs

## Verification
Run on a clean machine.
