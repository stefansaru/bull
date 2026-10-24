# Application requirements

Tier contract: Hermes `system/meta/requirement-tiers/README.md` (DR-026). Index: [Requirements.md](../Requirements.md).

| ID | Title | Status | Refines baseline |
|----|-------|--------|------------------|
| [APP-CNT-001](../app_requirements/content/APP-CNT-001.md) | Book structure from the wiki | Done | — |
| [APP-CNT-002](../app_requirements/content/APP-CNT-002.md) | Reference pages | Partial | — |
| [APP-CNT-003](../app_requirements/content/APP-CNT-003.md) | Only cleared images ship | Done | — |
| [APP-CNT-004](../app_requirements/content/APP-CNT-004.md) | Fully offline | Done | H-APP-LIFE-006 |
| [APP-RDR-001](../app_requirements/reader/APP-RDR-001.md) | Reading view | Done | H-APP-UX-002 |
| [APP-RDR-002](../app_requirements/reader/APP-RDR-002.md) | Zoomable images | Partial | H-APP-ADP-002 |
| [APP-SRCH-001](../app_requirements/search/APP-SRCH-001.md) | Full-text search | Done | — |
| [APP-L10N-001](../app_requirements/localisation/APP-L10N-001.md) | Interface in four languages | Done | H-APP-L10N-001 |
| [APP-L10N-002](../app_requirements/localisation/APP-L10N-002.md) | Book language switch with English fallback | Done | — |
| [APP-ADP-001](../app_requirements/platform/APP-ADP-001.md) | Adaptive layouts | Done | H-APP-ADP-001, H-APP-LIFE-005 |
| [APP-ADP-002](../app_requirements/platform/APP-ADP-002.md) | Android TV | Partial | H-APP-ADP-002 |
| [APP-LIFE-001](../app_requirements/lifecycle/APP-LIFE-001.md) | Lifecycle conformance | Done | H-APP-LIFE-001, H-APP-LIFE-002, H-APP-LIFE-003, H-APP-LIFE-004, H-APP-LIFE-005 |
| [APP-ACC-001](../app_requirements/accessibility/APP-ACC-001.md) | Accessibility for long reading | Partial | H-APP-ACC-001, H-APP-ACC-002 |
| [APP-PRV-001](../app_requirements/privacy/APP-PRV-001.md) | Privacy notice in the app | Partial | H-APP-PRV-001, H-APP-PRV-002 |
| [APP-UX-001](../app_requirements/ux/APP-UX-001.md) | Reading in two interactions | Done | H-APP-UX-001 |
| [APP-UX-002](../app_requirements/ux/APP-UX-002.md) | Paper-and-ink design | Partial | H-APP-UX-002 |

## Adopted baselines

Met as written in the Hermes baseline; no refinement needed.

| Baseline | How it is met |
|----------|---------------|
| H-APP-QAL-001 | Release gate blocks on any failing test; crash-free target set at first release (TODO.md) |
| H-APP-QAL-002 | Budget 2 s on a mid-range reference device; measured at first release (TODO.md) |
| H-APP-QAL-003 | No debug flags exist; release builds come only from the wizard |
| H-APP-SEC-001 | key.properties and keystores gitignored; keystore outside the repo |
