# UI concept — the artefact browser

**Status: proposed** (2026-10-25). This concept awaits review — see
[`ui-concept-review.md`](ui-concept-review.md). The accepting decision will become a
bull DR once the review lands. It describes the app's target UI; the current code
(`lib/src/ui/`) implements only a fraction of it. Implementation work is tracked in
[`../TODO.md`](../TODO.md).

Each feature carries a stable ID (`UIC-…`) so requirements, TODO entries and the
review can cite it. Changing an ID means changing every citation; don't.

## 1. Purpose and principles (UIC-PRN)

The app is a tool for **learning about the 1858 Bull's Head stamps**: an interactive
book one can read linearly *and* wander through by following any term that catches
the eye. Charter values apply (jini-apps CH-VAL): the UI is simple, minimalistic and
a joy to use.

- **UIC-PRN-01** — Everything the text refers to is reachable in place: tap it,
  learn what it is, go deeper if you want, come back without losing your spot.
- **UIC-PRN-02** — One uniform page model (the *artefact*, §2) rather than
  per-type screens.
- **UIC-PRN-03** — Chrome stays out of the way: few icons, no text labels in the
  top menu, vertical space is spent on content (§8 hides even the title in
  landscape).
- **UIC-PRN-04** — Every control is reachable by touch **and** by D-pad (§9).

## 2. The artefact model (UIC-ART)

- **UIC-ART-01** — An **artefact** is any page of the book's content: a narrative
  section, an entity (issue, denomination, colour, abbreviation, handstamp, place,
  person, reference, concept, event), or an image (via the image index, §4). All
  artefacts share the same page anatomy and all can be added to favorites.
- **UIC-ART-02** — Page anatomy, portrait, top to bottom:
  1. the **top menu** (UIC-NAV-01);
  2. the **date line** (UIC-ART-03), when the artefact has one;
  3. the **title**, on its own line;
  4. the **body** — text, images, tables;
  5. a **Related artefacts** list (UIC-ART-05).
- **UIC-ART-03** — The **date line** shows the artefact's year or time range and
  the calendar it is expressed in, marked `J` (Julian) or `G` (Gregorian):
  `1858–1862 · G`, or a dual date as `1/13 June 1865 J/G` (Julian first — wiki
  convention C-04). Every token is tappable (UIC-LNK): the year opens the calendar
  tables for that year, `J` opens the Julian-calendar artefact. *The exact display
  format is an open question for the reviewer; C-04 leaves "both vs primary +
  parenthetical" undecided.*
- **UIC-ART-04** — Artefacts without a time dimension **omit the date line**
  entirely; the title moves up. Colours are the canonical example: *Carmine red*
  shows the colour itself (a swatch), its hex code, and the standardized colours
  that match it (Pantone 1807, RAL 3002, AMS 11136).
- **UIC-ART-05** — Each artefact ends with **Related artefacts**: typed, curated
  relations from frontmatter (e.g. other red colours on *Carmine red*; the
  denominations printed in that colour; the issue a denomination belongs to). Each
  entry is a link (UIC-LNK-01).

## 3. Links and previews (UIC-LNK)

- **UIC-LNK-01** — Every reference to another artefact is clickable, styled with a
  **thin dotted underline** — deliberately more discreet than a conventional
  hyperlink, so dense pages stay calm. No colour change; the underline alone marks
  it.
- **UIC-LNK-02** — Tapping a link opens a **preview popup** first, never the page:
  a brief description of the artefact and a **More** button. Dismissing it (tap
  outside, Back) returns to reading with nothing lost. This holds for *all* links,
  from a full chapter down to the `J` in a date.
- **UIC-LNK-03** — **More** opens the artefact's own page. Example: the preview on
  `J` explains the abbreviation in a sentence; More opens the *J — Julian calendar*
  artefact, which carries the full description, a list of **all abbreviations
  beginning with J**, and a link to the **index of all abbreviations**. The same
  pattern applies to every abbreviation.
- **UIC-LNK-04** — The preview text comes from the artefact's `summary` frontmatter
  field, falling back to its first paragraph. (Data prerequisite, §11.)

## 4. Images (UIC-IMG)

- **UIC-IMG-01** — Every image in the book carries a number in one global,
  ordered **image index** — itself a browsable artefact listing all images with
  their captions.
- **UIC-IMG-02** — Any image that can be enlarged is enlarged by tapping it, into
  the full-screen viewer.
- **UIC-IMG-03** — The viewer supports **finger zoom**: pinch out to zoom in,
  pinch in to zoom out, drag to pan.
- **UIC-IMG-04** — While the image fits the screen (not zoomed in), **swiping
  left/right moves to the next/previous image** in the index. Zoomed in, the same
  gestures pan.
- **UIC-IMG-05** — The viewer's top menu: **Back · zoom in (magnifier +) ·
  zoom out (magnifier −) · previous · next**. Previous/next step the image index
  down/up by one — the buttons are the D-pad/TV equivalent of UIC-IMG-04.

## 5. Tables (UIC-TBL)

- **UIC-TBL-01** — Tables render in a dedicated **table viewer** element, shared
  by every table in the book.
- **UIC-TBL-02** — A table wider than the screen offers a **rotate control**: the
  table turns 90° so its width runs along the screen's long edge. Content and
  order are unchanged; only its orientation on screen changes. (Open question for
  the reviewer: interplay with system auto-rotation, and whether a transpose
  option should accompany it.)
- **UIC-TBL-03** — The viewer supports **selection**: tap a row header to select
  the row, a column header for the column, drag across cells for a range.
- **UIC-TBL-04** — A selection can be **bookmarked** (UIC-FAV-03). Opening that
  bookmark later re-opens the table with the same selection highlighted.

## 6. Favorites and bookmarks (UIC-FAV)

- **UIC-FAV-01** — The **star** in the top menu toggles the current artefact as a
  favorite, and the favorites window is where everything starred or bookmarked is
  found again.
- **UIC-FAV-02** — The favorites window lists entries grouped by artefact. An
  artefact with several bookmarks shows as an **expandable tree node**: the page
  on the branch, its bookmarks as leaves.
- **UIC-FAV-03** — Bookmark kinds: the **artefact** itself; a **table selection**
  (UIC-TBL-04); an **image** (by its index number, from the viewer); a **text
  passage** (long-press a paragraph). Each bookmark reopens its artefact at
  exactly that spot.
- **UIC-FAV-04** — The current **reading position** is kept automatically and
  shown at the top of the favorites window as "Continue reading" (today's
  `lastSection`, generalized).
- **UIC-FAV-05** — Deleting: a single bookmark, **all bookmarks of one artefact**,
  or **all bookmarks**. The two bulk actions confirm first.
- **UIC-FAV-06** — The favorites window has its own **search field**: it is the
  global search (§7) with the *favorites-only* filter pre-applied.

## 7. Search (UIC-SRC)

- **UIC-SRC-01** — The search window: **Back** on top, the query field, a
  **filter button showing the number of applied filters** (e.g. `Filters (2)`),
  and the list of matches.
- **UIC-SRC-02** — The filter opens as a **subwindow** of its own. Initial filter
  set: **artefact type** (narrative, colour, abbreviation, reference, …),
  **chapter**, **favorites only**. (Candidate for the reviewer: a language
  filter.)
- **UIC-SRC-03** — One search serves the whole app; entry points differ only in
  pre-applied filters (UIC-FAV-06).

## 8. Orientation and layout (UIC-LAY)

- **UIC-LAY-01** — The app is optimized for **portrait and landscape** and
  switches seamlessly: scroll position, open artefact, selections and popups all
  survive rotation (Flutter restoration IDs, as already implemented).
- **UIC-LAY-02** — In **landscape**, the title and top menu move to the **left
  side** (a rail); the menu buttons keep their order and relative places (back at
  the top, three-dots at the bottom of the rail).
- **UIC-LAY-03** — In landscape a dedicated **title button** appears — it exists
  *only* in landscape. The title and date line are **hidden by default** to give
  the saved vertical space to content; pressing the button shows them (an
  overlay/flyout), pressing again or tapping away hides them.
- **UIC-LAY-04** — Width classes stay as implemented (`scope.dart`): compact
  < 600 dp, medium 600–839, expanded ≥ 840; expanded shows two panes.

## 9. Platforms and input (UIC-PLT)

- **UIC-PLT-01** — The app detects its platform: **Phone, Tablet, TV, or other —
  and *other* is treated as TV** (the safe default: everything reachable without
  touch). Detection follows busy's pattern: TV when Android reports
  `UI_MODE_TYPE_TELEVISION` or `FEATURE_LEANBACK` (platform channel,
  `busy/android/.../MainActivity.kt`); otherwise tablet when the shortest display
  side is ≥ 600 dp (`busy/lib/core/layout_mode.dart`), else phone.
- **UIC-PLT-02** — On TV, text entry uses the **same in-app keyboard element as
  the busy (Day OK) app**: `TvKeyboard` (`busy/lib/widgets/keyboard.dart`) — a
  D-pad-driven on-screen keyboard with text and digits layouts, Romanian
  diacritics, and a single-focus-node grid. Rationale inherited from busy
  REQ-LAY-064: Google TV remotes don't reliably reach the system keyboard.
- **UIC-PLT-03** — When the platform **cannot be determined**, a **keyboard
  button** appears next to text fields to open the in-app keyboard explicitly.
- **UIC-PLT-04** — Every interactive element — links, previews, image viewer
  controls, table selection, favorites tree — is operable by D-pad alone
  (existing TV remote-only test to be extended per feature).

## 10. Navigation chrome and the three-dots menu (UIC-NAV)

- **UIC-NAV-01** — The top menu, left to right:
  1. **Back** (top left);
  2. **Sections** — three horizontal lines, each preceded by a dot, so the icon
     reads as a bullet list (deliberately *not* the plain hamburger); opens the
     table of contents;
  3. **Star** — favorites (UIC-FAV-01);
  4. **Search** — magnifying glass (§7);
  5. **Three-dots** (top right) — the menu below.
- **UIC-NAV-02** — The three-dots menu on an artefact page opens a menu window
  with entries, each a **subwindow** of its own:
  - **Audio** (UIC-NAV-03)
  - **Language** (UIC-NAV-04)
  - **Help** (UIC-NAV-05)
  - **Colours** (UIC-NAV-06)
  - **Privacy policy** (link; APP-PRV-001)
- **UIC-NAV-03** — **Audio**, modelled on Amethyst's audio window
  (`amethyst/lib/widgets/audio_window.dart`): a sound-effects switch (UI feedback
  sounds), and **text-to-speech**: a "read this page aloud" control with
  play/stop, plus voice/rate settings. **TTS ships in v1** for all shipped
  languages. Reading order: date line, title, body units in order, image captions.
- **UIC-NAV-04** — **Language**, same as Amethyst
  (`amethyst/lib/widgets/language_reorder_window.dart`): one row per language —
  code, name, flag, country (`EN · English · 🇺🇸 · USA`), tap to apply,
  drag to reorder. Languages: EN always; RO/FR/DE as they reach coverage
  (content-pipeline rules unchanged).
- **UIC-NAV-05** — **Help**, Amethyst's model: the help entry lists the **topics
  of the current page** and plays **simple walkthrough steps** — a spotlight
  overlay highlighting the actual controls (`amethyst/lib/widgets/walkthrough_*`).
- **UIC-NAV-06** — **Colours**, two independent axes:
  - **Theme**: automatic / light / dark (busy's `ThemeChoice`,
    `busy/lib/core/device_profile.dart`);
  - **Vision mode**: default / **Red-Green Safe** / **Tritan Safe** /
    **Grayscale** (Amethyst's palette names; grayscale = its Achromatopsia,
    `amethyst/lib/models/palettes/`).
  Any combination is valid, e.g. dark + Tritan Safe.

## 11. Data prerequisites (UIC-DAT)

The concept needs wiki content and bundle fields that don't exist yet. These are
prerequisites, not UI work; the generation scripts are tracked in
[`../TODO.md`](../TODO.md).

- **UIC-DAT-01** — **Abbreviation entities** (~60), generated from Table 2
  (`wiki/narrative/01-introduction/006-abbreviations.md`) into a new
  `entities/abbreviations/` area with a new ontology type `abbreviation`.
  Duplicates get qualified slugs (`sg-stanley-gibbons` vs the SG coin catalogue);
  the catalogue abbreviations link to their existing `references/catalogues/`
  pages instead of duplicating them.
- **UIC-DAT-02** — **Colour entities** (~22) in the currently empty
  `entities/colors/`, generated from `wiki/narrative/25-colors/`, each with
  `hex`, its Pantone/RAL/AMS codes, and `related:` colour links (UIC-ART-04/05).
  Hex values need a rights-safe source (reviewer research item).
- **UIC-DAT-03** — **Calendar concept pages** (Julian, Gregorian) in
  `entities/concepts/`, already planned by the ontology, backing the `J`/`G`
  links (UIC-ART-03) and the per-year calendar tables of chapter 21.
- **UIC-DAT-04** — A **`summary`** frontmatter field on entity pages for previews
  (UIC-LNK-04).
- **UIC-DAT-05** — **Content bundle extensions** (`wizard/bullwiz/content.py`):
  entity summaries and relations, time/calendar metadata per artefact, the global
  image index numbering, and table cell structure sufficient for selection
  (UIC-TBL-03).

## 12. Out of scope

Store upload automation, iOS (v1.x), downloadable/offline TTS voice management,
and background music. The image-rights gate (content-pipeline.md) is untouched by
this concept: the image index and viewer only ever see cleared images.
