# Content pipeline and image rights

## Bundle format (`assets/content/content.json`, schema 2)

```json
{
  "schema": 2, "generated": "…", "source_commit": "ef57e42",
  "languages": ["en"],
  "chapters": [{"id": "04-1858", "label": "1858 📅", "sections": ["narrative/04-1858/001-1858", "…"]}],
  "sections": [{
    "id": "narrative/04-1858/004-…", "chapter": "04-1858", "order": 103, "level": 2,
    "title": {"en": "…", "ro": "…"}, "summary": {"en": "First paragraph …"}, "year": "1858",
    "units": [
      {"uid": "u00473", "kind": "quad",   "text": {"en": "… ⟦entities/references/catalogues/lp|LP⟧ …"}},
      {"uid": "u00474", "kind": "figure", "images": ["img/media__image219.webp"], "caption": {"en": "Figure 134: …"}},
      {"uid": "u00739", "kind": "table",  "text": {}, "rows": {"en": [["…", "…"]]}, "head": 1, "images": ["…"]}
    ]
  }],
  "entities": [{
    "id": "entities/colors/carmine-red", "type": "color", "group": "colors", "subgroup": "",
    "title": {"en": "Carmine red"}, "summary": {"en": "…"}, "year": "",
    "units": [{"uid": "entities/colors/carmine-red#1", "kind": "text", "text": {"en": "…"}},
              {"uid": "entities/colors/carmine-red#2", "kind": "table", "rows": {"en": [["…"]]}, "head": 1}],
    "related": [{"id": "entities/colors/light-red", "rel": "related"}],
    "hex": "#A4343A", "family": "red", "swatches": [{"system": "pantone", "code": "1807", "hex": "#A4343A", "…": "…"}]
  }],
  "images": [{"id": "media__image219", "number": 1, "file": "img/media__image219.webp",
              "caption": {"en": "…"}, "unit": "u00474", "section": "narrative/…"}],
  "indexes": [{"id": "index/images", "title": {"en": "Images"}}, "…",
              {"id": "index/calendars", "title": {"en": "Calendars"}, "items": ["entities/concepts/julian-calendar", "…"]}]
}
```

- **Links** (UIC-LNK) are written into text as `⟦artefact-id|label⟧`. Wikilinks become links when their target ships as an artefact (a section, an entity, or an index); links to `meta/`, `sources/` and other non-shipping pages fall back to their label. The app strips the markup for search and read-aloud.
- **Auto-links** are added at build time (`bullwiz/links.py`, owner ruling 2026-10-25), never in the wiki: unambiguous multi-letter abbreviations (LP, AMS, M1, PM52 …; country codes, one-letter forms and `AT` excluded), multi-word colour names and Pantone/RAL/AMS codes, `(J)`/`(G)` markers, and **dual dates**, which are also rewritten into the DR-015 notation (`1/13 June 1865` → `1 (13) June 1865 ᴶ⁄ᴳ`, the tag linking to the notation page). Every run writes `build/reports/autolinks.txt` with the counts and any date pair that does not convert.
- **Stable IDs** (UIC-DAT-05): narrative units keep their wiki `uid`; entity units are `<entity-id>#<n>`; table rows and columns are addressed as `<uid>-r<n>` / `<uid>-c<n>` (0-based, header rows included, `head` = number of header rows); images by `id` (the bundled file stem), with `number` = display order among shipped images.
- **Entities** carry `summary` (frontmatter, else first paragraph), `year`, `related` (typed: related, see, issue, denomination, handstamp, series, published in, in the book, reference) and type-specific fields: colours `hex`/`family`/`swatches`, abbreviations `abbr`/`forms`/`category`/`expansion`.
- **Text** is otherwise cleaned of wiki syntax: emphasis and inline code markers are dropped. One paragraph per line.
- **Images** are converted to WebP, long edge 2048 px, quality 82 (`wizard/config.yaml`). They are stored flat in `img/` (`media/image1.png` becomes `img/media__image1.webp`), because Flutter asset directories are not recursive.
- **Translations** come from the `.i18n.yml` sidecars. Only entries with `status: ok` are used: stale or orphan text never ships.

### Generated wiki pages

`tools/extract_swatches.py` reads the colour tables' cell shading from the source book into `work/extract/swatches.json`; `tools/gen_colors.py` and `tools/gen_abbreviations.py` then write `wiki/entities/colors/` and `wiki/entities/abbreviations/`. Generated pages carry `generated_by:`; a generator never overwrites a page whose `generated_by` was removed (`tools/wikilib.py`).

## Languages (STRAT-OBJ-002)

English always ships. A candidate language (RO, FR, DE) ships when its share of translated units reaches `min_translation_coverage` (98 %). The wizard report shows each language's coverage. As of 2026-10-25, only the quadrilingual blocks are translated (≈ 13 % of units), so the bundle is **English only**.

## Image rights (NORM-COPY-01, PROC-RGT-001)

Registry: `wiki/assets/rights.yml`, one entry per referenced image, keyed by its path under `wiki/`.

```yaml
images:
  assets/media/image219.jpg:
    status: cleared          # pending | cleared | omit
    provenance: "Own scan of item in the author's collection"
    licence: "Own work"
    note: ""
```

| Status | Effect in a development run | Effect in a release run |
|--------|-----------------------------|-------------------------|
| `cleared` (with provenance **and** licence) | ships | ships |
| `cleared` without provenance or licence | left out, reported invalid | **blocks** |
| `omit` | left out | left out (recorded decision) |
| `pending` / not in registry | left out, warning | **blocks** |

A figure whose image is not shipped is dropped together with its caption. A table or text unit keeps its text and loses only the image.

### Clearing a whole source at once (bull DR-014)

Most images come from a reference (a book, a sale, a museum). Rights are usually granted per source, so:

1. Give the image its `source: references/<kind>/<slug>` (and a `locator`). `--rights-init` does this automatically for images under a reference's `assets:` folder.
2. On the reference page, set `rights_default: {status: cleared, licence: "permission, letter 2026-11-02", note: "…"}`, or `status: omit`.
3. Every `pending` image from that source now follows the default. An image's own status still wins: set `omit` on single images you do not want, even when the source is cleared.

The wizard report lists the counts per source, so you can see which decision unlocks the most images.

### Clearing an image, step by step

1. Identify the source: own photograph or scan, a book (author, year, page), an auction catalogue (house, sale, lot), or an archive.
2. Decide the basis for reproducing it:
   - own work;
   - public domain (say why, e.g. the author died more than 70 years ago, or a faithful photo of a two-dimensional public-domain object, if your legal assessment accepts that);
   - permission, citing the letter or email by date;
   - a licence (name it).
3. Fill in `provenance`, `licence` and `note`, then set `status: cleared`. Keep permission documents outside the repository; `note` points to them.
4. If you cannot clear it, set `status: omit`, or replace the image in the wiki with one you can clear.
5. `py -3 app/wizard/wizard.py --rights-init` adds new images as `pending`. It never changes existing entries.

As of 2026-10-25: 1,049 images are referenced, 0 are cleared.
