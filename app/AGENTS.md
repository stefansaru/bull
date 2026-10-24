# AGENTS.md — recipes for the Bull app

Read [`CLAUDE.md`](CLAUDE.md) first.

## Before every commit (H-PROC-CMT-001, adopted)

1. `./doctor.sh --gates-only`
2. `flutter analyze` and `flutter test`
3. `py -3 -m pytest wizard/tests` (when `wizard/` changed)
4. Update the requirement files you touched: tick criteria, adjust the status.

## Add a UI string

1. Add the key to `lib/l10n/app_en.arb`, then the same key to `app_ro.arb`, `app_fr.arb` and `app_de.arb`.
2. `flutter pub get` regenerates `lib/l10n/app_localizations*.dart`.
3. Use `AppLocalizations.of(context).<key>`.

## Change what the bundle contains

1. Edit `wizard/bullwiz/content.py` (parsing) or `bundle.py` (JSON shape). If the JSON shape changes, bump `SCHEMA` and update `lib/src/content/book.dart` and `docs/content-pipeline.md`.
2. Add a case to `wizard/tests/test_wizard.py`.
3. `py -3 wizard/wizard.py --content`, then `flutter test`.

## Add a screen

1. Put it under `lib/src/ui/`. Read the book and settings through `AppScope.of(context)`.
2. Check it at every width class: add a case to `test/layout_test.dart`.
3. Make it reachable by D-pad: only focusable widgets (buttons, list tiles) take focus, and `select` activates.
4. If it holds state the reader would miss after a process kill, make it restorable (`RestorationMixin`).

## Clear images (owner only)

Edit `../wiki/assets/rights.yml`. The procedure is in `docs/content-pipeline.md`. An agent may prepare a list of images per source to help the owner decide, but never sets `status: cleared`.

## Release

Follow `docs/release-workflow.md`. Never upload an AAB that did not come from `wizard.py --release` with a PASS verdict.
