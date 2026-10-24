"""doctor — checks that every tool and package the Bull app needs is installed (PROC-REPO-004).

    ./doctor.sh | .\\doctor.ps1                    # check; exit 0 only when every gate passes
    ./doctor.sh --fix                             # also attempt remediations
    ./doctor.sh --release                         # also require release signing (key.properties)
    ./doctor.sh --gates-only                      # skip advisory checks

Two tiers, as in Amethyst:
  GATES     must pass for the wizard to run; a failure makes the exit code 1.
  ADVISORY  informational; never changes the exit code.

`--fix` performs project-local remediations without asking (dependency fetches,
config templates). Anything system-wide (installing a JDK, Flutter, the Android
SDK) is attempted only after a yes at the prompt, and otherwise the manual
command is printed. Non-interactive runs never install system-wide software.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

APP = Path(__file__).resolve().parent
WINDOWS = os.name == "nt"
MIN_PYTHON = (3, 12)


@dataclass
class Result:
    name: str
    ok: bool
    detail: str = ""
    gate: bool = True
    fix: Callable[[], bool] | None = None      # project-local remediation, run without asking
    system_fix: list[str] | None = None         # system-wide install command, run only after a yes
    manual: str = ""                            # what to do by hand when nothing can be automated


def _run(cmd: list[str], cwd: Path = APP, timeout: int = 900) -> tuple[int, str]:
    exe = shutil.which(cmd[0]) or cmd[0]
    try:
        p = subprocess.run([exe, *cmd[1:]], cwd=cwd, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as e:
        return 127, str(e)
    return p.returncode, (p.stdout + p.stderr).strip()


def _android_sdk() -> Path | None:
    for var in ("ANDROID_HOME", "ANDROID_SDK_ROOT"):
        if os.environ.get(var) and Path(os.environ[var]).is_dir():
            return Path(os.environ[var])
    guesses = [Path(os.environ.get("LOCALAPPDATA", "")) / "Android" / "Sdk",
               Path.home() / "Android" / "Sdk", Path.home() / "Library" / "Android" / "sdk"]
    return next((g for g in guesses if g.is_dir()), None)


def _java() -> str | None:
    if shutil.which("java"):
        return shutil.which("java")
    homes = [os.environ.get("JAVA_HOME", "")]
    if WINDOWS:
        homes.append(r"C:\Program Files\Android\Android Studio\jbr")
    else:
        homes += ["/Applications/Android Studio.app/Contents/jbr/Contents/Home", "/opt/android-studio/jbr"]
    for h in filter(None, homes):
        exe = Path(h) / "bin" / ("java.exe" if WINDOWS else "java")
        if exe.exists():
            return str(exe)
    return None


def _adb() -> str:
    sdk = _android_sdk()
    exe = sdk / "platform-tools" / ("adb.exe" if WINDOWS else "adb") if sdk else None
    return str(exe) if exe and exe.exists() else "adb"


def _winget_or_brew(win_id: str, brew: str) -> list[str] | None:
    if WINDOWS and shutil.which("winget"):
        return ["winget", "install", "-e", "--id", win_id]
    if not WINDOWS and shutil.which("brew"):
        return ["brew", "install", *brew.split()]
    return None


# -- checks --------------------------------------------------------------------

def check_python() -> Result:
    ok = sys.version_info >= MIN_PYTHON
    return Result("Python ≥ 3.12", ok, sys.version.split()[0],
                  system_fix=None if ok else _winget_or_brew("Python.Python.3.13", "python@3.13"),
                  manual="install Python 3.13 from python.org")


def check_python_packages() -> Result:
    missing = []
    for mod, pkg in (("yaml", "PyYAML"), ("PIL", "Pillow"), ("pytest", "pytest")):
        try:
            __import__(mod)
        except ImportError:
            missing.append(pkg)

    def fix() -> bool:
        code, _ = _run([sys.executable, "-m", "pip", "install", "-r", str(APP / "requirements.txt")])
        return code == 0

    return Result("Python packages (requirements.txt)", not missing,
                  "all present" if not missing else "missing: " + ", ".join(missing), fix=fix)


def check_flutter() -> Result:
    code, out = _run(["flutter", "--version"], timeout=180)
    first = out.splitlines()[0] if out else ""
    return Result("Flutter SDK", code == 0, first or "flutter not on PATH",
                  system_fix=None if code == 0 else (_winget_or_brew("Google.Flutter", "--cask flutter")),
                  manual="install Flutter (https://docs.flutter.dev/get-started/install) and add it to PATH")


def check_java() -> Result:
    java = _java()
    return Result("JDK 17+ (Gradle)", bool(java), java or "no java, JAVA_HOME or Android Studio JBR found",
                  system_fix=None if java else _winget_or_brew("Microsoft.OpenJDK.17", "--cask temurin@17"),
                  manual="install a JDK 17 or Android Studio (bundled JBR)")


def check_android_sdk() -> Result:
    sdk = _android_sdk()
    return Result("Android SDK", bool(sdk), str(sdk) if sdk else "not found (ANDROID_HOME / default locations)",
                  system_fix=None if sdk else _winget_or_brew("Google.AndroidStudio", "--cask android-studio"),
                  manual="install Android Studio, then the SDK, platform-tools and cmdline-tools")


def check_android_licences() -> Result:
    sdk = _android_sdk()
    lic = sdk / "licenses" if sdk else None
    ok = bool(lic and any(lic.glob("android-sdk-license*")))
    return Result("Android SDK licences accepted", ok, str(lic) if ok else "not accepted",
                  manual="run: flutter doctor --android-licenses")


def check_cmdline_tools() -> Result:
    sdk = _android_sdk()
    ok = bool(sdk and (sdk / "cmdline-tools").is_dir())
    return Result("Android cmdline-tools", ok, "present" if ok else "missing", gate=False,
                  manual="Android Studio → SDK Manager → SDK Tools → Android SDK Command-line Tools")


def check_pub() -> Result:
    ok = (APP / ".dart_tool" / "package_config.json").exists()

    def fix() -> bool:
        return _run(["flutter", "pub", "get"])[0] == 0

    return Result("Dart packages resolved (flutter pub get)", ok, "resolved" if ok else "not resolved", fix=fix)


def check_keystore(release: bool) -> Result:
    props = APP / "android" / "key.properties"
    values: dict[str, str] = {}
    if props.exists():
        for line in props.read_text(encoding="utf-8").splitlines():
            if "=" in line and not line.lstrip().startswith("#"):
                k, v = line.split("=", 1)
                values[k.strip()] = v.strip()
    complete = all(values.get(k) for k in ("storePassword", "keyPassword", "keyAlias", "storeFile"))
    store_ok = complete and (APP / "android" / "app" / values["storeFile"]).resolve().exists()
    detail = ("complete" if store_ok else
              "storeFile not found" if complete else
              "incomplete" if props.exists() else "missing")

    def fix() -> bool:
        if props.exists():
            return False                       # never overwrite a real key.properties
        shutil.copy(APP / "android" / "key.properties.example", props)
        print(f"    wrote {props} from the template; fill in the passwords and storeFile")
        return False                           # still needs a human

    return Result("Release signing (android/key.properties)", store_ok, detail, gate=release, fix=fix,
                  manual="fill in android/key.properties; see docs/release-workflow.md")


def check_tool(name: str, cmd: list[str], manual: str) -> Result:
    code, out = _run(cmd, timeout=60)
    return Result(name, code == 0, (out.splitlines() or [""])[0] if code == 0 else "not installed",
                  gate=False, manual=manual)


def check_all(release: bool = False, include_advisory: bool = True) -> list[Result]:
    results = [check_python(), check_python_packages(), check_flutter(), check_java(),
               check_android_sdk(), check_android_licences(), check_pub(), check_keystore(release)]
    if include_advisory:
        results += [
            check_cmdline_tools(),
            check_tool("ruff", [sys.executable, "-m", "ruff", "--version"], "pip install ruff"),
            check_tool("adb (device testing)", [_adb(), "version"], "install Android SDK platform-tools"),
        ]
    return results


# -- fixing ----------------------------------------------------------------------

def ask(question: str) -> bool:
    if not sys.stdin.isatty():
        return False
    return input(f"    {question} [y/N] ").strip().lower() in ("y", "yes")


def remediate(results: list[Result]) -> None:
    for r in results:
        if r.ok:
            continue
        print(f"\n  fix: {r.name}")
        if r.fix:
            print("    ✓ fixed" if r.fix() else "    ✗ not fixed automatically")
        elif r.system_fix and ask(f"Run `{' '.join(r.system_fix)}`?"):
            code, out = _run(r.system_fix, timeout=3600)
            print("    ✓ installed (open a new terminal if PATH changed)" if code == 0 else f"    ✗ {out[-300:]}")
        if r.manual:
            print(f"    manual: {r.manual}")


def report(results: list[Result]) -> int:
    for tier, gate in (("GATES", True), ("ADVISORY", False)):
        rows = [r for r in results if r.gate == gate]
        if rows:
            print(f"\n{tier}")
            for r in rows:
                print(f"  {'✓' if r.ok else '✗'} {r.name:<45} {r.detail}")
    failed = [r for r in results if r.gate and not r.ok]
    print(f"\n{'All gates pass.' if not failed else f'{len(failed)} gate(s) failed.'}")
    return 1 if failed else 0


def main(argv: list[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fix", action="store_true", help="attempt remediations, then re-check")
    ap.add_argument("--release", action="store_true", help="treat release signing as a gate")
    ap.add_argument("--gates-only", action="store_true", help="skip advisory checks")
    args = ap.parse_args(argv)

    results = check_all(args.release, not args.gates_only)
    if args.fix and any(not r.ok for r in results):
        remediate(results)
        results = check_all(args.release, not args.gates_only)
    return report(results)


if __name__ == "__main__":
    sys.exit(main())
