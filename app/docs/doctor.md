# Doctor

`app/doctor.sh` (macOS, Linux, Git Bash) and `app/doctor.ps1` (Windows) are thin wrappers over `app/doctor.py`, the single implementation (PROC-REPO-004).

| Flag | Effect |
|------|--------|
| *(none)* | Check everything. Exit 0 only when every gate passes |
| `--fix` | Attempt remediations, then check again |
| `--release` | Treat release signing as a gate |
| `--gates-only` | Skip advisory checks |

## Checks

| Check | Tier | `--fix` |
|-------|------|---------|
| Python ≥ 3.12 | gate | prompts to install via winget / brew |
| Python packages (`requirements.txt`) | gate | `pip install -r requirements.txt` |
| Flutter SDK | gate | prompts to install via winget / brew; prints the manual steps otherwise |
| JDK 17+ (PATH, `JAVA_HOME`, or the Android Studio JBR) | gate | prompts to install OpenJDK 17 |
| Android SDK | gate | prompts to install Android Studio |
| Android SDK licences | gate | prints `flutter doctor --android-licenses` (it is interactive) |
| Dart packages resolved | gate | `flutter pub get` |
| Release signing (`android/key.properties` + keystore) | gate with `--release`, advisory otherwise | writes the template from `key.properties.example`; never overwrites a real file |
| Android cmdline-tools | advisory | manual |
| ruff | advisory | manual |
| adb | advisory | manual |

Project-local fixes run without asking. System-wide installs run only after a yes at the prompt, and never in a non-interactive run.
