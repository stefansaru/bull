"""The wizard pipeline: from a clean checkout to signed bundles (PROC-REPO-005).

Development run:  doctor → content → validate → rights → bundle → pub get → analyze → tests → report
Release run adds: strict rights gate → bundle size gate → version bump → signed AAB → signature check
                  → release log. Store upload stays manual.

Exit codes: 0 success · 1 a gate failed (development run) · 2 the release gate blocked
the build (no artefact) · 3 the build itself failed.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

import yaml

from . import bundle, content, paths, report, rights, validate


@dataclass
class Step:
    name: str
    gate: bool = True
    status: str = "skip"            # pass | warn | fail | skip
    detail: list[str] = field(default_factory=list)


def load_config() -> dict:
    return yaml.safe_load(paths.CONFIG.read_text(encoding="utf-8")) or {}


def flutter_cmd() -> str:
    return shutil.which("flutter") or shutil.which("flutter.bat") or "flutter"


def run(cmd: list[str], cwd: Path = paths.APP) -> tuple[int, str]:
    print(f"  $ {' '.join(cmd)}", flush=True)
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, encoding="utf-8",
                           errors="replace", shell=(os.name == "nt" and cmd[0].lower().endswith(".bat")))
    except OSError as e:
        return 127, str(e)
    return p.returncode, (p.stdout + p.stderr)


def tail(text: str, n: int = 25) -> list[str]:
    return [line for line in text.strip().splitlines() if line.strip()][-n:]


def bump_build_number() -> str:
    text = paths.PUBSPEC.read_text(encoding="utf-8")
    m = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", text, re.M)
    if not m:
        raise RuntimeError("pubspec.yaml has no `version: x.y.z+n` line")
    new = f"{m.group(1)}+{int(m.group(2)) + 1}"
    paths.PUBSPEC.write_text(text[:m.start()] + f"version: {new}" + text[m.end():], encoding="utf-8")
    return new


def find_jarsigner() -> str | None:
    found = shutil.which("jarsigner")
    if found:
        return found
    candidates = [os.environ.get("JAVA_HOME", "")]
    if os.name == "nt":
        candidates += [r"C:\Program Files\Android\Android Studio\jbr"]
    for home in filter(None, candidates):
        exe = Path(home) / "bin" / ("jarsigner.exe" if os.name == "nt" else "jarsigner")
        if exe.exists():
            return str(exe)
    return None


class Wizard:
    def __init__(self, release: bool, skip_flutter: bool = False):
        self.release = release
        self.skip_flutter = skip_flutter
        self.cfg = load_config()
        self.steps: list[Step] = []
        self.sections: list[content.Section] = []
        self.languages: list[str] = []
        self.shipped: list[str] = []

    # -- helpers ----------------------------------------------------------
    def step(self, name: str, gate: bool = True) -> Step:
        s = Step(name, gate)
        self.steps.append(s)
        print(f"\n▶ {name}", flush=True)
        return s

    def gates_ok(self) -> bool:
        return not any(s.gate and s.status == "fail" for s in self.steps)

    # -- steps ------------------------------------------------------------
    def doctor(self) -> None:
        s = self.step("Doctor (gates)")
        sys.path.insert(0, str(paths.APP))
        import doctor  # app/doctor.py

        results = doctor.check_all(release=self.release, include_advisory=False)
        failed = [r for r in results if r.gate and not r.ok]
        s.detail = [f"{'ok ' if r.ok else 'FAIL'} {r.name}: {r.detail}" for r in results]
        s.status = "fail" if failed else "pass"

    def load_content(self) -> None:
        s = self.step("Content: read the wiki")
        master = self.cfg.get("master_language", "en")
        candidates = list(self.cfg.get("candidate_languages", []))
        self.sections = content.load_sections([master, *candidates])
        threshold = float(self.cfg.get("min_translation_coverage", 0.98))
        self.languages = [master]
        for lang in candidates:
            cov = content.coverage(self.sections, lang)
            ships = cov >= threshold
            if ships:
                self.languages.append(lang)
            s.detail.append(f"{lang}: {cov:.1%} translated — {'ships' if ships else 'held back'}")
        s.detail.insert(0, f"{len(self.sections)} sections; languages shipped: {', '.join(self.languages)}")
        s.status = "pass" if self.sections else "fail"

    def validate(self) -> None:
        s = self.step("Content: validate")
        errors, warnings = validate.validate(self.sections, content.referenced_images(self.sections))
        s.detail = [f"ERROR {e}" for e in errors] + [f"warn {w}" for w in warnings[:50]]
        if len(warnings) > 50:
            s.detail.append(f"… {len(warnings) - 50} more warnings")
        s.status = "fail" if errors else ("warn" if warnings else "pass")

    def rights_gate(self) -> None:
        s = self.step("Rights gate (images)")
        referenced = content.referenced_images(self.sections)
        verdict = rights.evaluate(referenced, rights.load(), rights.load_references())
        self.shipped = verdict.cleared
        s.detail = [f"{len(referenced)} images referenced: {len(verdict.cleared)} cleared, "
                    f"{len(verdict.omitted)} omitted by decision, {len(verdict.pending)} pending, "
                    f"{len(verdict.invalid)} invalid"]
        # Per source, so the owner can clear or omit a whole reference at once (bull DR-014).
        for src, c in sorted(verdict.by_source.items(), key=lambda kv: -sum(kv[1].values())):
            s.detail.append(f"  {src}: " + ", ".join(f"{n} {k}" for k, n in c.items() if n))
        s.detail += [f"invalid (cleared without provenance/licence, or unknown status): {i}"
                     for i in verdict.invalid[:20]]
        if not paths.RIGHTS.exists():
            s.detail.append("wiki/assets/rights.yml does not exist — run `wizard.py --rights-init`")
        if verdict.blocks_release:
            s.status = "fail" if self.release else "warn"
            s.gate = self.release
            if not self.release:
                s.detail.append("development run: uncleared images are left out of the bundle")
        else:
            s.status = "pass"

    def write_bundle(self) -> None:
        s = self.step("Bundle: write assets/content")
        res = bundle.write(self.sections, content.load_entities(), self.languages, self.shipped, self.cfg)
        s.detail = [f"{res.sections} sections, {res.entities} entities, {res.images_shipped} images, "
                    f"{res.images_dropped} image references left out (not cleared), {res.size_mb} MB"]
        limit = float(self.cfg.get("bundle_size_limit_mb", 150))
        if res.size_mb > limit:
            s.detail.append(f"bundle exceeds {limit} MB — move images to a Play Asset Delivery pack")
            s.status = "fail" if self.release else "warn"
        else:
            s.status = "pass"

    def flutter(self, name: str, args: list[str], gate: bool = True) -> bool:
        s = self.step(name, gate)
        if self.skip_flutter:
            s.detail = ["skipped (--skip-flutter)"]
            return True
        code, out = run([flutter_cmd(), *args])
        s.status = "pass" if code == 0 else "fail"
        s.detail = tail(out)
        return code == 0

    def pytest(self) -> None:
        s = self.step("Wizard tests (pytest)")
        code, out = run([sys.executable, "-m", "pytest", "-q", "wizard/tests"])
        s.status = "pass" if code == 0 else "fail"
        s.detail = tail(out, 10)

    def build_release(self) -> int:
        s = self.step("Version bump")
        version = bump_build_number()
        s.status, s.detail = "pass", [f"pubspec version → {version}"]

        if not self.flutter("Build signed App Bundle", ["build", "appbundle", "--release"]):
            return 3
        aab = paths.APP / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab"

        s = self.step("Verify signature")
        signer = find_jarsigner()
        if not aab.exists():
            s.status, s.detail = "fail", [f"missing artefact: {aab}"]
            return 3
        if signer:
            code, out = run([signer, "-verify", str(aab)])
            ok = code == 0 and "jar verified" in out
            s.status, s.detail = ("pass" if ok else "fail"), tail(out, 5)
            if not ok:
                return 3
        else:
            s.status, s.gate, s.detail = "warn", False, ["jarsigner not found; verify by hand"]

        s = self.step("Release log", gate=False)
        entry = {"date": datetime.now(timezone.utc).isoformat(timespec="seconds"), "version": version,
                 "git": bundle.git_commit(), "languages": self.languages,
                 "images": len(self.shipped), "released_to_store": False}
        with paths.RELEASE_LOG.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        s.status, s.detail = "pass", [json.dumps(entry, ensure_ascii=False), f"artefact: {aab}"]
        return 0

    # -- orchestration ----------------------------------------------------
    def run(self, only: str | None = None) -> int:
        mode = "release" if self.release else "development"
        if only != "content":
            self.doctor()
        self.load_content()
        self.validate()
        self.rights_gate()
        if only == "content":
            if self.gates_ok():
                self.write_bundle()
        else:
            if self.gates_ok():
                self.write_bundle()
                self.flutter("flutter pub get (+ gen-l10n)", ["pub", "get"])
                self.flutter("flutter analyze", ["analyze"])
                self.flutter("flutter test (incl. lifecycle baselines)", ["test"])
                self.pytest()

        code = 0
        if not self.gates_ok():
            code = 2 if self.release else 1
        elif self.release and only is None:
            code = self.build_release()
        verdict = "PASS" if code == 0 and self.gates_ok() else "BLOCKED"
        out = report.write(self.steps, verdict if self.release else f"{verdict} (development run)", mode)
        print(f"\nVerdict: {verdict} — report: {out}")
        return code
