# Habit Tapestry

A calm, well-being habit tracker built in Flutter from the *GitHub-Style Habit
Tracker* / *Habit Tapestry* design handoff (Claude Design).

Habit Tapestry reframes the GitHub contribution grid as a **woven tapestry**:
each habit ("thread") has its own dusty color, and every day is a small *weave*
of whatever you tended. Over a season the grid becomes a soft, multi-color
cloth — the texture of a life, not a scoreboard. There is no streak pressure, no
guilt-red empties, no scores.

## Screens

- **Home — "The loom"** — today's woven focal tile, per-thread check-in chips,
  the 18-week season tapestry, and the threads list.
- **Detail — "A thread"** — one thread's single-hue contribution grid with month
  and weekday labels, current/longest/8-week stats, and a gentle note.
- **Add / Edit** — one form, two modes: live preview, name, the 10-color curated
  palette, and a 7-day rhythm. Edit adds Archive (preserves history) and Delete
  (removes it, with confirmation).
- **Settings** — week start, reminders (reserved), appearance, export/backup
  stubs, and "see first-run screen".
- **Empty / first run** — the zero-threads state.

## Architecture

```
lib/
  theme/      oklch.dart      OKLCH → sRGB conversion (palette source of truth)
              tokens.dart     colors, fonts, card/shadow tokens
  models/     habit.dart      Habit model (+ JSON)
  util/       dates.dart      rolling 18-week grid window, real date math
              stats.dart      streak / longest / 8-week rate
  data/       repository.dart  SharedPreferences-backed persistence (binary check-ins)
              seed.dart        first-run sample threads + history
  state/      app_state.dart   ChangeNotifier: navigation, data, derived getters
  widgets/    cells.dart       woven (conic-gradient) + single-hue cell decorations
              grids.dart       SeasonGrid + DetailGrid
              home_widgets.dart  focal tile, check-in chips, empty loom
  screens/    home / detail / form / settings / empty
  app.dart    MaterialApp + single-stack view switch
  main.dart   entry point
```

- **State**: `provider` (`ChangeNotifier`). The UI derives everything (woven
  cells, counts, stats) from one source so a tend-toggle re-weaves the focal
  tile, the season grid, and the detail grid together.
- **Persistence**: `shared_preferences` (JSON). The check-in model is binary —
  a date key present in a habit's set means that day was tended. This is the
  real, durable store the grids and stats read from.
- **Color**: the curated habit palette is defined in **OKLCH** (the design's
  source of truth) and converted to `Color` at runtime; tints/halos use the
  same hue at reduced alpha so any combination weaves harmoniously.

## Productionization notes (vs. the HTML prototype)

The handoff prototype froze a single moment with seeded-RNG history. This app
makes the mocked parts real:

- **Real dates** — the grid is a rolling 18-week window ending today, aligned to
  the chosen week start; today lands in its true weekday row.
- **Real history** — stats and grids read from stored check-ins, not an RNG. On
  first launch the five example threads are seeded *once* with a plausible
  history written as real records (so the season grid has something to show);
  thereafter the RNG is never consulted.
- **Bundled fonts** — Newsreader & Hanken Grotesk are bundled as assets (under
  `assets/fonts/`, OFL — see the included license files) so the app renders
  correctly offline / on first launch with no runtime font fetch.
- **Time-aware greeting** — "Good morning / afternoon / evening" by local time
  (the prototype hard-coded "Good morning").

## Running

```bash
flutter pub get
flutter run                 # a connected device or simulator
# or, to preview in a browser:
flutter run -d chrome
```

Target platforms: Android & iOS (web is enabled and used for quick preview).

## Fonts

Newsreader and Hanken Grotesk are licensed under the SIL Open Font License 1.1.
Their license texts are included at `assets/fonts/OFL-Newsreader.txt` and
`assets/fonts/OFL-HankenGrotesk.txt`.
