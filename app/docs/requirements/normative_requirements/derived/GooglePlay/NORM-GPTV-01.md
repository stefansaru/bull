---
id: NORM-GPTV-01
tier: normative
title: Android TV app quality requirements
status: Partial
category: GPTV
sources: [Google Play TV app quality guidelines, https://developer.android.com/docs/quality-guidelines/tv-app-quality, retrieved 2026-10-25]
applies_when: always
tags: [Store, TV]
---

# NORM-GPTV-01 — Android TV app quality requirements

## Intent
TV apps go through a separate review; missing a banner or requiring touch makes the app invisible or rejected on TV.

## Requirement
The app shall declare a leanback launcher entry and a TV banner, not require a touchscreen, be fully usable with a D-pad, and provide TV screenshots on the listing.

## Acceptance criteria
- [x] `LEANBACK_LAUNCHER` intent filter and `android:banner`
- [x] `android.hardware.touchscreen` and `android.software.leanback` not required
- [x] D-pad-only navigation covered by a widget test
- [ ] Designed banner artwork (placeholder in use)
- [ ] TV screenshots and opt-in to TV distribution in Play Console

## Verification
Manifest inspection; `test/layout_test.dart` TV test; manual check on an Android TV emulator.
