# bull — Moldavian Bull's Head (1858) stamps

A local, AI-native **knowledge wiki** for the study of the Moldavian *Cap de bour*
(Bull's Head / aurochs-head) stamps of 1858, plus a **pipeline** that regenerates the
book from it. The wiki is the source of truth; the book is a rendering.

## Layout

```
input/    the source 4-language A4 book (.docx)
tools/    the pipeline (Python): extract, structure, generate, export, audit
work/     intermediate artifacts (gitignored): extraction JSON, media, outline
wiki/     THE VAULT (Obsidian-style Markdown) — start at wiki/index.md
output/   generated books
```

## The pipeline (concepts → narrative → pagination)

1. **Extract** — `tools/extract.py <book.docx> work/extract` → ordered `document_model.json` + media.
2. **Structure** — group blocks into sections/content-units with provenance.
3. **Concepts** — entity graph in `wiki/entities/` (issues, denominations, handstamps, …).
4. **Narrate** — faithful prose in `wiki/narrative/`, 4 languages, verbatim first.
5. **Paginate** — `tools/export_book.py` rebuilds the book (`output/`).
6. **Audit** — `tools/audit.py` validates against `wiki/meta/requirements.md`.

## Read first

- `wiki/index.md` — home / map of content.
- `wiki/concept.md` — what and why.
- `wiki/AGENTS.md` — how to work here.
- `wiki/strategy/multilanguage-analysis.md` — should the book stay 4-up? (recommends: no).

## Requirements

Python 3.13 with `lxml` and `python-docx` (both present). Open `wiki/` as an Obsidian
vault for graph view and wikilinks.
