# Requirements — Bull app

The four-tier requirement tree of the Bull app. It follows the Hermes tier contract (Hermes DR-026, `system/meta/requirement-tiers/README.md`) and refines the Hermes baselines (`H-APP-*`, `H-PROC-*`). Strategic requirements cite the Jini Solutions charter (`CH-*`, Hermes Tenant `jini-apps`).

| Tier | Index | Prefix | Answers |
|------|-------|--------|---------|
| Normative | [NormativeReferences.md](normative_requirements/NormativeReferences.md) | `NORM-STD-nn` | What law, standards and the store oblige |
| Strategic | [StrategyRequirements.md](strategy_requirements/StrategyRequirements.md) | `STRAT-CAT-nnn` | What the charter and this app's choices commit to |
| Application | [AppRequirements.md](app_requirements/AppRequirements.md) | `APP-CAT-nnn` | What the app does |
| Process | [ProcessRequirements.md](process_requirements/ProcessRequirements.md) | `PROC-CAT-nnn` | How it is built, tested and released |

## Rules

- IDs are unique across all four tiers, uppercase and hyphenated. Numbers are zero-padded: 2 digits for NORM, 3 for the rest.
- One file per ID, named after it, linked from its tier index.
- YAML frontmatter: `id, tier, title, status, category, sources, baseline_sources, applies_when, tags`.
- Status is one of four words: `Done` · `Partial` · `Pending` · `Retired`. A requirement with an unticked acceptance criterion is never `Done`.
- A Hermes baseline that applies here is either refined (`baseline_sources`), adopted as written (the *Adopted baselines* tables), or deviated from by a recorded owner ruling.

These requirements are separate from the **book's** requirements (`REQ-*` in `wiki/meta/requirements.md`). The book and the app share the wiki as their content source. Nothing else is shared between them.

## Category codes

| Tier | Codes |
|------|-------|
| NORM | COPY (copyright), GPDP (Google Play policies), GPTV (Google Play TV), GDPR, WCAG22 |
| STRAT | MIS, VAL, MKT, OBJ, RSK |
| APP | CNT (content), RDR (reader), SRCH (search), L10N, ADP (adaptive / TV), LIFE, ACC, PRV, UX |
| PROC | REPO (repository standard), CNT (content pipeline), RGT (rights), TST, REL |
