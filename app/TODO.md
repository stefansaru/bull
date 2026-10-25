# TODO — Bull app

**v1 means: on Google Play as a paid app, for Android phones, tablets and TVs.** iOS is v1.x (charter CH-STR-2).

The book's own work list is `../TODO.md`. Requirement IDs refer to [`docs/requirements/`](docs/requirements/Requirements.md).

## Owner rulings

- **2026-10-24**: the app is an interactive digital book, sold **paid upfront** with no ads and no IAP, for Android phone + tablet (portrait and landscape) + Android TV. Code lives in `app/` inside the bull repository. Image rights are a release gate. The wizard goes up to signed bundles; upload stays manual. (Hermes jini-apps-DR-002)
- **2026-10-25**: applicationId `com.jinisolutions.capdebour`. It becomes permanent at the first upload.

## Blocks v1: only the owner can do these

- [ ] **Image rights.** 1,049 referenced images, 0 cleared. Decide per source: own photographs, permission requests, replacement, or omit. See [`docs/content-pipeline.md`](docs/content-pipeline.md#clearing-an-image-step-by-step) (NORM-COPY-01, STRAT-RSK-001, PROC-RGT-001). The book's own TODO (section A, *Q-commercial*) asks the same question; one answer serves both.
- [ ] **Record the source of the 1,049 book images** (`assets/media/`): add `source:` per image in `wiki/assets/rights.yml`, then decide rights per source with `rights_default:` (bull DR-014). The wizard report counts images per source.
- [ ] **Price** (STRAT-MKT-001).
- [ ] **Play Console**: payments profile, paid app, content rating, data safety ("no data"), TV opt-in (NORM-GPDP-01, NORM-GPTV-01).
- [ ] **Privacy policy page** published at `https://jini.solutions/bull/privacy` (APP-PRV-001). The shared Jini Solutions site should become a catalogue (cross-app item in Amethyst's TODO).
- [ ] **Upload key**: reuse `upload-keystore.jks` or create one; fill in `android/key.properties`; record the backup location (H-APP-SEC-001).
- [ ] **Title and front matter** of the app edition. This follows the book's front-matter decision (book TODO §A).
- [ ] **Tax and Framework subscription** for income from a paid app as a natural person. This is a Hermes `jini-apps` decision and must come before the first paid release.

## UI concept (docs/ui-concept.md, accepted — bull DR-015)

The target UI is specified in [`docs/ui-concept.md`](docs/ui-concept.md); IDs below refer to it. Two reviews ran 2026-10-25 (findings files next to the concept); DR-015 records the rulings: frozen-column tables, hybrid previews, best-effort TTS, `1 (13) June 1865 ᴶ⁄ᴳ` dates.

- [x] Run the review; owner accepted findings; DR-015 recorded (2026-10-25).
- [x] Navigation stack: restorable, with scroll offsets and anchors; Back closes overlays first (UIC-PRN-01). Focus restoration on Back is Flutter's default; pane context is per-layout.
- [x] Artefact page chrome: top menu, breadcrumb, date line (year links to its calendar), title (UIC-NAV-01, UIC-ART-02..06).
- [x] Sections window: TOC + Indexes + Favorites + Recently visited (UIC-NAV-01a).
- [x] Dotted-underline links with TalkBack link semantics; hybrid previews; remote: focusable paragraphs, Select previews or offers a choice (UIC-LNK-01..04).
- [x] Image viewer: pinch zoom, swipe prev/next, stable `imageId` + display numbers, two D-pad modes, zoom/fit/prev/next/bookmark bar (UIC-IMG-01..05). Widget test waits for the first cleared image.
- [x] Table viewer: frozen first column, horizontal scroll, full screen with sticky header rows; keyboard-first selection (Select–extend–Select, header → column, first column → row, Back clears); touch taps and long-press drag; selections bookmarked by stable row/column ids (UIC-TBL-01..04).
- [x] Favorites: star, passage (long-press, or Select on a remote; TalkBack custom action), table-selection and image bookmarks; tree; deletes; Recently visited; Continue reading only on linear reading (UIC-FAV-01..06).
- [x] Search: sections and entities; filter subwindow with count and chips (UIC-SRC-01..03).
- [x] Landscape rail + title button (hidden by default), breadcrumb always visible, Sections pane when ≥ 900 dp (UIC-LAY-02..04).
- [x] Platform detection (phone / tablet / TV / other → TV) via the `capdebour/device` channel; Day OK's `TvKeyboard` ported; keyboard button on unknown devices; 10-foot type ×1.6 and 5 % / 3 % overscan margins on TV-like devices (UIC-PLT-01..04).
- [ ] Validate the 10-foot scale and the remote paths on a real Android TV / Google TV device (and an emulator pass), then tune `tenFootTextScale`.
- [ ] UI sound effects: the Audio switch exists (default on) but no sounds are designed or played yet (UIC-NAV-03).
- [x] More menu: read aloud (flutter_tts behind `SpeechService`, offline voices preferred, no-voice explanation, never cloud), audio, language + country with reorder, help (first-run tour + topics), theme × vision mode (UIC-NAV-02..06). Verify TTS voices on real hardware (phone, TV).
- [x] Wiki content (UIC-DAT-01..05), 2026-10-25: 60 abbreviation pages + index (`tools/gen_abbreviations.py`), 22 colour pages with the author's swatch hex (`tools/extract_swatches.py`, `tools/gen_colors.py`), Julian/Gregorian/dual-date concept pages, bundle schema 2 (links, curated auto-links, DR-015 date notation, summaries, stable IDs, image index, indexes).
- [ ] `summary:` fields written by hand for the most-visited entities (the first-paragraph fallback covers the rest).
- [ ] Adopt reviewer B's 13 acceptance tests (its "Suggested acceptance tests") as the feature-level test checklist.

## Product work

- [ ] Links from narrative text to entity pages (APP-CNT-002).
- [ ] 10-foot type scale on TV; manual D-pad pass on an Android TV emulator (APP-ADP-002).
- [ ] Designed launcher icon and TV banner (the current ones are the Flutter default and a placeholder) (APP-UX-002, NORM-GPTV-01).
- [ ] Reading typeface decision; optional in-app text size control (APP-UX-002).
- [ ] Widget test for the image viewer, once the first cleared image exists (APP-RDR-002).
- [ ] Accessibility guideline tests on the reader and settings screens; a TalkBack pass (APP-ACC-001).
- [ ] Startup time measured on the reference device (H-APP-QAL-002); crash-free target set (H-APP-QAL-001).
- [ ] If the cleared images push the bundle past 150 MB, move `img/` to a Play Asset Delivery pack, as Amethyst does (`wizard/config.yaml` → `bundle_size_limit_mb`).
- [ ] Hand-over of translations: RO, FR and DE ship automatically once their coverage reaches 98 %. The work is in the wiki sidecars, not here.

## Tooling

- [ ] A tree check: requirement ID uniqueness, index links, Hermes baseline coverage (H-PROC-REPO-003).
- [ ] Git tag and push automation in the wizard's release mode, after a successful build (PROC-REL-001).
- [ ] CI workflow (GitHub Actions) running `doctor --gates-only`, `flutter analyze`, `flutter test` and `pytest`.

## v1.x — iOS

- [ ] `flutter create --platforms ios .`, bundle id `com.jinisolutions.capdebour`, Apple Developer enrolment (natural person), App Store listing (CH-STR-2, CH-GOAL-4).

## Cross-app entries (H-PROC-REPO-006)

- **2026-10-24, from Hermes DR-026 / jini-apps-DR-001**: this app was built to the repository standard from day one. Patterns worth copying to Amethyst: the single-implementation doctor (`doctor.py`) behind the sh and ps1 wrappers, and `--fix`. That entry is already in Amethyst's TODO.
