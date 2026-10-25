# UI concept review findings — reviewer B (ChatGPT)

Received 2026-10-25, pasted verbatim by the owner. Responds to
[`ui-concept-review.md`](ui-concept-review.md); reviews
[`ui-concept.md`](ui-concept.md) as proposed on 2026-10-25. This reviewer worked
from the two documents only, without repository access (see its own scope note).
Disposition of the findings: bull DR-015.

---

# Bull Heads — UI concept review findings

**Review date:** 2026-10-25
**Status:** Independent review, proposed findings and draft decisions; not an acceptance decision.
**Inputs:** `ui-concept.md` (proposed 2026-10-25), `ui-concept-review.md` (review brief).
**Output:** This document only. Neither input file was modified.

## Review scope and evidence limits

The brief calls for review of `README.md`, `architecture.md`, `requirements/Requirements.md`, `wiki/meta/ontology.md`, `wiki/meta/conventions.md`, `../TODO.md` (including fixed **Owner rulings**), the Hermes baselines, current Flutter UI source, and widget tests. **None of those additional repository files or the runnable application were supplied or accessible in this review environment.** Findings below are a design/document consistency review of the two attached files, supplemented by cited public sources. They are **not** code-audit findings, tests of a running app, a complete requirement trace, confirmation of the existing implementation, or a substitute for an owner-rulings check. Existing charter/owner decisions must prevail over proposed alternatives here.

**Severity definitions:** `blocker` = a key flow or mandatory platform promise cannot be specified/tested reliably as written; `should-fix` = appreciable usability/accessibility/maintenance risk; `note` = clarification or optional enhancement. `UIC-*` IDs are retained exactly as written.

## Executive assessment

**Conditional recommendation: retain the single artefact model, but do not accept the proposed interaction contract unchanged.** The unified content model, locally reversible navigation, reuse of image/table elements, and device-wide D-pad intent are strong. The principal gaps are navigation reachability, semantics of preview-first links, full TV image navigation, table selection, reading-history restoration and the availability guarantee implied by v1 TTS. Accessibility and adaptivity compliance cannot be certified from a design description alone.

### Decision queue, in recommended priority order

| Priority | Severity | Owner decision / required specification | IDs |
|---|---|---|---|
| P0 | blocker | Define global routes and exact star/favorites actions; ensure all indexes have a reachable entry point | UIC-NAV-01, UIC-FAV-01, UIC-IMG-01, UIC-LNK-03 |
| P0 | blocker | Specify D-pad panning at image zoom, table cell/range selection and popup focus/Back behaviour | UIC-IMG-03/05, UIC-TBL-03, UIC-LNK-02, UIC-PLT-04 |
| P0 | blocker | Reconcile all-language v1 TTS with devices that have no suitable installed voice | UIC-NAV-03, UIC-PLT-01 |
| P1 | should-fix | Replace 90° table rotation as the primary width remedy; keep semantic row/column relationships | UIC-TBL-02/03 |
| P1 | should-fix | Decide how previews can be bypassed for direct navigation; do not insert a forced dialog on every link | UIC-LNK-02/03 |
| P1 | should-fix | Document canonical navigation/restore/reading-history model and durable bookmark anchors | UIC-FAV-03/04, UIC-LAY-01, UIC-DAT-05 |
| P1 | should-fix | Distinguish historical source dates from converted dates, and choose readable dual-date notation | UIC-ART-03 |
| P1 | should-fix | Ensure link discoverability, adaptive text, native semantics and focused-control visibility | UIC-LNK-01, UIC-PRN-04, UIC-LAY-03 |

---

## Review task 1 — Coherence

**1.1 — [blocker] Star action is overloaded / favorites navigation is missing** (`UIC-FAV-01`, `UIC-NAV-01`, `UIC-FAV-06`). The star is defined as a *toggle*, but the same clause says there is a favorites window. The top menu specifies no separate favorites entry and no procedure to reach that window. Searching with a favorites-only filter is not a substitute for finding saved passages and table selections. **Fix:** keep the star as a per-page toggle; give the favorites library a named, reachable action in Sections or the overflow menu (and an equivalent landscape-rail route). Specify how its tree, bookmarks, search and Continue Reading are reached from any artefact and returned from. If owner policy precludes another top-level item, prefer an overflow/Sections entry rather than another permanent icon.

**1.2 — [blocker] Indexes are described but not entered** (`UIC-IMG-01`, `UIC-LNK-03`, `UIC-DAT-01/03`, `UIC-NAV-01`). The global image index has no named top-level route. The abbreviations index is only reached by traversing an abbreviation entry; there is no stated way to arrive there directly. A year link promises calendar tables, but no index or handling for a missing year is described. **Fix:** add a consistent *Indexes* subsection within Sections: Images, Abbreviations/Glossary, Colours, Calendars. Make index pages searchable artefacts with stable IDs and allow them as Related links.

**1.3 — [should-fix] Universal preview rule conflicts with useful direct actions** (`UIC-LNK-02`, `UIC-IMG-02`, `UIC-FAV-03`, `UIC-ART-03`). "All links" must open a preview, yet tapping an enlargable image must open the viewer, a bookmark must reopen an exact selection, and tapping a date's year says it opens a calendar table. These do not need to conflict if the concepts are defined. **Fix:** distinguish *semantic content links* (preview-capable) from *commands* (enlarge, resume, open bookmark, switch image, Back). Specify which content links can go directly to an artefact and whether dates use the same preview affordance.

**1.4 — [should-fix] Image is both a page type and a viewer item without identity rules** (`UIC-ART-01`, `UIC-IMG-01/05`, `UIC-FAV-03`, `UIC-DAT-05`). Numbering images sequentially is useful to readers but not a safe bookmark key: inserting a new image can shift every later number. **Fix:** store immutable `imageId` and `artefactId`, with a separately generated display `imageNumber`; save bookmarks by stable ID. Specify whether selecting an image-index entry opens the image artefact or the full-screen viewer, and Back destination.

**1.5 — [should-fix] Navigation return state has no shared contract** (`UIC-PRN-01`, `UIC-LNK-02/03`, `UIC-FAV-04`, `UIC-LAY-01/03`). "Come back without losing your spot" mentions scroll, but not the focused inline link, its nearby passage, preview state, viewer scale, current TTS unit, or side-pane selection. **Fix:** one typed navigation stack with `artefactId`, content-unit anchor, scroll offset, focused element, pane context and opening source. On Back, close the innermost overlay first, then restore origin and focus. After rotation, retain the semantic anchor rather than raw pixel offset alone.

**1.6 — [should-fix] Two-pane landscape needs a defined ownership model** (`UIC-LAY-02/03/04`). An expanded screen shows two panes; the title/date move to a left rail and are hidden by default. What happens when one pane opens a linked artefact, how Back works, and where the title flyout appears are unstated. **Fix:** distinguish *navigation rail* (persistent controls) from *content panes*. Define which pane updates on preview/More and the exact point at which compact landscape still uses one pane. Avoid overlaying a second pane with a long title flyout.

**1.7 — [note] Uniform page model is sound if specialized elements stay inside it** (`UIC-PRN-02`, `UIC-TBL-01`, `UIC-IMG-02`). "One artefact" need not mean every item uses identical interactions. Define shared metadata, navigation and bookmarking, while allowing the image viewer and table viewport to be specialized content elements.

## Review task 2 — Simplicity

**2.1 — [should-fix] Universal preview-first is too costly for routine reading** (`UIC-LNK-02/03`). Readers seeking a cited topic may need two activations where one would do; on TV, every preview adds focus movement and Back management. A MediaWiki mobile-web A/B test explicitly decided against launching tap previews there, while reporting a separate positive history for Android-app previews [S7]. **Fix:** preserve previews for brief discovery but permit a direct-open path: e.g. one tap preview in narrative prose, an explicit **Open** affordance in indexes/search/Related, and user-adjustable *Open links directly* preference only if supported by user testing. A D-pad-focused link can show a preview through Select and offer a clearly focused Open action. Do not rely on undocumented long-press on remotes.

**2.2 — [should-fix] Search has two-window filter choreography** (`UIC-SRC-01/02`). A separate subwindow is reasonable on narrow phones but adds another modal level on TV. **Fix:** keep the three initial filters (type, chapter, favorites-only); display them as one filter sheet/panel or TV focus region, with Apply/Clear and visible chips in results. Do not add language when the app searches only its active content locale.

**2.3 — [should-fix] Language reordering may lack a visible purpose** (`UIC-NAV-04`). Selecting a language matters, but dragging a four-item language list demands extra gesture and TV mechanics. **Fix:** first state what ordering changes (fallback order? menu order? translation preference). If it only changes display order, omit reorder. If inherited charter or owner ruling requires it, supply an explicit D-pad Move Up/Down alternative.

**2.4 — [note] Reduce overlapping save concepts** (`UIC-FAV-01/02/03`). Define favorite as the *page-level* saved state and bookmark as *location within a page*. Present both in one Saved/Favorites library, without two separate search engines or unrelated screen structures. Search remains one service with filters.

**2.5 — [should-fix] Onboarding/help should be proportional** (`UIC-NAV-05`). A spotlight walkthrough on every page is disproportionate when controls are common. **Fix:** one short first-run tour of global controls, then contextual Help describing the focused viewer/table. Keep the inherited Amethyst mechanism only where it has a concrete benefit.

**2.6 — [note] Keep colour controls visually small** (`UIC-NAV-06`). Theme and vision mode are independent and can remain two small settings groups. Stamp colour representation is educational evidence: accessibility palettes should adapt UI chrome, not silently recolour reference images or comparison swatches (see §8).

## Review task 3 — Cross-device feasibility

### Capability matrix (concept-level judgement, not executed tests)

| Feature | Phone touch | Tablet touch/keyboard | Android TV D-pad | Finding |
|---|---|---|---|---|
| Inline link preview | Feasible as anchored popup/bottom sheet | Feasible | Feasible only with initial focus, clear Open/Close and return focus | [should-fix] `UIC-LNK-02` |
| Image pinch/pan/index swipe | Feasible via `InteractiveViewer` [S10] | Feasible | Zoom buttons alone do **not** substitute for directional **pan** | **[blocker]** `UIC-IMG-03/04/05` |
| Table row/column/range selection | Feasible but drag conflicts with scroll | Feasible, add pointer/keyboard | No keyboard-only range model specified | **[blocker]** `UIC-TBL-03/04` |
| 90° table rotation | Technically possible with `RotatedBox` [S9] | Possible but confusing | Orientation changes arrow direction/reading order | [should-fix] `UIC-TBL-02` |
| Landscape hidden title | Possible | Possible; not needed if space ample | Context lost during D-pad exploration | [should-fix] `UIC-LAY-03/04` |
| Favorites tree | Straightforward | Straightforward | Feasible with explicit expand/collapse and child focus | [should-fix] `UIC-FAV-02/05` |
| Text long-press bookmark | Feasible, must coexist with text selection | Feasible with pointer/keyboard | No touch/long-press equivalent specified | **[blocker]** `UIC-FAV-03`, `UIC-PLT-04` |
| In-app TV keyboard | Not primary | Fallback | Plausible, but busy implementation not inspected | [note] `UIC-PLT-02/03` |
| TTS | OS service dependent | OS service dependent | OS service dependent; no engine/voice guarantee | **[blocker]** `UIC-NAV-03` |

**3.1 — [blocker] Define two explicit image modes** (`UIC-IMG-03/04/05`, `UIC-PLT-04`). At `scale=1`: Left/Right = previous/next image, Up/Down = control navigation where applicable. At `scale>1`: focus an *image canvas* where arrows pan by a visible fixed fraction, Select returns to control bar, and Back leaves pan mode before closing viewer. Offer Fit/Reset, zoom +/- and prior/next buttons independently. Do not allow next/previous and pan to compete for the same D-pad event. `InteractiveViewer` supports visual pan/zoom, but the D-pad adapter and focus state are custom [S10, S11]. Specify a safe zoom range and clamp pan.

**3.2 — [blocker] Table selection must be keyboard-first, drag-second** (`UIC-TBL-03/04`, `UIC-PLT-04`). Use a focusable grid: arrows move active cell, Select anchors the start of a selection, arrows extend, Select confirms; Back cancels selection before closing. Row/column header Select chooses the entire row/column. Provide a separate *Bookmark selection* action. Announce `row heading, column heading, value, selected state` to TalkBack. Keep saved selections as `(tableId, stable row IDs, stable column IDs)` rather than raw coordinates when possible. Test large/merged/spanned tables and left/right scroll interplay.

**3.3 — [should-fix] Dialog focus restoration needs explicit tests** (`UIC-LNK-02`, `UIC-PRN-04`). On open: move accessibility/D-pad focus into a brief titled dialog with summary, Open and Close; keep traversal inside it; on dismissal restore the invoking link. On Android Back: dismiss only the preview. Flutter `showDialog` has focus-request and closed-loop traversal support, but requires correct wiring [S8]. Test TalkBack reading order, short summaries and text scaling.

**3.4 — [should-fix] Do not hide the identity of the reading context unconditionally** (`UIC-LAY-03`). TV and rotated-phone users can forget which stamp, colour or chapter is open. Keep a slim breadcrumb/short title visible on TV, or expose an always-visible page identity near rail focus. A flyout can show full title/date but should not be the only orientation cue.

**3.5 — [should-fix] Provide menu/item focus order across all modes** (`UIC-PLT-01/04`, `UIC-LAY-02`). Android TV guidance calls for predictable D-pad movement, clear focus, and a reachable path to all controls [S11]. On split panes, define Left/Right to enter panes, Up/Down to scroll within them, and rail-entry/exit through a documented focus boundary. Full-screen modal Back must restore the caller.

**3.6 — [note] Text controls on unknown platforms** (`UIC-PLT-01/03`). "Other => TV" is a conservative *input strategy*, not proof that a device is a TV. Feature detection (D-pad present, pointer present, display class) should drive affordances. An optional keyboard launcher should be an accessible labelled control, without suppressing an already functional system keyboard.

## Review task 4 — Requirements/Hermes conformance (provisional)

**4.1 — [blocker: evidence gap] Exhaustive conformance check cannot be completed.** The referenced `requirements/Requirements.md`, all `H-APP-*` baseline texts, the owner rulings and the source/tests are not present. Consequently it is not possible to truthfully list **every** requirement satisfied, strained or contradicted. The table is a **family-level design risk map**, not a verified APP/Hermes trace and not a claim of formal compliance.

| Referenced family | Appears to support | Strains / potential contradiction | Evidence needed before sign-off |
|---|---|---|---|
| `H-APP-UX-*` | Uniform artefacts, Related, reversible exploration, saved position (`UIC-PRN-01/02`, `UIC-ART-05`, `UIC-FAV-04`) | Forced extra preview step, missing indexes, undiscoverable favorites, title hidden (`UIC-LNK-02`, `UIC-NAV-01`, `UIC-LAY-03`) | Exact UX requirements and TV/phone task tests |
| `H-APP-ACC-*` | D-pad parity intent, contrast/vision modes, TTS (`UIC-PRN-04`, `UIC-NAV-03/06`) | Thin link-only dotted underline, no dialog/cell semantics, missing D-pad pan/selection, tiny date tokens | Exact ACC criteria, TalkBack semantics-tree tests, focus and scaling checks |
| `H-APP-ADP-*` | Portrait+landscape, width classes and panes (`UIC-LAY-01/04`) | Hidden title, rotated table interaction, ambiguous compact landscape, focus loss in reflow | Device matrix, resize/rotation/large-font tests |
| `H-APP-PRV-*` | Paid, no-tracking, on-device artefact model as stated by brief | TTS may use network-enabled voice engines; privacy behaviour not specified | Exact privacy rules; inspect voice engine flags, network policy, permissions |
| `APP-PRV-001` | Privacy-policy entry in overflow (`UIC-NAV-02`) | Entry is specified only on artefact page; global access and offline policy availability uncertain | Requirement text, reachable path audit, implementation |
| Other `APP-*`, `NORM/STRAT/PROC` | Unassessed | Unassessed | Complete requirement tree and source-level mapping |

**4.2 — [should-fix] Accessibility acceptance criteria are underspecified** (`UIC-LNK-01`, `UIC-PLT-04`, `UIC-NAV-06`). Apply a testable checklist for semantic roles, 48-dp target *design recommendation* on touch where possible, visible focus, accessible names, non-colour-only states, dynamic text resizing, screen-reader order and keyboard-equivalent actions. WCAG 2.2 gives relevant non-text contrast and focus principles, but do not treat these alone as a statement of native-Android legal conformance [S12, S13].

**4.3 — [should-fix] Privacy boundary for TTS must be clear** (`UIC-NAV-03`, `UIC-NAV-02`). Device voices can be local or network-dependent. Since the app is sold with no tracking, default to locally installed offline voices when available and make any network-required voice an explicit informed choice (or disallow it in a stricter offline policy). Confirm this against actual `H-APP-PRV-*` owner constraints, not an inference from the brief.

**4.4 — [note] Required trace expansion.** Once the repository is available, build a spreadsheet/Markdown matrix with **one row per exact APP and H-APP-* ID**, columns `requirement text`, `UIC coverage`, `satisfies/strains/contradicts/not addressed`, `evidence from code/test`, `owner ruling`, `action`. Do not mark a row "satisfies" from an aspirational `UIC` statement alone.

## Review task 5 — Learning value

**5.1 — [should-fix] Keep discovery without making knowledge access laborious** (`UIC-LNK-02/03/04`). Previews are useful for terms such as "tête-bêche," catalogue abbreviations and Julian dates. They are less useful as a compulsory intermediary for every related issue, chapter or image. Recommend context-sensitive previews for inline glossary references, direct opening for task/navigation results, and user testing with "define term vs follow topic" tasks. Wikimedia's positive Android-app preview feedback and unsuccessful mobile-web rollout illustrate that platform and interaction context matter [S7].

**5.2 — [should-fix] Provide location and recent trails** (`UIC-PRN-01`, `UIC-FAV-04`, `UIC-LAY-03`). Add compact `Chapter > Section > Artefact` context, a real Back stack, and a modest "Recently visited" list using local storage. Keep "Continue reading" distinct from "most recent exploration": a reader may wander through ten references without moving the canonical book-reading position. The latter should change on intentional linear reading, not every preview.

**5.3 — [should-fix] Restore both reading and exploration context** (`UIC-FAV-03/04`). Bookmark a passage by stable block ID and selection offset where possible; read progress by canonical narrative position. A preview should not overwrite the Continue Reading pointer. An artefact navigated from a chapter should preserve its originating chapter context even if the same entity also appears elsewhere.

**5.4 — [note] Add optional "context cards" for stamp education** (`UIC-ART-05`, `UIC-DAT-05`). A denomination page may show a structured definition, an identifiable original specimen photo (rights-cleared), issue and colour, and links to variations. Related relations should expose a short **relation label** ("printed in," "belongs to issue") rather than a flat unexplained list. This reuses existing artefact data; it does not require a new screen model.

**5.5 — [should-fix] Preserve evidence integrity for philately** (`UIC-NAV-06`, `UIC-DAT-02`). A red/green-safe UI palette must not silently alter stamp photographs or historical colour swatches that readers are studying. Expose text identifiers, a neutral frame, an "original colours" view, and approximate-digital disclaimers, especially on TV.

---

## Research Q1 — Date-line format (`UIC-ART-03`) — [should-fix]

**Evidence:** Romania adopted the Gregorian civil calendar in 1919, when 1 April Old Style became 14 April New Style. For 1800–1899, the Julian/Gregorian difference was **12 days**; in 1900–1919 it was **13 days**. Romanian military archives and AGERPRES document the national change [S1, S2]. It is wrong to infer a Gregorian basis for every Moldavian nineteenth-century source merely because the app displays modern dates.

**Recommendation:** Make **the calendar of the source date** the first date, then label any conversion. Date line: `1 June 1865 (J) · 13 June 1865 (G)`. Inline narrative on first use: `1 June 1865 (13 June 1865 Gregorian)` or locale-equivalent, then use a consistently explained shorter form where repetition demands it. Render the entire dual-date phrase as one semantic time element with focusable calendar terms if desired; tiny `/`, `J`, `G` tokens alone are poor touch targets. For year-only or range-only metadata, show `1858–1862` unless there is a meaningful source-calendar designation; **do not default it to `· G`**. Store source date, source calendar, precision, citation, optional converted date and conversion provenance. Date conversion must consider both century and regional adoption/context.

**Owner choice:** Accept source-first labelled dual dates, or explicitly choose a compact historian notation with a legend. Proposed DR-1 below.

## Research Q2 — Android/Android TV TTS (`UIC-NAV-03`) — [blocker]

**Evidence:** `flutter_tts` is maintained and at **4.2.5** when checked. It supports `speak`, `stop`, `getVoices`, engine/language enumeration, rate controls, progress callbacks and Android-specific queries [S3]. Android's TTS API can return unsupported language, missing voice data and synthesis errors; voice availability and local/network requirements vary with device and engine [S4]. Google's help says TTS-engine choices vary by device [S5]. The plugin implements Android pause via a workaround and restricts this to API **26+**; it also documents Android 11+ manifest visibility requirements for TTS-service queries [S3].

**Recommendation:** Use `flutter_tts` v4.2.5 as initial adapter, behind an app-owned `SpeechService` interface, not directly in artefact widgets. At startup or first use, query actual engines/voices, select an installed voice for the active locale (`en`, `ro`, `fr`, `de`), prefer no-network voice, and show a short spoken sample in Settings. Validate supported locales on target Google TV/Android TV hardware, including cheap devices. Split content into **stable paragraph/title/caption speech units** shorter than the engine's maximum input length; preserve `artefactId`, block ID and word/character offset; queue sequentially and resume after rotation or view change. Announce but do not double-read labels. Provide Play/Pause where engine/API permits, Stop, Next/Previous unit, rate and voice choice. Do not equate "progress callback exists" with reliable exact sentence seeking across every engine. For Android <26, implement coarse unit-level resume.

**No-engine/no-voice fallback:** Show `Read aloud is unavailable for [language] on this device`, keep normal reading fully usable, and offer instructions to install/select suitable voice data **if the TV supports it**. Do not silently read Romanian in English or send text to cloud TTS. **Owner decision required:** this pragmatic fallback does *not* guarantee spoken output on every TV, so the current statement "TTS ships in v1 for all shipped languages" must either be clarified as functionality with device-dependent voice data or backed by a licensed bundled offline synthesis/recording strategy. The latter has size, rights and maintenance implications; downloadable voice management remains out of scope. Proposed DR-3 below.

## Research Q3 — 90° rotated tables (`UIC-TBL-02/03`) — [should-fix]

**Evidence:** Flutter provides `RotatedBox`, which rotates the whole child before layout; this makes 90° rotation technically feasible [S9]. It does not solve interaction conventions. Flutter's DataTable guidance points to `TableView` from `two_dimensional_scrollables` for larger two-axis tables and warns of expensive whole-table layout [S14]. W3C guidance emphasizes preserving the relationship between row/column headers and cells for assistive reading [S15].

**Recommendation:** Reject *quarter-turning the table content* as the default remedy. The primary view should use horizontal/vertical scrolling, preserved sticky row and first-column headers where practical, and a **Fit table / Full-screen table** control. Add optional `Transpose rows/columns` only for rectangular, structurally safe matrices and only when it clearly improves analysis; transpose **changes the roles of dimensions** and must be explicitly labelled, unlike view rotation. Device rotation should be handled by normal responsive layout, not a separate in-content rotate button. For TV, grid navigation and optional page-at-a-time scrolling must be reachable by arrows. A 90° experimental mode can be retained behind a test flag if demanded by owner, but it needs TalkBack and TV validation before release. Proposed DR-2 below.

## Research Q4 — Preview popups and accessible links (`UIC-LNK-01/02`) — [should-fix]

**Evidence:** MediaWiki provides page previews in multiple products, but a recent tap-preview experiment on **mobile web** was not rolled out; its mobile apps have distinct implementations [S7]. Flutter dialogs support requested focus and closed-loop focus traversal [S8]. WCAG guidance cautions that **thin** cues can become indistinct after antialiasing and recommends sufficient contrast for necessary indicators [S12]; meaningful link names matter [S16].

**Recommendation:** Use a short, nonnested dialog or mobile bottom sheet. Screen readers should hear `Preview: [artefact title]`, summary, `Open full article`, `Close`. Mark inline links as links in the semantics tree (`Semantics(link: true, label: meaningfulName, onTap: ...)`) and ensure focus returns to the invoking span when closed. D-pad: Select opens preview, initial focus goes to Open, Back closes, no underlying controls can steal focus. Tap-outside dismissal on touch should be optional; a visible Close action is needed on TV. The **thin dotted underline alone** is not sufficient as a discoverability strategy for dense text and TV focus: add solid underline or stronger accent to interactive terms where needed, plus a clear focus outline and nonvisual link role. Keep colour coding nonessential. Avoid making link targets as small as a single typographic `J` without padding or accessible action grouping.

## Research Q5 — Search filters (`UIC-SRC-02`) — [note]

**Recommendation:** Keep exactly **artefact type, chapter and favorites only** initially. No language filter: search the active language, show available content and clearly label translation fallback where needed. Make filters multi-select only if the type schema requires it; retain applied chips and a one-action Clear. Use a single search model (`UIC-SRC-03`) for Search, the favorites library and index routes. Add no extra filter until user testing shows a repeatable retrieval problem.

## Research Q6 — Sections icon (`UIC-NAV-01`) — [should-fix]

**Evidence:** Android TV guidance emphasizes recognizable, predictable navigation rather than inventing new interaction patterns [S11]. Google's Material icon set includes a conventional **table-of-contents (`toc`)** symbol and book-like symbols [S17].

**Recommendation:** Prefer the standard `toc`/`format_list_bulleted` glyph if it renders recognizably at the app's chosen size, and expose a semantics/tooltip label **Contents** or **Sections**. A plain hamburger suggests application navigation, while the proposed bullet-list glyph is close to a familiar list metaphor and is reasonable *if tested*. On TV, a small persistent `Contents` label near focused rail item can remove ambiguity. Do an A/B recognition test using first-time users; do not create a new glyph solely to distinguish this app.

## Research Q7 — 10-foot reading UX (`UIC-PLT`, `UIC-NAV`) — [should-fix]

**Evidence:** Google's TV guidance observes a viewing distance around 3 metres and advises limiting heavy reading or increasing type size [S18]. Its typography guidance prioritizes legible, larger sans-serif type [S19]; TV navigation/focus rules require clear control focus and predictable directional movement [S11].

**Proposed first-pass TV design tokens (design estimates, **not** Google-mandated values):**

| Element | TV target | Reason/test |
|---|---|---|
| Long-form body | `26sp`, line-height `1.35–1.5`, default | Confirm at 2.5–3 m; support 30–34sp user setting |
| Chapter/artefact title | `34sp` | Strong location cue |
| Section heading | `29sp` | Keeps section hierarchy visible |
| Image caption, metadata | `22–24sp` | Avoid tiny date and catalogue codes |
| Focused action/label | `24sp` with visible outline | Readable D-pad affordance |
| Edge-safe region | approximately 5% side inset, 3–5% vertical | Test TV overscan and platform bars [S20] |
| Text column | roughly 55–75 characters per line at default scale | Readability target to validate, not a fixed pixel width |

**Behaviour:** let D-pad Up/Down scroll by paragraph or viewport when no inline link is focused; support distinct control-focus and reading-focus modes without traps. A single Select on `Read aloud` should launch TTS without opening several settings windows. Include pause/stop and paragraph stepping that works from the remote. Prioritize an artefact title, a related-image preview, one reading column, and a clear Return to Contents action. Test on a 1080p low-end TV, 4K TV with density scaling, tablet with hardware keyboard and phone rotated to landscape. Validate text scaling up to at least 200% as a test target without clipped dialogs/buttons.

## Research Q8 — Rights-safe colour swatches and hex (`UIC-DAT-02`, `UIC-ART-04`) — [should-fix]

**Evidence:** RAL itself warns that digital reproductions approximate physical samples and that display colour varies [S21]. RAL sells digital RGB/Lab libraries with stated **per-user** usage rights; public availability of a hex approximation does **not** by itself establish reuse rights for a commercial app [S22]. Pantone describes its numbering system as proprietary [S23]. These sources do **not** give permission to redistribute proprietary swatch libraries.

**Recommendation:** Treat canonical colour **names/standard identifiers** (where adequately sourced) as reference metadata, but label a displayed sRGB hex `screen approximation, not official standard colour`. For a rights-safe initial swatch, create an **independent** approximate colour guided by a rights-cleared stamp scan or another asset with an explicit compatible licence; record its method, licence/provenance, `sRGB_hex`, colour-profile assumption and confidence. Avoid copying Pantone/RAL RGB lookup tables or republishing someone else's palette under a generic "public" assumption. If fidelity of RAL/Pantone-derived swatches is essential, seek a licence that covers embedding and redistribution. Preserve original rights-cleared stamp scans; vision-mode filters may adjust surrounding interface and add text, but must not be presented as authentic specimen colours.

**Suggested frontmatter (illustrative, not actual verified code/schema):**

```yaml
# Keep the repository's canonical schema/identifiers if they differ.
standard_references:
  pantone: "1807"
  ral: "3002"
  ams: "11136"
digital_swatch:
  hex: "#<independently-determined-sRGB-value>"  # placeholder, not a real value
  display_label: "Approximate screen colour"
  approximation: true
  method: "visual_estimate_from_rights_cleared_specimen"
  source_asset_id: "<stable-rights-cleared-image-id>"
  rights_record: "<source-and-licence-evidence>"
  colour_space: "sRGB"
```

No actual colour codes were computed or verified in this review because the supporting wiki content, specimen scans and rights records were not supplied.

---

## Draft decision records (owner approval required)

The repository's official DR template was not available. These drafts use a minimal conventional structure and must be migrated to `wiki/meta/decisions/README.md` format once accessible. **No DR is accepted by this review.**

### DR-1 — Date display: source-calendar first

- **Status:** Proposed.
- **Context:** `UIC-ART-03` permits two formats; source dates of nineteenth-century Moldavia often follow the Julian calendar, while modern cross-references may be Gregorian [S1, S2]. Bare `J/G` is terse and potentially ambiguous.
- **Decision proposed:** On dated artefacts, show source date first with its calendar marker; show an explicitly labelled converted equivalent when relevant: `1 June 1865 (J) · 13 June 1865 (G)`. Inline prose: `1 June 1865 (13 June 1865 Gregorian)`. Year-only dates omit the calendar suffix unless material to interpretation. Persist precision and source/converted provenance. Default-to-Gregorian is forbidden unless proven by the source.
- **Consequences:** Slightly longer date line, fewer conversion misunderstandings, localized formatting required; year and individual date tokens need accessible target design.
- **Alternatives considered:** `1/13 June 1865 J/G` (compact but hard to parse); converted-date first (easier for modern chronology but obscures original source evidence); primary with parentheses (suitable inline, used there).
- **Validation:** Compare 1858/1865 and post-1900 examples, leap boundaries and changes of month/year in RO/EN/FR/DE. Check exact C-04 text when repository is available.

### DR-2 — Table presentation: scroll, not quarter-turn

- **Status:** Proposed.
- **Context:** `UIC-TBL-02` uses in-content 90° rotation to fit wide tables, introducing disorienting axes, keyboard-navigation questions and altered screen-reader presentation [S9, S14, S15].
- **Decision proposed:** Keep table upright. Use horizontal/vertical scrolling, stable headers when feasible, fullscreen viewing and keyboard-addressable cells. Allow a specialized transpose function only for matrices whose semantic relationships permit it. Do not put a rotate-table control in the default viewer.
- **Consequences:** Conventional text reading and TV focus, some continued horizontal scrolling; implementation must handle big tables without laying out every cell.
- **Alternatives considered:** Quarter-turn content; changing device orientation; automatic transpose. None is the primary solution for the stated constraints.
- **Validation:** Simulate a wide chronology table, a table with row/column headers, and a merged-cell table under touch, TalkBack and D-pad. Preserve bookmark selections across reflow.

### DR-3 — Device TTS adapter and installed-voice fallback

- **Status:** Proposed; **requires explicit owner ruling on guarantee**.
- **Context:** `UIC-NAV-03` commits to v1 TTS across shipped languages. Android synthesis availability is controlled by the installed engine and voice data, not by a Flutter package [S3, S4, S5].
- **Decision proposed:** Integrate `flutter_tts` 4.2.5 behind an app-owned speech service; test installed locale/voice support for EN/RO/FR/DE, prefer offline voices, speak stable content units with position/progress restoration and support remote controls. If no supported engine/voice exists, explain unavailability and show device-appropriate setup guidance without cloud synthesis. Do not ship a fixed set of misleading substitute voices.
- **Consequences:** One service, graceful errors and reproducible progress; some TVs may lack spoken output unless voice data can be installed. **This is weaker than a device-independent output guarantee.** If that guarantee is an owner requirement, this DR cannot be approved without a separate bundled/offline-engine or prerecorded-audio plan.
- **Alternatives considered:** A native custom Android TTS wrapper (more maintenance, same voice limitations); cloud synthesis (network/privacy/cost risk); embedded engine/audio (distribution and licensing cost, complex for four languages).
- **Validation:** Android 7/8/11+, Google TV and generic TV devices, offline mode, engine missing, installed voice missing, changing languages, long passage, pause/resume, screen rotation and interruption. Test content order and pronunciation of philatelic terms.

---

## Suggested acceptance tests to add after repository access

1. On **every** page, reach Contents, Images, Abbreviations/Glossary, Favorites and Search with touch and D-pad; return to original focus/scroll after each.
2. On first launch and after app restore, Continue Reading opens the last *narrative* location, not a transient preview or arbitrary linked entity.
3. Navigate from prose link to preview to More to a second preview, then Back twice; verify artefact, scroll anchor, focus and origin.
4. With TalkBack active, read a linked date/calendar marker, open/dismiss its preview, and verify the active focus returns to the same link.
5. In a TV image viewer, zoom to >1×, pan in all four directions, fit, step to previous/next cleared image and return; verify no hidden focus traps.
6. Select one cell, a row, a column and a rectangular range on TV, bookmark each, and reopen with exact stable selection after orientation/layout changes.
7. Navigate a table wider than viewport using only remote arrows, with accessible row/column labels and focus always visible.
8. Open a full-width, large-font landscape page (compact and expanded sizes), including title/date, preview, bookmarks and two-pane Back behaviour.
9. Search using all three filters on phone and TV; enter a query using TV keyboard and return from filter panel without losing the query.
10. TTS on each available EN/RO/FR/DE voice: long artefact, title/body/caption order, stop/resume, offline, missing voice, network-required voice and rotation.
11. Switch colour-vision modes while viewing original stamp scans and colour entries; original reference pixels remain visibly distinguishable from accessibility-adjusted chrome.
12. Confirm all saved bookmarks and favorites survive process death, content bundle reordering and translation change, with a defined missing-content recovery state.
13. Audit each relevant APP/Hermes baseline and owner ruling against evidence from actual tests, not just design text.

## Unresolved repository-dependent checks

- `../TODO.md` owner rulings: some recommendations (previews, language ordering, titles, table controls, TTS guarantee) may already be fixed and must be reconciled before acceptance.
- `requirements/Requirements.md`: exact APP requirement enumeration and `H-APP-UX-*`, `H-APP-ACC-*`, `H-APP-ADP-*`, `H-APP-PRV-*` conformance cannot be determined here.
- `wiki/meta/ontology.md` and `conventions.md`: verify source calendar conventions, relation types, abbreviation ID rules, source dates and stable image/table IDs.
- Flutter UI and tests: verify actual focus management, restoration IDs, device detection, two-pane navigation and platform-specific focus behaviour; no claim of passed tests is made here.
- Colour sources and source files: confirm actual colour-to-standard mappings, licensed photos and permissible swatch data before generating `hex` fields.

## References (consulted 2026-10-25)

- **[S1]** Arhivele Militare Naționale Române, *100 de ani de la introducerea oficială a Calendarului Gregorian în România*: https://amnr.defense.ro/events/19
- **[S2]** AGERPRES, *Trecerea la calendarul gregorian în România*: https://agerpres.ro/documentare/2024/03/26/fragment-de-istorie-trecerea-la-calendarul-gregorian-in-romania-1-aprilie-1919--1272407
- **[S3]** `flutter_tts` package and Android pause/API details: https://pub.dev/packages/flutter_tts ; https://pub.dev/packages/flutter_tts/changelog
- **[S4]** Android `TextToSpeech` reference, language/voice availability and errors: https://developer.android.com/reference/android/speech/tts/TextToSpeech
- **[S5]** Android Accessibility Help, *Text-to-speech output*: https://support.google.com/accessibility/android/answer/6006983
- **[S7]** Wikimedia, *Mobile page previews* experiment and results: https://www.mediawiki.org/wiki/Readers/Reader_Growth/Mobile_page_previews
- **[S8]** Flutter `showDialog`, focus and traversal: https://api.flutter.dev/flutter/material/showDialog.html
- **[S9]** Flutter `RotatedBox`: https://api.flutter.dev/flutter/widgets/RotatedBox-class.html
- **[S10]** Flutter `InteractiveViewer`: https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html
- **[S11]** Android TV D-pad navigation and focus guidance: https://developer.android.com/training/tv/get-started/navigation ; https://developer.android.com/design/ui/tv/guides/styles/focus-system
- **[S12]** W3C WCAG 2.2, Non-text Contrast (including thin-line visibility): https://www.w3.org/WAI/WCAG22/understanding/non-text-contrast.html
- **[S13]** W3C WCAG 2.2, Focus Appearance (AAA, used as design guidance): https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance
- **[S14]** Flutter DataTable class, two-dimensional-scroll alternatives: https://api.flutter.dev/flutter/material/DataTable-class.html
- **[S15]** W3C WAI, *Tables with Two Headers*: https://www.w3.org/WAI/tutorials/tables/two-headers/
- **[S16]** W3C WCAG, Link Purpose (in context): https://www.w3.org/WAI/WCAG21/Understanding/link-purpose-in-context
- **[S17]** Google's Material symbols repository (official), *Material Icons*: https://github.com/google/material-design-icons ; icon browser: https://fonts.google.com/icons
- **[S18]** Android TV, *Design for TV* / 10-foot context: https://developer.android.com/design/ui/tv/guides/foundations/design-for-tv
- **[S19]** Android TV typography: https://developer.android.com/design/ui/tv/guides/styles/typography
- **[S20]** Android TV layouts and overscan guidance: https://developer.android.com/training/tv/playback/compose/layouts
- **[S21]** RAL COLOURS, digital versus physical colour approximation: https://www.ral-farben.de/en/ral-digital-colour-library
- **[S22]** RAL CLASSIC digital colour library and one-user purchase terms: https://shop.ral-farben.de/en/ral-digital-colour-library-ral-classic.html
- **[S23]** Pantone, proprietary numbering system: https://www.pantone.com/color-systems/for-graphic-design

**Source precision:** References support the external facts or technical APIs indicated. The project-specific risks, priorities, design tokens and recommendations are this reviewer's analysis, not claims stated by those sources. Licences for any future colour values must be evaluated separately for actual reuse.
