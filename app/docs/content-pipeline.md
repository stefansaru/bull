# Content pipeline and image rights

## Bundle format (`assets/content/content.json`, schema 1)

```json
{
  "schema": 1, "generated": "…", "source_commit": "ef57e42",
  "languages": ["en"],
  "chapters": [{"id": "04-1858", "label": "1858 📅", "sections": ["narrative/04-1858/001-1858", "…"]}],
  "sections": [{
    "id": "narrative/04-1858/004-…", "chapter": "04-1858", "order": 103, "level": 2,
    "title": {"en": "…", "ro": "…"},
    "units": [
      {"uid": "u00473", "kind": "quad",   "text": {"en": "…"}},
      {"uid": "u00474", "kind": "figure", "images": ["img/media__image219.webp"], "caption": {"en": "Figure 134: …"}},
      {"uid": "u00739", "kind": "table",  "text": {}, "rows": {"en": [["…", "…"]]}, "images": ["…"]}
    ]
  }],
  "entities": [{"id": "entities/denominations/108-parale", "group": "denominations", "title": {"en": "…"}, "text": {"en": "…"}}]
}
```

- **Text** is cleaned of wiki syntax: `[[link|label]]` becomes `label`, and emphasis and inline code markers are dropped. One paragraph per line.
- **Images** are converted to WebP, long edge 2048 px, quality 82 (`wizard/config.yaml`). They are stored flat in `img/` (`media/image1.png` becomes `img/media__image1.webp`), because Flutter asset directories are not recursive.
- **Translations** come from the `.i18n.yml` sidecars. Only entries with `status: ok` are used: stale or orphan text never ships.

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
