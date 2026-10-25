# UI concept — the artefact browser

**Status: accepted** (2026-10-25, bull DR-015), revised after two independent
reviews — [reviewer A](ui-concept-review-findings-gemini.md) and
[reviewer B](ui-concept-review-findings-chatgpt.md), both answering
[`ui-concept-review.md`](ui-concept-review.md). The owner rulings from the review
round: hybrid previews (UIC-LNK-02), frozen-column tables instead of rotation
(UIC-TBL-02), best-effort TTS with graceful fallback (UIC-NAV-03), and the
`1 (13) June 1865 ᴶ⁄ᴳ` date notation (UIC-ART-03). Implementation work is tracked
in [`../TODO.md`](../TODO.md).

Each feature carries a stable ID (`UIC-…`) so requirements, TODO entries and
reviews can cite it. Changing an ID means changing every citation; don't.

## 1. Purpose and principles (UIC-PRN)

The app is a tool for **learning about the 1858 Bull's Head stamps**: an interactive
book one can read linearly *and* wander through by following any term that catches
the eye. Charter values apply (jini-apps CH-VAL): the UI is simple, minimalistic and
a joy to use.

- **UIC-PRN-01** — Everything the text refers to is reachable in place: tap it,
  learn what it is, go deeper if you want, come back without losing your spot.
  "Your spot" is a typed navigation stack entry — artefact, content-unit anchor,
  scroll offset, focused element and pane context — not a raw pixel offset, so it
  survives rotation and reflow. Back closes the innermost overlay first, then
  restores the origin and its focus.
- **UIC-PRN-02** — One uniform page model (the *artefact*, §2) rather than
  per-type screens. Specialized elements (the image viewer, the table viewer)
  live *inside* that model: they share its metadata, navigation and bookmarking
  while keeping their own interactions.
- **UIC-PRN-03** — Chrome stays out of the way: few icons, no text labels in the
  top menu, vertical space is spent on content (§8 hides even the title in
  landscape).
- **UIC-PRN-04** — Every control is reachable by touch **and** by D-pad (§9),
  and carries proper semantics (roles, names, states) for TalkBack.

## 2. The artefact model (UIC-ART)

- **UIC-ART-01** — An **artefact** is any page of the book's content: a narrative
  section, an entity (issue, denomination, colour, abbreviation, handstamp, place,
  person, reference, concept, event), or an image (via the image index, §4). All
  artefacts share the same page anatomy and all can be added to favorites.
- **UIC-ART-02** — Page anatomy, portrait, top to bottom:
  1. the **top menu** (UIC-NAV-01);
  2. a slim **breadcrumb** — Chapter › Section › Artefact (UIC-ART-06);
  3. the **date line** (UIC-ART-03), when the artefact has one;
  4. the **title**, on its own line;
  5. the **body** — text, images, tables;
  6. a **Related artefacts** list (UIC-ART-05).
- **UIC-ART-03** — The **date line** shows the artefact's date or time range.
  Dual Julian/Gregorian dates are written **source calendar first (Julian for
  this material), Gregorian in parentheses, with one small tappable ᴶ⁄ᴳ tag**
  saying which is which (owner ruling, DR-015):
  - same month: `1 (13) June 1865 ᴶ⁄ᴳ`
  - different months: `24 January (5 February) 1859 ᴶ⁄ᴳ`
  - different years: `25 December 1865 (6 January 1866) ᴶ⁄ᴳ`
  - year ranges make no calendar claim and stay plain: `1858–1862`
  The ᴶ⁄ᴳ tag is a link (UIC-LNK): its preview explains the notation, More opens
  the calendar artefact. Stored data keeps the source date, source calendar,
  precision and conversion provenance; a date is never silently assumed
  Gregorian. Date tokens get adequate touch/focus targets — never a bare
  one-letter hit area. This resolves the wiki's open convention question under
  C-04.
- **UIC-ART-04** — Artefacts without a time dimension **omit the date line**
  entirely; the title moves up. Colours are the canonical example: *Carmine red*
  shows the colour itself (a swatch), its approximate hex, and the standardized
  colours that match it (Pantone 1807, RAL 3002, AMS 11136) — see UIC-DAT-02 for
  what "approximate" means.
- **UIC-ART-05** — Each artefact ends with **Related artefacts**: typed, curated
  relations from frontmatter, each shown with a short relation label ("printed
  in", "belongs to issue", "other reds") rather than a flat list. Each entry
  opens directly (UIC-LNK-02 — these are deliberate navigation).
- **UIC-ART-06** — The **breadcrumb** keeps the reader located while wandering:
  Chapter › Section › Artefact, each segment a direct link. It stays visible on
  TV and in landscape even when the title is hidden (UIC-LAY-03), so the page's
  identity is never lost.

## 3. Links and previews (UIC-LNK)

- **UIC-LNK-01** — Every reference to another artefact is clickable, styled with a
  **thin dotted underline** — deliberately more discreet than a conventional
  hyperlink, so dense pages stay calm. The underline is the *visual* marker; each
  link also registers as a link in the semantics tree with a meaningful name, so
  TalkBack users can list and activate them without relying on the visual cue.
  Touch targets get padding; a single letter like the ᴶ⁄ᴳ tag is never the whole
  hit area.
- **UIC-LNK-02** — **Hybrid preview rule** (owner ruling, DR-015). Links in
  **narrative prose** open a **preview popup** first — a brief description and a
  **More** button — because mid-reading taps are exploratory; dismissing it (tap
  outside, Back) loses nothing. Links that are already **deliberate navigation**
  open their target **directly**: entries in indexes, search results, Related
  lists, bookmarks and favorites, and the TOC. Commands (enlarge an image, resume
  reading, prev/next) are not links and never preview. On TV, Select on a focused
  prose link opens the preview with initial focus on **More**; Back closes only
  the preview and returns focus to the link.
- **UIC-LNK-03** — **More** opens the artefact's own page. Example: the preview on
  the `J` of a date explains the abbreviation in a sentence; More opens the
  *J — Julian calendar* artefact, which carries the full description, a list of
  **all abbreviations beginning with J**, and a link to the **index of all
  abbreviations**. The same pattern applies to every abbreviation. The indexes
  themselves are also reachable without any link, from Sections (UIC-NAV-01a).
- **UIC-LNK-04** — The preview text comes from the artefact's `summary` frontmatter
  field, falling back to its first paragraph. (Data prerequisite, §11.) TalkBack
  hears "Preview: ⟨title⟩", the summary, More, Close.

## 4. Images (UIC-IMG)

- **UIC-IMG-01** — Every image in the book appears in one global, ordered **image
  index** — itself a browsable artefact, reachable from Sections (UIC-NAV-01a).
  Readers see sequential **display numbers**; internally every image keeps a
  stable `imageId`, and bookmarks store the ID, never the number, so inserting an
  image later shifts no one's bookmarks.
- **UIC-IMG-02** — Any image that can be enlarged is enlarged by tapping it, into
  the full-screen viewer (a command, not a preview — UIC-LNK-02).
- **UIC-IMG-03** — The viewer supports **finger zoom**: pinch out to zoom in,
  pinch in to zoom out, drag to pan. Zoom range is clamped; Fit/Reset is always
  one action away.
- **UIC-IMG-04** — While the image fits the screen (not zoomed in), **swiping
  left/right moves to the next/previous image** in the index. Zoomed in, the same
  gestures pan.
- **UIC-IMG-05** — The viewer's top menu: **Back · zoom in (magnifier +) ·
  zoom out (magnifier −) · previous · next**. Previous/next step the image index
  down/up by one. On TV the viewer has **two explicit D-pad modes** (review
  finding): *fitted* — Left/Right are previous/next, Up reaches the control bar;
  *zoomed* — the image canvas takes focus and arrows **pan** by a fixed visible
  fraction, Select returns to the control bar, Back leaves pan mode before it
  closes the viewer. Pan and prev/next never compete for the same key. The
  buttons fully substitute every gesture — pinch has no monopoly on zoom.

## 5. Tables (UIC-TBL)

- **UIC-TBL-01** — Tables render in a dedicated **table viewer** element, shared
  by every table in the book.
- **UIC-TBL-02** — A table wider than the screen stays **upright** and scrolls
  **horizontally with the first column and the header row frozen** (anchored),
  plus a **full-screen table mode** that gives it the whole display (owner
  ruling, DR-015 — the earlier rotate-90° idea is dropped; both reviewers showed
  it breaks D-pad directions and screen-reader order). A labelled **transpose**
  option may be added later for rectangular matrices where it genuinely helps;
  it is not part of the default viewer.
- **UIC-TBL-03** — The viewer supports **selection**, keyboard-first (review
  finding): arrows move the focused cell; **Select anchors** the start of a
  selection, arrows extend it, **Select confirms**; Back cancels the selection
  before it closes anything. Select on a row or column header selects the whole
  row or column. On touch, tap headers and drag across cells do the same.
  TalkBack announces row heading, column heading, value and selected state.
- **UIC-TBL-04** — A selection can be **bookmarked** (UIC-FAV-03) through an
  explicit *Bookmark selection* action. Selections are stored as stable row and
  column IDs, not raw coordinates, so they survive content reflow; opening the
  bookmark re-opens the table with the same selection highlighted.

## 6. Favorites and bookmarks (UIC-FAV)

- **UIC-FAV-01** — The **star** in the top menu is a pure **toggle**: it marks or
  unmarks the current artefact as a favorite. The **favorites window** is a
  separate destination, reachable from Sections (UIC-NAV-01a) and from the
  three-dots menu — never hidden behind the toggle (review blocker).
- **UIC-FAV-02** — The favorites window lists entries grouped by artefact. An
  artefact with several bookmarks shows as an **expandable tree node**: the page
  on the branch, its bookmarks as leaves. On TV, expand/collapse and child focus
  are explicit D-pad actions.
- **UIC-FAV-03** — Bookmark kinds: the **artefact** itself; a **table selection**
  (UIC-TBL-04); an **image** (by stable `imageId`, from the viewer); a **text
  passage** (long-press a paragraph on touch; on TV, Select on a focused
  paragraph offers *Bookmark passage*). Every bookmark anchors to stable unit
  IDs and reopens its artefact at exactly that spot — and survives process
  death, content-bundle reordering and language switches.
- **UIC-FAV-04** — The current **reading position** is kept automatically and
  shown at the top of the favorites window as "Continue reading" (today's
  `lastSection`, generalized). It moves only on **intentional linear reading**:
  wandering through previews and linked entities never drags it along (review
  finding). A separate, modest **Recently visited** trail lists the artefacts
  explored, so a learner can retrace a wander.
- **UIC-FAV-05** — Deleting: a single bookmark, **all bookmarks of one artefact**,
  or **all bookmarks**. The two bulk actions confirm first.
- **UIC-FAV-06** — The favorites window has its own **search field**: it is the
  global search (§7) with the *favorites-only* filter pre-applied.

## 7. Search (UIC-SRC)

- **UIC-SRC-01** — The search window: **Back** on top, the query field, a
  **filter button showing the number of applied filters** (e.g. `Filters (2)`),
  and the list of matches. Applied filters also show as chips above the results,
  each removable, with a one-action Clear.
- **UIC-SRC-02** — The filter opens as a **subwindow** of its own (a sheet/panel;
  on TV one focus region, not another modal layer). The filter set is fixed at
  three (owner ruling via both reviewers): **artefact type**, **chapter**,
  **favorites only**. **No language filter** — search works on the active
  language. Nothing is added until real usage shows a retrieval problem.
- **UIC-SRC-03** — One search serves the whole app; entry points differ only in
  pre-applied filters (UIC-FAV-06).

## 8. Orientation and layout (UIC-LAY)

- **UIC-LAY-01** — The app is optimized for **portrait and landscape** and
  switches seamlessly: scroll position, open artefact, selections and popups all
  survive rotation (Flutter restoration IDs, as already implemented, plus the
  semantic anchors of UIC-PRN-01).
- **UIC-LAY-02** — In **landscape**, the title and top menu move to the **left
  side** (a rail); the menu buttons keep their order and relative places (back at
  the top, three-dots at the bottom of the rail).
- **UIC-LAY-03** — In landscape a dedicated **title button** appears — it exists
  *only* in landscape. The title and date line are **hidden by default** to give
  the saved vertical space to content; pressing the button shows them, pressing
  again or tapping away hides them. The slim breadcrumb (UIC-ART-06) stays
  visible, so hiding the title never hides *where you are* (review finding). In
  two-pane layouts the flyout opens over the rail side and never covers the
  second pane's content.
- **UIC-LAY-04** — Width classes stay as implemented (`scope.dart`): compact
  < 600 dp, medium 600–839, expanded ≥ 840; expanded shows two panes. Pane
  ownership: the TOC/list pane stays put; previews and More open in the content
  pane; Back walks the content pane's stack before it collapses panes. On TV,
  Left/Right cross the pane boundary at a documented focus edge.

## 9. Platforms and input (UIC-PLT)

- **UIC-PLT-01** — The app detects its platform: **Phone, Tablet, TV, or other —
  and *other* is treated as TV** (the safe default: everything reachable without
  touch). Detection follows busy's pattern: TV when Android reports
  `UI_MODE_TYPE_TELEVISION` or `FEATURE_LEANBACK` (platform channel,
  `busy/android/.../MainActivity.kt`); otherwise tablet when the shortest display
  side is ≥ 600 dp (`busy/lib/core/layout_mode.dart`), else phone. Affordances
  additionally follow *capabilities* where detectable (touch present, pointer
  present), so "treated as TV" widens input options rather than removing any.
- **UIC-PLT-02** — On TV, text entry uses the **same in-app keyboard element as
  the busy (Day OK) app**: `TvKeyboard` (`busy/lib/widgets/keyboard.dart`) — a
  D-pad-driven on-screen keyboard with text and digits layouts, Romanian
  diacritics, and a single-focus-node grid. Rationale inherited from busy
  REQ-LAY-064: Google TV remotes don't reliably reach the system keyboard.
- **UIC-PLT-03** — When the platform **cannot be determined**, a labelled
  **keyboard button** appears next to text fields to open the in-app keyboard
  explicitly; a working system keyboard is never suppressed.
- **UIC-PLT-04** — Every interactive element — links, previews, image viewer
  controls, table selection, favorites tree — is operable by D-pad alone, with a
  clearly visible focus state and a predictable focus order (the existing TV
  remote-only test grows with each feature). TV typography follows a dedicated
  10-foot scale; reviewer B's token table (body ≈ 26 sp, titles ≈ 34 sp, ~60
  characters per line, overscan-safe insets) is the starting point to validate
  on real hardware.

## 10. Navigation chrome and the three-dots menu (UIC-NAV)

- **UIC-NAV-01** — The top menu, left to right:
  1. **Back** (top left);
  2. **Sections** — three horizontal lines, each preceded by a dot, so the icon
     reads as a bullet list (Material's standard `toc` glyph is exactly this —
     both reviewers endorse it over a plain hamburger); semantic label
     "Contents";
  3. **Star** — favorite toggle (UIC-FAV-01);
  4. **Search** — magnifying glass (§7);
  5. **Three-dots** (top right) — the menu below.
- **UIC-NAV-01a** — The **Sections window** holds more than the TOC (review
  blocker — everything must have an entry point): the table of contents on top,
  then an **Indexes** group — **Images** (UIC-IMG-01), **Abbreviations**,
  **Colours**, **Calendars** — and a **Favorites** entry (UIC-FAV-01). Index
  pages are ordinary artefacts: searchable, linkable, favoritable.
- **UIC-NAV-02** — The three-dots menu on an artefact page opens a menu window
  with entries, each a **subwindow** of its own:
  - **Audio** (UIC-NAV-03)
  - **Language** (UIC-NAV-04)
  - **Help** (UIC-NAV-05)
  - **Colours** (UIC-NAV-06)
  - **Favorites** (UIC-FAV-01)
  - **Privacy policy** (link; APP-PRV-001)
  Each subwindow opens and closes in one step — no nested stacks of windows.
- **UIC-NAV-03** — **Audio**, modelled on Amethyst's audio window
  (`amethyst/lib/widgets/audio_window.dart`): a sound-effects switch (UI feedback
  sounds), and **text-to-speech** — a "read this page aloud" control with
  play/stop and paragraph stepping, plus voice and rate settings. **TTS ships in
  v1 as best effort with a graceful fallback** (owner ruling, DR-015): the app
  uses the device's installed voices through `flutter_tts` behind an app-owned
  `SpeechService`, **prefers offline voices and never sends text to a cloud
  service** (the no-tracking promise); where the active language has no voice,
  the control says so — "Read aloud is unavailable for ⟨language⟩ on this
  device" — and offers setup guidance, never a wrong-language substitute.
  Reading order: date line, title, body units in order, image captions; the
  spoken unit is highlighted, and position survives rotation.
- **UIC-NAV-04** — **Language**, same as Amethyst
  (`amethyst/lib/widgets/language_reorder_window.dart`): one row per language —
  code, name, flag, country (`EN · English · 🇺🇸 · USA`), tap to apply, drag
  (or D-pad Move Up/Down) to reorder the display order. Languages: EN always;
  RO/FR/DE as they reach coverage (content-pipeline rules unchanged).
- **UIC-NAV-05** — **Help**, Amethyst's model: the help entry lists the **topics
  of the current page** and plays **simple walkthrough steps** — a spotlight
  overlay highlighting the actual controls (`amethyst/lib/widgets/walkthrough_*`).
  Proportionality (review finding): one short first-run tour covers the global
  chrome; per-page topics exist only where a page has something of its own (the
  table viewer, the image viewer), not as boilerplate on every page.
- **UIC-NAV-06** — **Colours**, two independent axes:
  - **Theme**: automatic / light / dark (busy's `ThemeChoice`,
    `busy/lib/core/device_profile.dart`);
  - **Vision mode**: default / **Red-Green Safe** / **Tritan Safe** /
    **Grayscale** (Amethyst's palette names; grayscale = its Achromatopsia,
    `amethyst/lib/models/palettes/`).
  Any combination is valid, e.g. dark + Tritan Safe. **Vision modes recolour the
  UI chrome only — never stamp photographs or colour swatches** (review
  finding): the evidence a philatelist studies keeps its original pixels, in a
  neutral frame, with its text identifiers alongside.

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
  `entities/colors/`, generated from `wiki/narrative/25-colors/`, each with the
  **standard's code as the authoritative value** (Pantone/RAL/AMS) and an
  **independently derived sRGB hex labelled as a screen approximation** — not
  copied from a proprietary swatch library (review finding: public availability
  of a conversion table is not a reuse licence). Each swatch records its
  derivation method and provenance. `related:` links connect colour families
  (UIC-ART-04/05).
- **UIC-DAT-03** — **Calendar concept pages** (Julian, Gregorian) in
  `entities/concepts/`, already planned by the ontology, backing the ᴶ⁄ᴳ tag
  (UIC-ART-03) and the per-year calendar tables of chapter 21.
- **UIC-DAT-04** — A **`summary`** frontmatter field on entity pages for previews
  (UIC-LNK-04).
- **UIC-DAT-05** — **Content bundle extensions** (`wizard/bullwiz/content.py`):
  entity summaries and relations (with relation labels), source-calendar date
  metadata per artefact, **stable IDs** for images, table rows/columns and text
  units (the bookmark anchors of UIC-FAV-03), and the generated display
  numbering of the image index.

## 12. Out of scope

Store upload automation, iOS (v1.x), downloadable/offline TTS voice management,
background music, and the rotate-90°/transpose table views (dropped and deferred
respectively, DR-015). The image-rights gate (content-pipeline.md) is untouched
by this concept: the image index and viewer only ever see cleared images.
