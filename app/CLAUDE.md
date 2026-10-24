# CLAUDE.md — Bull app

A Flutter **interactive digital book** on the 1858 Moldavian *Cap de bour* stamps. It is generated from the research wiki one folder up (`../wiki/`). It is a paid app (no ads, no IAP, no data collection) for Android phones, tablets (portrait and landscape) and Android TV. The applicationId is `com.jinisolutions.capdebour`.

Governance: Program `bull` of the Hermes Tenant `jini-apps` (Jini Solutions). Requirements: [`docs/requirements/`](docs/requirements/Requirements.md), four tiers refining the Hermes baselines. Work list: [`TODO.md`](TODO.md). Docs index: [`docs/README.md`](docs/README.md).

## Key commands (run from `app/`)

```bash
./doctor.sh            # or .\doctor.ps1 — environment gates; add --fix to remediate
py -3 wizard/wizard.py # full development run: content bundle, analyze, tests, HTML report
py -3 wizard/wizard.py --content     # rebuild assets/content only
py -3 wizard/wizard.py --release     # zero to signed AAB + release verdict
flutter test                         # widget tests (lifecycle, layouts, TV, a11y, search)
py -3 -m pytest wizard/tests         # wizard tests
flutter run                          # needs assets/content built first
```

## Rules

- **The wiki is the source.** Never edit `assets/content/`; it is generated and gitignored. Fix content in `../wiki/`.
- **Rights gate.** Only images marked `cleared` in `../wiki/assets/rights.yml` ship. Do not mark anything cleared on the owner's behalf.
- **No network, no tracking.** Do not add dependencies that collect data or need INTERNET in release.
- **Layout by width class, never by device type** (`lib/src/ui/scope.dart`). Keep TV D-pad navigation working: `test/layout_test.dart` has a remote-only test.
- **Lifecycle baselines are tested** in `test/lifecycle_test.dart`. Keep them green.
- **UI strings** go in `lib/l10n/app_*.arb`, in all four languages.
- Requirement files change together with the code they describe. A requirement with an unticked criterion is never `Done`.

See [`AGENTS.md`](AGENTS.md) for step-by-step recipes.
