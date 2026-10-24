"""Filesystem locations the wizard works with, resolved from this file's position."""

from __future__ import annotations

from pathlib import Path

APP = Path(__file__).resolve().parents[2]          # bull/app
REPO = APP.parent                                  # bull
WIKI = REPO / "wiki"
NARRATIVE = WIKI / "narrative"
ENTITIES = WIKI / "entities"
ASSETS = WIKI / "assets"
RIGHTS = ASSETS / "rights.yml"

BUNDLE = APP / "assets" / "content"                # generated, gitignored
BUNDLE_JSON = BUNDLE / "content.json"
BUNDLE_IMG = BUNDLE / "img"

CONFIG = APP / "wizard" / "config.yaml"
REPORTS = APP / "build" / "reports"
RELEASE_LOG = APP / "docs" / "release_log.jsonl"
PUBSPEC = APP / "pubspec.yaml"
