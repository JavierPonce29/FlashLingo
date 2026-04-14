# FlashLingo

FlashLingo is a local-first Flutter app for importing `.flashjp` decks and
studying them on Android with spaced repetition, deck analytics, offline
progress tracking, and exportable statistics.

## Release scope

- Primary target: Android / Play Store
- App id: `com.flashlingo.app`
- Supported UI languages in v1: English and Spanish
- Data model: fully local, no account system, no cloud sync

## Core capabilities

- Import `.flashjp` or `.zip` deck packages
- Update an existing deck without resetting user progress
- Study recognition and production cards with SRS scheduling
- Resume sessions, undo the latest answer, and review deck history
- Inspect deck statistics, forecasts, problem cards, CSV exports, and PDF exports
- Store deck media locally and clean orphaned media after update/delete

## Project layout

- `lib/data/`: local models, Isar setup, study-day utilities
- `lib/features/home/`: deck list, import flow entry points, deck actions
- `lib/features/importer/`: package preview, import/update merge, media handling
- `lib/features/library/`: deck settings, browser, deck overview, rename/delete logic
- `lib/features/stats/`: deck analytics, exports, forecast/prediction helpers
- `lib/features/study_session/`: study queue, SRS transitions, undo/session restore
- `lib/l10n/`: English and Spanish strings used in the production build
- `test/`: unit and integration coverage for importer, stats, browser logic, settings validation, and SRS

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release commands

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

The signed Android bundle is produced at:

`build/app/outputs/bundle/release/app-release.aab`

## Deck package contract

FlashLingo accepts package files with either extension:

- `.flashjp`
- `.zip`

The importer supports:

- a flat archive layout
- a single wrapper folder containing the package contents

See the full package contract in [docs/flashjp-format.md](docs/flashjp-format.md).

## Android release setup

Create `android/key.properties` before building a signed release:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=../keystore/flashlingo-upload.jks
```

Then place the keystore file at the matching relative path.

## Manual QA and release preparation

- Android release checklist: [docs/android-release-checklist.md](docs/android-release-checklist.md)
- Manual smoke matrix: [docs/manual-qa-matrix.md](docs/manual-qa-matrix.md)

## Current expectations

- `flutter analyze` must stay clean
- `flutter test` must stay green
- Import/update flows must preserve user progress
- Release builds must avoid debug-only tools and placeholder branding

## Notes

- Generated `*.g.dart` files are excluded from static analysis noise.
- Test runs may rewrite `tmp/pdfs/stats_report_test.pdf`.
- The app is intentionally local-first. Backup/sync is not part of the current release scope.
