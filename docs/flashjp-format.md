# FlashLingo `.flashjp` package format

This document describes the package contract consumed by the importer in
`lib/features/importer/importer_service.dart`.

## Accepted archive layouts

The importer accepts both of these layouts:

1. Flat archive contents
2. A single wrapper directory containing the package contents

Examples:

```text
manifest.json
flashcards.db
audio/word_001.mp3
images/card_001.png
```

```text
starter_pack/
  manifest.json
  flashcards.db
  audio/word_001.mp3
  images/card_001.png
```

## Required files

- `manifest.json`
- SQLite database file referenced by `manifest.json`

## `manifest.json`

Required keys:

- `language_id`
- `pack_name`
- `db_filename`

Example:

```json
{
  "language_id": "ja",
  "pack_name": "FlashLingo Starter",
  "db_filename": "flashcards.db",
  "settings": {
    "new_cards_per_day": 20,
    "max_reviews_per_day": 200,
    "learning_steps": [1.0, 4.0],
    "enable_write_mode": false
  }
}
```

Optional media/icon keys currently recognized:

- `deck_icon`
- `deckIcon`
- `deck_icon_path`
- `deckIconPath`
- `icon`
- `icon_path`
- `iconPath`

The same icon aliases are also checked inside `settings`.

## Supported settings keys

Supported deck setting keys inside `manifest.json > settings`:

- `new_cards_per_day`
- `max_reviews_per_day`
- `lapse_tolerance`
- `use_fixed_interval_on_lapse`
- `lapse_fixed_interval`
- `p_min`
- `alpha`
- `beta`
- `offset`
- `initial_nt`
- `learning_steps`
- `new_card_min_correct_reps`
- `new_card_intra_day_minutes`
- `enable_write_mode`
- `write_mode_threshold`
- `write_mode_max_reps`

Boolean parsing accepts all of these values:

- `true` / `false`
- `1` / `0`
- `yes` / `no`
- `si` / `si` with accent

## SQLite contract

The importer reads a table named `flashcards`.

Columns currently consumed:

- `ID`
- `PALABRA`
- `SIGNIFICADO`
- `AUDIO_PALABRA`
- `AUDIO_ORACION`
- `IMAGEN`
- `ORACION`
- `TRADUCCION`
- `LECTURA_PALABRA`
- `LECTURA_ORACION`
- `FORMAS`

Each SQLite row produces two FlashLingo cards:

- recognition card: `{language_id}_recog`
- production card: `{language_id}_prod`

The logical identity used during import/update is:

`originalId + cardType`

## Media resolution

Media files are copied into the app-local `media_assets` directory.

Lookup is attempted by:

1. exact filename/path
2. decoded filename/path
3. lowercase filename/path
4. decoded lowercase filename/path
5. stem without extension

## Update existing contract

When importing with `updateExisting`, FlashLingo preserves user progress.

Fields preserved:

- `state`
- `nextReview`
- `lastReview`
- `repetitionCount`
- `lifetimeReviewCount`
- `lifetimeCorrectCount`
- `lifetimeWrongCount`
- `totalStudyTimeMs`
- review logs
- sessions
- daily stats

Fields refreshed from the package:

- `question`
- `answer`
- `sentence`
- `translation`
- `audioPath`
- `sentenceAudioPath`
- `imagePath`
- `extraDataJson`
- `deckIconUri` when available

## Current importer guarantees

- ZIP contents are extracted from file, not from a full in-memory archive blob
- SQLite rows are read in batches
- Isar writes are flushed in batches
- orphaned media is cleaned after import/update/delete
- duplicate logical cards inside the same import are ignored

## Things the importer does not do

- it does not delete existing cards that are missing from the new package
- it does not support remote downloads
- it does not edit cards manually inside the app
