---
id: NORM-GDPR-01
tier: normative
title: No personal data; transparent privacy notice
status: Done
category: GDPR
sources: [eu-gdpr-2016-679 (Hermes Framework) art. 5, 13, legea-190-2018]
applies_when: always
tags: [Privacy]
---

# NORM-GDPR-01 — No personal data; transparent privacy notice

## Intent
The best way to comply with data-protection law is to collect nothing. The app needs no account, no analytics and no network.

## Requirement
The app shall process no personal data: no analytics, no crash reporting SDK, no advertising identifiers, no network access in release builds. Preferences stay on the device.

## Acceptance criteria
- [x] No analytics, ads or crash SDKs in pubspec
- [x] Release manifest declares no INTERNET permission
- [x] Preferences stored locally only (shared_preferences)

## Verification
pubspec review; `aapt dump permissions` on the release AAB.
