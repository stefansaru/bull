# Process requirements

Tier contract: Hermes `system/meta/requirement-tiers/README.md` (DR-026). Index: [Requirements.md](../Requirements.md).

| ID | Title | Status | Refines baseline |
|----|-------|--------|------------------|
| [PROC-REPO-001](../process_requirements/repository/PROC-REPO-001.md) | TODO.md | Done | H-PROC-REPO-001, H-PROC-REPO-006 |
| [PROC-REPO-002](../process_requirements/repository/PROC-REPO-002.md) | docs/ LLM-wiki | Done | H-PROC-REPO-002 |
| [PROC-REPO-003](../process_requirements/repository/PROC-REPO-003.md) | Four-tier requirement tree | Done | H-PROC-REPO-003 |
| [PROC-REPO-004](../process_requirements/repository/PROC-REPO-004.md) | doctor with --fix | Done | H-PROC-REPO-004 |
| [PROC-REPO-005](../process_requirements/repository/PROC-REPO-005.md) | Zero-to-release wizard | Done | H-PROC-REPO-005 |
| [PROC-CNT-001](../process_requirements/content/PROC-CNT-001.md) | Content build from the wiki | Done | — |
| [PROC-RGT-001](../process_requirements/content/PROC-RGT-001.md) | Clearing an image | Pending | — |
| [PROC-TST-001](../process_requirements/testing/PROC-TST-001.md) | Tests in the gate | Done | H-PROC-TST-001 |
| [PROC-REL-001](../process_requirements/release/PROC-REL-001.md) | Release | Pending | H-PROC-REL-001, H-PROC-REL-002, H-APP-QAL-003 |

## Adopted baselines

Met as written in the Hermes baseline; no refinement needed.

| Baseline | How it is met |
|----------|---------------|
| H-PROC-CMT-001 | Run `doctor.sh` and `flutter test` before committing (checklist in AGENTS.md) |
