# UI concept review findings — reviewer A (Gemini)

Received 2026-10-25, pasted verbatim by the owner. Responds to
[`ui-concept-review.md`](ui-concept-review.md); reviews
[`ui-concept.md`](ui-concept.md) as proposed on 2026-10-25. Disposition of the
findings: bull DR-015.

---

The review of the UI concept against the provided requirements and baselines yields the findings and decision drafts below.

**Coherence**

* **Blocker (UIC-IMG-01):** The concept introduces a global image index but provides no clear entry point in the navigation menu to reach it from any context.

* **Blocker (UIC-DAT-01, UIC-LNK-03):** The abbreviations index is accessible only by clicking an abbreviation in the text to trigger its preview. There is no top-level routing to browse all abbreviations independently.

**Simplicity**

* **Should-fix (UIC-SRC-02):** Opening search filters as a dedicated subwindow adds unnecessary navigation overhead. Using inline toggle chips below the search field reduces friction.

* **Should-fix (UIC-NAV-02):** Spawning independent subwindows for each three-dots menu item (Audio, Language, Help, Colours) creates excessive view layers.

**Feasibility**

* **Blocker (UIC-TBL-03):** Selecting table cell ranges via drag is not feasible on D-pad TV remotes. A discrete focus-state selection mode using the remote's Center/Enter key is required.

* **Blocker (UIC-IMG-03):** Pinch-to-zoom is impossible on Android TV. The provided zoom buttons (UIC-IMG-05) must fully substitute the gesture for hardware without touchscreens.

* **Note (UIC-LAY-03):** The landscape title flyout may obscure critical reading content. A collapsible sidebar pushes content dynamically rather than overlaying it.

**Conformance**

* **Satisfies H-APP-ADP:** Flutter restoration IDs successfully preserve scroll position, open artifacts, and popups across orientation changes.

* **Satisfies H-APP-ACC:** The in-app keyboard ensures text input is operable via D-pad on TV environments.

**Learning Value**

* **Note (UIC-LNK-02):** Preview-first linking effectively preserves reading momentum by preventing accidental deep-dives.

* **Should-fix:** A breadcrumb trail or visited artifact history is missing, which is critical for learners jumping between highly connected entities.

**Proposed Decision Records (DRs)**

**DR: Date-Line Format (UIC-ART-03)**
Historiographic practice for 19th-century Eastern European contexts standardizes the Julian date as primary, followed by the Gregorian date in parentheses.

* **Format:** `1 (13) June 1865`.
* **Rationale:** This aligns with academic conventions for Romanian history prior to the 1919 calendar adoption, ensuring clarity without the visual clutter of constant `J/G` abbreviations.

**DR: Text-to-Speech Engine (UIC-NAV-03)**
Use the `flutter_tts` package wrapping the native Android `TextToSpeech` API.

* **Implementation:** The plugin leverages on-device engines without cloud dependencies.
* **TV Fallback:** Because OEMs occasionally omit TTS engines on Android TV firmware, the app must catch initialization failures and gracefully disable the TTS UI button.
* **State Management:** Use the package's playback callbacks to highlight the active paragraph.

**DR: Big Data Table Pattern (UIC-TBL-02)**
Abandon the 90° rotation pattern (UIC-TBL-02).

* **Alternative:** Implement a frozen first column (anchor column) with horizontal scrolling for the remaining data matrix.
* **Rationale:** Rotating tables 90° maps horizontal scrolling to vertical screen gestures, which breaks D-pad traversal logic and confuses screen readers. A frozen anchor column preserves standard row-based reading orientation.

**DR: Link Discoverability (UIC-LNK-01)**
Retain the thin dotted underline but supplement it with structural accessibility cues.

* **Accessibility:** TalkBack 15.1 supports native link extraction. Ensure the Semantic widget wrapping the text registers as a link so TalkBack users can parse interactive elements via the local context menu without relying on visual underlines.

**DR: Search Filters (UIC-SRC-02)**
Implement Type, Chapter, and Favorites as the sole initial filters.

* **Exclusion:** Omit Language as a filter. Since the application UI dynamically translates and loads active locale bundles via the language selection window (UIC-NAV-04), cross-language search adds unnecessary complexity.

**DR: Navigation Iconography (UIC-NAV-01)**
Use the bullet-list icon for the Table of Contents.

* **Rationale:** Material Design specifications reserve the standard hamburger icon exclusively for root-level navigation drawers. A stylized bullet list accurately signals a hierarchical contents index.

**DR: 10-Foot UI Reading Experience**
Enforce a dedicated TV type scale utilizing `sp` units.

* **Typography:** Set body text minimums to 18sp and headers to 24sp–32sp.
* **Layout:** Restrict content columns to 600dp maximum width to prevent neck strain, utilizing the remaining horizontal real estate for generous margins. Ensure the active D-pad focus state applies a minimum 1.05x scale transformation with a high-contrast border.

**DR: Colour Entity Hex Codes (UIC-DAT-02)**
Store approximate Hex values derived from standardized conversion charts (e.g., Exactseal or CTBorracha matrices).

* **Storage Structure:** Define the standard code (e.g., `Pantone 187`) as the authoritative string, storing the hex approximation (e.g., `#B32428`) solely for on-screen rendering. This satisfies copyright boundaries while delivering the required visual UI swatches.
