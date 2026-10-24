---
id: STRAT-OBJ-003
tier: strategic
title: The wiki is the single source of content
status: Done
category: OBJ
sources: [CH-STR-4, bull wiki DR-005 (no hand edits)]
applies_when: always
tags: [Objectives, Content]
---

# STRAT-OBJ-003 — The wiki is the single source of content

## Intent
The book and the app must not diverge.

## Requirement
All app content is generated from `wiki/` by the wizard; nothing in `assets/content/` is edited by hand or committed.

## Acceptance criteria
- [x] Bundle is generated and gitignored

## Verification
`.gitignore`; PROC-CNT-001.
