# Release workflow

The process follows PROC-REL-001, which refines H-PROC-REL-001 and H-PROC-REL-002.

## One-time setup

1. **Upload key.** Reuse the existing upload keystore (`C:\Users\stefa\.android\upload-keystore.jks`) or create one for this app. Then run `app/doctor.sh --fix` to get `android/key.properties` from the template and fill it in. **Never commit it.** Record where the backup of the keystore is kept (H-APP-SEC-001).
2. **Play Console** (personal developer account):
   - Create the app `com.jinisolutions.capdebour`. The applicationId is permanent.
   - Set it as **Paid**. This needs a payments profile (NORM-GPDP-01).
   - Fill in the content rating and the data safety form ("no data collected").
   - Add the privacy policy URL (`https://jini.solutions/bull/privacy`, which must be published first).
   - Opt in to **Android TV** distribution, with TV screenshots and the banner (NORM-GPTV-01).
3. **Price**: an owner decision, recorded in TODO.md (STRAT-MKT-001).

## Every release

1. `app/doctor.sh --release`: every gate must be green.
2. `py -3 app/wizard/wizard.py --release`: this needs a PASS verdict. The wizard bumps the build number in `pubspec.yaml` and builds and verifies the AAB. Bump `versionName` by hand when the release is user-visible.
3. Upload `app/build/app/outputs/bundle/release/app-release.aab` to the **internal testing** track.
4. Smoke test on a phone (portrait and landscape), a tablet, and an Android TV device or emulator with the D-pad only. Write the result in the release log entry's notes.
5. Promote to production as an explicit owner action. Set `"released_to_store": true` in `docs/release_log.jsonl`.
6. Commit the version bump and the release log, and tag `vX.Y.Z` (manual until automated).
