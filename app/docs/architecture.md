# Architecture

```
bull/wiki/ (source of truth)          bull/app/
  narrative/**.md + .i18n.yml  ──┐      wizard/ (Python)  ── content.py → validate.py → rights.py → bundle.py
  entities/**.md               ──┼──►     │                   writes assets/content/{content.json, img/*.webp}
  assets/media|sources/*       ──┤        └─ pipeline.py → flutter pub get / analyze / test → build appbundle
  assets/rights.yml            ──┘      lib/ (Flutter)    ── loads assets/content/content.json at start
```

## Two halves

1. **The wizard** (`wizard/`, Python 3.12+) compiles the wiki into a bundle and drives the build. It never edits the wiki, except to add `pending` entries to `wiki/assets/rights.yml` when asked (`--rights-init`). See [wizard.md](wizard.md).
2. **The app** (`lib/`, Flutter, Android) reads the bundle and renders it. It has no network access, no accounts and no analytics.

## Flutter code map

The UI follows [ui-concept.md](ui-concept.md) (bull DR-015); `UIC-` IDs refer to it.

| File | Role | Requirements |
|------|------|--------------|
| `lib/main.dart` | Loads preferences and the bundle; shows a "content missing" screen if the bundle was not built or has another schema | APP-CNT-004 |
| `lib/src/app.dart` | Localisation, TV `select` key, `restorationScopeId`, theme mode; owns the read-aloud session | APP-UX-002, APP-ADP-002 |
| `lib/src/theme.dart` | Theme × vision mode (standard, Red-Green Safe, Tritan Safe, Grayscale) | UIC-NAV-06 |
| `lib/src/content/book.dart` | Schema-2 model: every page is an `Artefact` (Section, Entity, BookImage, IndexInfo); lookup by id | APP-CNT-001, UIC-ART-01 |
| `lib/src/content/inline.dart` | `⟦id\|label⟧` link markup: spans, plain text, targets | UIC-LNK-01 |
| `lib/src/settings.dart` | Persistent state: language and its order, theme, vision, sound, speech rate, Continue reading, recents, bookmarks, tour seen | APP-LIFE-001, UIC-FAV |
| `lib/src/nav/nav_stack.dart` | Restorable navigation stack (artefact, scroll offset, anchor) | UIC-PRN-01, H-APP-LIFE-004 |
| `lib/src/ui/scope.dart` | `AppScope`, layout modes (portrait / rail / rail + pane), `Reader` actions | UIC-LAY |
| `lib/src/ui/shell.dart` | The shell: top menu or rail with the same five controls, title button in landscape, Sections pane when wide | UIC-NAV-01, UIC-LAY-02..04 |
| `lib/src/ui/artefact_view.dart` | One artefact page: breadcrumb, date line, title, units, colour/abbreviation/index blocks, Related, previous/next | UIC-ART-02..06 |
| `lib/src/ui/inline_text.dart` | Dotted-underline links; focusable reading paragraphs for the D-pad | UIC-LNK-01/02, UIC-PLT-04 |
| `lib/src/ui/preview.dart` | The preview popup (summary + More) | UIC-LNK-02..04 |
| `lib/src/ui/sections_panel.dart` | Contents, Indexes, Favorites, Recently visited | UIC-NAV-01a |
| `lib/src/ui/search_page.dart` | One search; filter subwindow (type, chapter, favorites only) with a count | UIC-SRC |
| `lib/src/ui/favorites_page.dart` | Favorites tree, bookmark deletes | UIC-FAV |
| `lib/src/ui/menu.dart` | More menu: audio, language + country, help, colours, privacy | UIC-NAV-02..06 |
| `lib/src/ui/tour.dart` | First-run spotlight tour of the controls | UIC-NAV-05 |
| `lib/src/ui/image_viewer.dart` | Numbered image viewer: pinch, swipe, zoom buttons, two remote modes, image bookmarks | UIC-IMG |
| `lib/src/speech/` + `ui/speech_controls.dart` | Read aloud through the device's TTS (offline voices preferred, never cloud), reading bar | UIC-NAV-03 |
| `lib/l10n/app_*.arb` | UI strings in EN, RO, FR, DE (gen-l10n) | APP-L10N-001 |

## Layout

The layout follows the window, never the device type (`layoutModeOf`):
- **Portrait** (height ≥ width): top menu; date line and title on the page.
- **Rail** (landscape, < 900 dp): the controls on a left rail; title behind the title button.
- **Rail + pane** (landscape, ≥ 900 dp: tablet landscape, TV): the Sections pane beside the page; the Sections button hides and shows it.

## State

| Kind | What | Mechanism |
|------|------|-----------|
| Persistent | language and order, theme, vision mode, sound, speech rate, Continue reading, recently visited, favorites and bookmarks, tour seen | `shared_preferences` (`Settings`) |
| Restorable (survives process death) | the navigation stack: artefacts visited, scroll offsets, anchors | `RestorableNavStack` in the shell |
| Session | read-aloud position | `ReadAloud`, above the shell (survives rotation) |
| Transient | search query and filters, expanded chapters, title flyout, Sections pane | widget state |

## Android

- `applicationId` / namespace `com.jinisolutions.capdebour`. It is permanent from the first upload.
- The manifest declares a leanback launcher entry and a banner (`res/drawable-xhdpi/tv_banner.png`, a placeholder), and requires neither touchscreen nor leanback.
- No orientation lock.
- `<queries>` declares the TTS service (read aloud) and https VIEW (privacy policy link) for Android 11+ package visibility.
- Release signing comes from `android/key.properties` (gitignored). A release task without it fails at task-graph time.
- INTERNET is declared only in the debug and profile manifests, which Flutter needs for hot reload. Release builds have none.
