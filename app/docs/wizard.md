# Wizard

The app's zero-to-release pipeline (PROC-REPO-005). The code is in `app/wizard/`: `wizard.py` is the entry point, and the logic is in the `bullwiz/` package. Run it from the repository root or from `app/`.

| Command | What it does |
|---------|--------------|
| `py -3 app/wizard/wizard.py` | Development run: doctor gates → read wiki → validate → rights (warn) → bundle → `flutter pub get` → `flutter analyze` → `flutter test` → `pytest wizard/tests` → HTML report |
| `py -3 app/wizard/wizard.py --release` | Every gate strict (rights, bundle size, signing) → build-number bump → `flutter build appbundle --release` → `jarsigner -verify` → `docs/release_log.jsonl` entry → report |
| `py -3 app/wizard/wizard.py --content` | Only rebuild `assets/content/` (fast, for content work) |
| `py -3 app/wizard/wizard.py --rights-init` | Add a `pending` entry to `wiki/assets/rights.yml` for every referenced image not yet registered |
| `--skip-flutter` | Skip the flutter steps (content-only machines) |

## Report and exit codes

The report is written to `app/build/reports/wizard-report.html`. It has one row per step (pass / warn / fail / skip, gate or advisory, details) and a single **release verdict**.

| Exit | Meaning |
|------|---------|
| 0 | All gates passed. In release mode, a signed AAB was built and verified |
| 1 | A gate failed in a development run |
| 2 | Release mode: a gate blocked the build. No artefact, no version bump |
| 3 | Release mode: the build or the signature check failed |

The artefact is `app/build/app/outputs/bundle/release/app-release.aab`. Upload is manual (see [release-workflow.md](release-workflow.md)).

## Configuration

`app/wizard/config.yaml` holds the master and candidate languages, the translation threshold, the image size and quality, and the bundle size limit.

## Tests

`py -3 -m pytest app/wizard/tests` covers parsing (text, figures, tables with escaped pipes, images inside tables), translation selection (only `ok`), the rights gate, and bundle pruning.
