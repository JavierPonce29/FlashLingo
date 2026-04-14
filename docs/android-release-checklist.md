# Android release checklist

This checklist is the minimum bar before shipping a new Play Store build of
FlashLingo.

## 1. Versioning and signing

- Update `version:` in `pubspec.yaml`
- Confirm Android package id is `com.flashlingo.app`
- Confirm `android/key.properties` points to the release keystore
- Confirm the keystore file exists at the expected path

## 2. Static verification

Run all of these commands from the repo root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Expected outcome:

- no analyzer issues
- all tests green
- `app-release.aab` generated successfully

## 3. Smoke validation on device

Install the release build on at least one physical Android device and verify:

- fresh install works
- app opens without onboarding/import crashes
- import of a valid `.flashjp` deck succeeds
- study flow works for new, learning, review, and production cards
- stats page opens and exports CSV/PDF through Android share sheet
- deleting a deck removes it cleanly

Use the full matrix in [manual-qa-matrix.md](manual-qa-matrix.md).

## 4. Upgrade validation

Validate an upgrade from an existing local database:

- install a previous app build with real data
- import at least one deck
- study some cards
- install the new release over the existing build
- confirm decks, stats, and next review dates remain intact
- confirm `updateExisting` still preserves progress

## 5. Play Console assets

Prepare before upload:

- app icon
- screenshots
- short description
- full description
- privacy policy URL
- Data Safety form answers
- release notes / changelog

## 6. Release bundle handoff

Archive these artifacts for each release:

- generated `.aab`
- exact git revision or tag
- final `versionName` and `versionCode`
- release notes text
- signed-off checklist result

## 7. Do not ship if any of these fail

- import/update resets user progress
- `flutter analyze` is not clean
- tests are failing
- the release bundle was built with debug signing
- debug-only tools are visible in production
- Android share/export is broken
