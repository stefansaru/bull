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

| File | Role | Requirements |
|------|------|--------------|
| `lib/main.dart` | Loads preferences and the bundle; shows a "content missing" screen if the bundle was not built | APP-CNT-004 |
| `lib/src/app.dart` | Theme (paper and ink), localisation, TV `select` key, `restorationScopeId` | APP-UX-002, APP-ADP-002 |
| `lib/src/content/book.dart` | Book / Chapter / Section / Unit / Entity model; English fallback (`pick`) | APP-CNT-001, APP-L10N-002 |
| `lib/src/settings.dart` | Persistent state: book language, last section | APP-LIFE-001 |
| `lib/src/ui/scope.dart` | `AppScope` (book + settings), width classes, reading width | APP-ADP-001 |
| `lib/src/ui/home_page.dart` | Shell: bottom bar (compact) or rail (medium/expanded); two panes when expanded; restorable tab and section | APP-ADP-001, APP-LIFE-001 |
| `lib/src/ui/toc.dart` | Contents + "Continue reading" | APP-UX-001 |
| `lib/src/ui/reader_page.dart` | Reader as a page (compact/medium); restorable route | APP-LIFE-001 |
| `lib/src/ui/section_view.dart` | Renders units (text, tables, figures); D-pad scrolling | APP-RDR-001, APP-ADP-002 |
| `lib/src/ui/image_viewer.dart` | Zoom: pinch, or select + arrows on TV | APP-RDR-002 |
| `lib/src/ui/search_page.dart` | In-memory full-text search | APP-SRCH-001 |
| `lib/src/ui/reference_page.dart` | Entity pages by group | APP-CNT-002 |
| `lib/src/ui/settings_page.dart` | Language, privacy notice, about | APP-L10N-002, APP-PRV-001 |
| `lib/l10n/app_*.arb` | UI strings in EN, RO, FR, DE (gen-l10n) | APP-L10N-001 |

## Layout

The layout follows the width class, never the device type:
- **Compact** (< 600 dp): phone portrait.
- **Medium** (600–839 dp): tablet portrait.
- **Expanded** (≥ 840 dp): tablet landscape, TV, and most phones in landscape. It shows the contents and the reader side by side.

## State

| Kind | What | Mechanism |
|------|------|-----------|
| Persistent | book language, last section | `shared_preferences` |
| Restorable (survives process death) | selected tab, selected section, the open reader route | `RestorationMixin`, `restorablePush` |
| Transient | search query, expanded chapters, scroll position | widget state, `PageStorageKey` |

## Android

- `applicationId` / namespace `com.jinisolutions.capdebour`. It is permanent from the first upload.
- The manifest declares a leanback launcher entry and a banner (`res/drawable-xhdpi/tv_banner.png`, a placeholder), and requires neither touchscreen nor leanback.
- No orientation lock.
- Release signing comes from `android/key.properties` (gitignored). A release task without it fails at task-graph time.
- INTERNET is declared only in the debug and profile manifests, which Flutter needs for hot reload. Release builds have none.
