# DR-015 — The app's UI concept: artefact browser, accepted with review revisions

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-10-25 |
| Mode | CONCEPT |
| Actor(s) | user + agent + two external LLM reviewers |
| Related | DR-014, jini-apps-DR-002, [[../conventions|C-04]] |

## Context

The owner described a UI for the app (`app/`): uniform artefact pages, preview
links, an image viewer, a table viewer with bookmarkable selections, a favorites
tree, landscape chrome, filtered search, TV support, and a three-dots menu reusing
Amethyst and busy patterns. After a clarification round it was written up as
`app/docs/ui-concept.md` with stable `UIC-` IDs, and two independent reviews were
run against `app/docs/ui-concept-review.md` (findings:
`app/docs/ui-concept-review-findings-gemini.md` and `…-chatgpt.md`).

## Decision

The concept is **accepted as revised**. The owner ruled on the four contested
points:

1. **Wide tables** (UIC-TBL-02): tables stay upright — **frozen first column and
   header row, horizontal scroll, full-screen mode**. The original rotate-90° idea
   is dropped (it inverts D-pad directions, breaks screen-reader order, and
   fights system rotation — both reviewers). Transpose is deferred.
2. **Link previews** (UIC-LNK-02): **hybrid** — preview-first in narrative prose;
   direct open from indexes, search results, Related lists, bookmarks and the TOC;
   commands never preview.
3. **TTS** (UIC-NAV-03): **best effort in v1 with graceful fallback** — device
   voices via `flutter_tts` behind a `SpeechService`, offline voices preferred,
   no cloud synthesis ever; a missing voice yields an explanation and setup
   guidance, never a wrong-language substitute. No device-independent output
   guarantee is claimed.
4. **Date notation** (UIC-ART-03): **source calendar (Julian) first, Gregorian in
   parentheses, one tappable ᴶ⁄ᴳ tag** — `1 (13) June 1865 ᴶ⁄ᴳ`,
   `24 January (5 February) 1859 ᴶ⁄ᴳ`, `25 December 1865 (6 January 1866) ᴶ⁄ᴳ`;
   year ranges stay plain (`1858–1862`), never defaulted to a calendar. This
   **resolves the open convention question under C-04** ("always show both, or
   primary + parenthetical?") in favour of primary + parenthetical, with the tag.

The uncontested review findings were folded in: entry points for every index and
for favorites in the Sections window; keyboard-first table selection; two D-pad
image-viewer modes (fitted = prev/next, zoomed = pan); stable IDs as bookmark
anchors; a breadcrumb plus a Recently-visited trail kept separate from Continue
reading; link semantics for TalkBack; the fixed three-filter search set with no
language filter; the Material `toc` glyph for Sections; proportional help;
vision modes that never recolour stamp images; hex swatches independently derived
and labelled as screen approximations, with the standard's code authoritative.

## Alternatives considered

- Rotate-90° tables (original owner idea) — rejected by both reviews; kept out
  even as a flag, to avoid promising an untested pattern.
- Preview-first on every link — uniform but doubles deliberate navigation,
  especially on TV; Wikimedia's mobile-web experience argued against it.
- Guaranteed TTS output (bundled voices or recordings) — a separate licensing,
  size and maintenance project; rejected for v1.
- Fully labelled dual dates (`1 June 1865 (J) · 13 June 1865 (G)`) — unambiguous
  but roughly twice as wide; the compact academic form with one tag won.

## Consequences

- `app/docs/ui-concept.md` is the binding target UI; implementation items live in
  `app/TODO.md` and future APP- requirements cite `UIC-` IDs.
- The wiki gains work: abbreviation entities, colour entities with rights-safe
  swatches, calendar concept pages, `summary` fields, stable unit IDs
  (UIC-DAT-01..05).
- Narrative prose keeps its current inline forms for now; any renotation of the
  13 `(J)` markers and `n/m Month` dates to the DR-015 form is a separate,
  audited pass under C-04.
