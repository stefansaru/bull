"""Tests for bundle schema 2: links, auto-links, dual dates, entities, tables, image index."""

from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path

import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "tools"))

from bullwiz import bundle, content, links, paths  # noqa: E402

NARRATIVE = """---
id: narrative/01-intro/001-start
type: narrative-section
chapter: "Intro"
order: 10
level: 2
title:
  en: "1858 📯 Start here"
---

## 1858 📯 Start here

<!-- u:u00001 kind:text -->
See [[../../entities/colors/carmine-red|carmine]] and [[../../meta/glossary|the glossary]]. Priced in the LP catalogue and by Michel (MI); signed on 1/13 June 1865 and dated 15 July 1858 (J). G alone is a letter. Carmine red ink.

<!-- u:u00002 kind:figure -->
![a.png](../../assets/media/a.png)

*Figure 1: An aurochs*

<!-- u:u00003 kind:table -->
| Julian | Calendar | Gregorian |
|---|---|---|
| 1858-01-01 | Wednesday | 1858-01-13 |
| LP 4 | RAL 3002 | x |
"""

COLOUR = """---
id: entities/colors/carmine-red
type: color
title: {en: Carmine red, ro: Roşu carmin}
hex: '#A4343A'
family: red
summary: Carmine red — matched in the book to RAL 3002.
swatches:
- {system: ral, code: '3002', name: Carmine Red, description: '', hex: '#9B2321'}
related: ['[[light-red]]']
narrative_refs: ['[[../../narrative/01-intro/001-start]]']
---

# Carmine red

The carmine red of the 108 parale. Carmine red is not linked to itself.
"""

LIGHT_RED = """---
id: entities/colors/light-red
type: color
title: {en: Light red}
hex: '#D47479'
---

# Light red

| Standard | Hex |
|---|---|
| RAL 3014 | `#D47479` |

A pale red with no summary field, so the first paragraph long enough serves as its summary.
"""

ABBR = """---
id: entities/abbreviations/abbr-{slug}
type: abbreviation
title: {{en: "{abbr} — {exp}"}}
abbr: {abbr}
forms: [{abbr}]
category: {cat}
expansion: {{en: "{exp}"}}
summary: "{abbr}: {exp}."
{see}---

# {abbr}
"""

LP_PAGE = """---
id: entities/references/catalogues/lp
type: reference
title: {en: "LP price list"}
---

# LP
"""


@pytest.fixture()
def wiki(tmp_path, monkeypatch):
    root = tmp_path / "wiki"
    (root / "narrative" / "01-intro").mkdir(parents=True)
    (root / "assets" / "media").mkdir(parents=True)
    (root / "meta").mkdir()
    (root / "meta" / "glossary.md").write_text("---\nid: meta/glossary\n---\n", encoding="utf-8")
    (root / "narrative" / "01-intro" / "001-start.md").write_text(NARRATIVE, encoding="utf-8")
    ents = root / "entities"
    for sub in ("colors", "abbreviations", "references/catalogues"):
        (ents / sub).mkdir(parents=True)
    (ents / "colors" / "carmine-red.md").write_text(COLOUR, encoding="utf-8")
    (ents / "colors" / "light-red.md").write_text(LIGHT_RED, encoding="utf-8")
    (ents / "references" / "catalogues" / "lp.md").write_text(LP_PAGE, encoding="utf-8")
    for slug, abbr, exp, cat, see in [
        ("lp", "LP", "Romanian price list", "catalogue", "see: '[[../references/catalogues/lp]]'\n"),
        ("mi", "MI", "Michel Catalogue", "catalogue", ""),
        ("g-gregorian", "G", "Gregorian calendar", "calendar", ""),
        ("ro", "RO", "Romania", "country", ""),
    ]:
        (ents / "abbreviations" / f"abbr-{slug}.md").write_text(
            ABBR.format(slug=slug, abbr=abbr, exp=exp, cat=cat, see=see), encoding="utf-8")
    Image.new("RGB", (400, 200), (200, 180, 150)).save(root / "assets" / "media" / "a.png")
    monkeypatch.setattr(paths, "WIKI", root)
    monkeypatch.setattr(paths, "NARRATIVE", root / "narrative")
    monkeypatch.setattr(paths, "ENTITIES", ents)
    return root


def linked(wiki):
    sections = content.load_sections(["en"])
    entities = content.load_entities()
    stats = links.LinkStats()
    artefacts = {s.id for s in sections} | {e["id"] for e in entities} | set(bundle.INDEX_TITLES)
    pages = {s.page_id: s.id for s in sections} | {e["page_id"]: e["id"] for e in entities}
    for e in entities:
        if e.get("see_id"):
            e["see_id"] = pages.get(e["see_id"], e["see_id"])
    links.finalize(sections, entities, pages, artefacts, stats)
    links.autolink_all(sections, entities, ["en"], stats)
    return sections, entities, stats


def test_wikilinks_become_links_only_to_artefacts(wiki):
    sections, _, stats = linked(wiki)
    text = sections[0].units[0].text["en"]
    assert "⟦entities/colors/carmine-red|carmine⟧" in text
    assert "the glossary" in text and "meta/glossary" not in text      # meta pages don't ship
    assert stats.dropped["meta/glossary"] == 1


def test_curated_autolinks(wiki):
    sections, entities, stats = linked(wiki)
    text = sections[0].units[0].text["en"]
    assert "⟦entities/references/catalogues/lp|LP⟧" in text            # `see` target wins
    assert "⟦entities/abbreviations/abbr-mi|MI⟧" in text
    assert "⟦entities/concepts/julian-calendar|(J)⟧" in text
    assert "G alone is a letter" in text                                # one letter: never alone
    assert "⟦entities/colors/carmine-red|Carmine red⟧ ink" in text
    carmine = next(e for e in entities if e["id"] == "entities/colors/carmine-red")
    body = " ".join(u["text"]["en"] for u in carmine["units"] if "text" in u)
    assert "⟦entities/colors/carmine-red" not in body                  # no self-links
    rows = sections[0].units[2].rows["en"]
    assert rows[2][1] == "⟦entities/colors/carmine-red|RAL 3002⟧"      # colour codes in tables
    assert stats.auto["LP"] == 2


def test_autolink_skips_headings_and_existing_links():
    terms = [links.Term(__import__("re").compile(r"(?<![\w/])LP(?![\w/])"), "x/lp", "LP")]
    stats = links.LinkStats()
    out = links.autolink("# LP heading\n⟦a/b|LP inside⟧ and LP", "en", "owner", terms, stats)
    assert out == "# LP heading\n⟦a/b|LP inside⟧ and ⟦x/lp|LP⟧"


@pytest.mark.parametrize("written, expected", [
    ("1/13 June 1865", "1 (13) June 1865"),
    ("24 January / 5 February 1859", "24 January (5 February) 1859"),
    ("25 December 1865 / 6 January 1866", "25 December 1865 (6 January 1866)"),
    ("18/30 March 1856", "18 (30) March 1856"),
    ("20/1 December 1861", "20 December 1861 (1 January 1862)"),
    ("19/1 December 1861", "19 November (1 December) 1861"),   # month names the Gregorian day
])
def test_dual_dates_are_rewritten(written, expected):
    stats = links.LinkStats()
    out = links.autolink(f"on {written} it", "en", "o", [], stats)
    assert out == f"on {expected} ⟦{links.DUAL_DATE}|{links.DUAL_TAG}⟧ it"
    assert stats.dates_rewritten == 1


def test_inconsistent_dual_date_is_left_alone():
    stats = links.LinkStats()
    assert links.autolink("on 1/20 June 1865", "en", "o", [], stats) == "on 1/20 June 1865"
    assert stats.dates_unconverted == ["1/20 June 1865"]


def test_julian_conversion_across_the_1900_change():
    assert links.julian_to_gregorian(1858, 7, 15) == date(1858, 7, 27)
    assert links.julian_to_gregorian(1919, 4, 1) == date(1919, 4, 14)


def test_sections_carry_year_summary_and_table_head(wiki):
    [s] = content.load_sections(["en"])
    assert s.year == "1858"
    assert s.units[2].head == 1


def test_entities_units_summary_and_relations(wiki):
    _, entities, _ = linked(wiki)
    by_id = {e["id"]: e for e in entities}
    carmine = by_id["entities/colors/carmine-red"]
    assert carmine["summary"]["en"].startswith("Carmine red — matched")
    assert carmine["hex"] == "#A4343A" and carmine["swatches"][0]["code"] == "3002"
    assert {"id": "entities/colors/light-red", "rel": "related"} in carmine["related"]
    assert {"id": "narrative/01-intro/001-start", "rel": "in the book"} in carmine["related"]
    light = by_id["entities/colors/light-red"]
    assert light["summary"]["en"].startswith("A pale red")              # first paragraph
    table = next(u for u in light["units"] if u["kind"] == "table")
    assert table["head"] == 1 and table["rows"]["en"][1][0] == "RAL 3014"
    assert table["uid"] == "entities/colors/light-red#1"


def test_bundle_schema_2_image_index_and_indexes(wiki, tmp_path):
    sections, entities, _ = linked(wiki)
    out = tmp_path / "bundle"
    bundle.write(sections, entities, ["en"], ["assets/media/a.png"], {"image_max_edge": 128}, out)
    doc = json.loads((out / "content.json").read_text(encoding="utf-8"))
    assert doc["schema"] == 2
    assert doc["images"] == [{"id": "media__a", "number": 1, "file": "img/media__a.webp",
                              "caption": {"en": "Figure 1: An aurochs"}, "unit": "u00002",
                              "section": "narrative/01-intro/001-start"}]
    assert [i["id"] for i in doc["indexes"]] == list(bundle.INDEX_TITLES)
    sec = doc["sections"][0]
    assert sec["year"] == "1858" and sec["summary"]["en"].startswith("See carmine")
    assert all("page_id" not in e and "see_id" not in e for e in doc["entities"])


def test_generated_pages_respect_hand_ownership(tmp_path):
    import wikilib
    page = tmp_path / "x.md"
    assert wikilib.write_generated(page, {"id": "x"}, "body", "tools/t.py")
    assert not wikilib.write_generated(page, {"id": "x"}, "body", "tools/t.py")   # unchanged
    page.write_text("---\nid: x\n---\n\nedited by hand\n", encoding="utf-8")
    with pytest.raises(wikilib.HandOwnedPage):
        wikilib.write_generated(page, {"id": "x"}, "body", "tools/t.py")
