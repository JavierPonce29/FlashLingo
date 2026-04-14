# Manual QA matrix

Use this matrix for Android smoke QA before uploading a release candidate.

## Fresh install

- Install the app on a clean device
- Launch the app
- Verify the home screen loads without errors
- Verify English and Spanish are the only selectable UI languages

## Import

- Import a flat `.flashjp` package
- Import a package with a wrapper root folder
- Import a package with media
- Import a package with missing media and confirm the summary reports it
- Re-import an existing deck using `update existing`

## Progress preservation

- Study at least one recognition card and one production card
- Close and reopen the app
- Confirm the session resumes correctly
- Update the same deck with a new package
- Confirm card content updates but progress fields remain intact

## Study flow

- Complete a new card until it reaches review
- Fail a review card and confirm lapse/relearning behavior
- Use undo once and confirm the latest answer is reverted
- Test write mode on a production card

## Library and browser

- Open deck settings and save valid values
- Try invalid learning steps and confirm validation blocks the save
- Open the card browser from stats/problem cards
- Confirm the initial search query is visible in the browser search field
- Rename a deck and confirm the new name propagates everywhere
- Delete a deck and confirm it disappears from home

## Stats and exports

- Open statistics for a populated deck
- Confirm the page loads without technical error text
- Use `Review now` on a future-due problem card
- Export CSV and confirm the Android share sheet opens
- Export PDF and confirm the Android share sheet opens

## Theme and layout

- Verify light theme
- Verify dark theme
- Verify system theme mode
- Verify large text / font scaling does not break core screens

## Upgrade test

- Install an older build with real study data
- Upgrade to the candidate build without uninstalling
- Confirm decks, review counts, next review dates, and recent stats remain intact

## Pass criteria

- no crashes
- no empty placeholders in production UI
- no raw exception strings shown to the user on normal flows
- imports, study, stats, and exports all work end to end
