---
id: STRAT-OBJ-002
tier: strategic
title: English first, more languages as they complete
status: Done
category: OBJ
sources: [CH-STR-2, bull wiki DR-009 (published languages)]
applies_when: always
tags: [Objectives, Localisation]
---

# STRAT-OBJ-002 — English first, more languages as they complete

## Intent
The wiki holds RO/FR/DE translations at different completeness levels; shipping half-translated text would break CH-VAL-1.

## Requirement
English always ships. Romanian, French and German ship only when their translation coverage reaches the wizard threshold (`min_translation_coverage`, 98 %).

## Acceptance criteria
- [x] Coverage-based language gate in the wizard

## Verification
Wizard content step.
