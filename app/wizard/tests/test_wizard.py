"""Tests for the content compiler and the rights gate (PROC-TST-001)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from bullwiz import bundle, content, paths, rights  # noqa: E402

PAGE = """---
id: narrative/01-intro/001-start
type: narrative-section
chapter: "Intro"
order: 10
level: 2
title:
  en: "Start here"
---

## Start here

<!-- u:u00001 kind:text -->
See [[../entities/issues/issue-bull-1|the first issue]] and **bold** words.

<!-- u:u00002 kind:figure -->
![a.png](../../assets/media/a.png)

*Figure 1: An aurochs*

<!-- u:u00003 kind:table -->
![b.png](../../assets/media/b.png)

| 🎨 Black \\| Negru | Blue |
|---|---|
"""

SIDECAR = """page: narrative/01-intro/001-start
title: {ro: "Începe aici"}
units:
  u00001:
    kind: text
    ro: {status: ok, text: "Vezi prima emisiune."}
    fr: {status: stale, text: "Ancien texte."}
  u00002:
    kind: figure
    ro: {status: ok, text: "*Figura 1: Un bour*"}
"""


@pytest.fixture()
def wiki(tmp_path, monkeypatch):
    root = tmp_path / "wiki"
    (root / "narrative" / "01-intro").mkdir(parents=True)
    (root / "assets" / "media").mkdir(parents=True)
    (root / "narrative" / "01-intro" / "001-start.md").write_text(PAGE, encoding="utf-8")
    (root / "narrative" / "01-intro" / "001-start.i18n.yml").write_text(SIDECAR, encoding="utf-8")
    for name in ("a.png", "b.png"):
        Image.new("RGB", (3000, 1500), (200, 180, 150)).save(root / "assets" / "media" / name)
    monkeypatch.setattr(paths, "WIKI", root)
    monkeypatch.setattr(paths, "NARRATIVE", root / "narrative")
    return root


def test_sections_units_and_images(wiki):
    [s] = content.load_sections(["en", "ro", "fr"])
    assert s.title == {"en": "Start here", "ro": "Începe aici"}
    text, fig, table = s.units
    assert text.text["en"] == "See the first issue and bold words."
    assert fig.images == ["assets/media/a.png"]
    assert fig.caption["en"] == "Figure 1: An aurochs"
    assert table.images == ["assets/media/b.png"]
    assert table.rows["en"] == [["🎨 Black | Negru", "Blue"]]
    assert content.referenced_images([s]) == ["assets/media/a.png", "assets/media/b.png"]


def test_only_ok_translations_are_used(wiki):
    [s] = content.load_sections(["en", "ro", "fr"])
    text, fig, _ = s.units
    assert text.text["ro"] == "Vezi prima emisiune."
    assert "fr" not in text.text                       # stale is not shipped
    assert fig.caption["ro"] == "Figura 1: Un bour"
    assert content.coverage([s], "ro") == pytest.approx(2 / 3)


def test_rights_gate(tmp_path):
    reg = tmp_path / "rights.yml"
    referenced = ["assets/media/a.png", "assets/media/b.png", "assets/media/c.png"]
    assert rights.init(referenced[:2], reg) == 2
    assert rights.init(referenced[:2], reg) == 0       # existing entries are kept
    data = rights.load(reg)
    data["assets/media/a.png"].update(status="cleared", provenance="own scan", licence="own work")
    data["assets/media/b.png"].update(status="omit")
    v = rights.evaluate(referenced, data)
    assert v.cleared == ["assets/media/a.png"]
    assert v.omitted == ["assets/media/b.png"]
    assert v.pending == ["assets/media/c.png"]         # not in the registry = pending
    assert v.blocks_release


def test_cleared_without_provenance_is_invalid():
    v = rights.evaluate(["x.png"], {"x.png": {"status": "cleared", "provenance": "", "licence": ""}})
    assert v.invalid == ["x.png"] and v.blocks_release


def test_bundle_ships_only_cleared_images(wiki, tmp_path):
    sections = content.load_sections(["en", "ro"])
    out = tmp_path / "bundle"
    res = bundle.write(sections, [], ["en", "ro"], ["assets/media/b.png"],
                       {"image_max_edge": 1024, "image_quality": 70}, out)
    doc = json.loads((out / "content.json").read_text(encoding="utf-8"))
    units = doc["sections"][0]["units"]
    assert [u["kind"] for u in units] == ["text", "table"]   # figure dropped with its image
    assert units[1]["images"] == ["img/media__b.webp"]
    with Image.open(out / "img" / "media__b.webp") as im:
        assert max(im.size) == 1024
    assert not (out / "img" / "media__a.webp").exists()
    assert res.images_shipped == 1 and res.images_dropped == 1


def test_bundle_removes_images_no_longer_cleared(wiki, tmp_path):
    sections = content.load_sections(["en"])
    out = tmp_path / "bundle"
    cfg = {"image_max_edge": 256}
    bundle.write(sections, [], ["en"], ["assets/media/a.png", "assets/media/b.png"], cfg, out)
    bundle.write(sections, [], ["en"], ["assets/media/b.png"], cfg, out)
    assert not (out / "img" / "media__a.webp").exists()
