# Kotlin layout parity

The implementation reference is the existing Kotlin code under
`Study_Planner/app/src/main/java/com/example/study_planner/view`, including
its current local edits. Each Flutter frame owns its own widget tree in the
matching HM, GO, AN, PR or PL directory. No frame uses `PrototypeScreen`.

`lib/view/common/kotlin_widgets.dart` ports the existing Compose primitives:
screen background (82% opacity), header (64 logical pixels), bottom bar
(72 logical pixels), cards (18-pixel corners, 16-pixel content padding),
buttons (52-pixel height), typography, progress rings, labeled bar charts,
subject icons, planner rows and profile fields. The full screen trees remain
in each of the 52 individual Dart files.

Restored examples:

- HM01: greeting, search/notifications, welcome image, week selector, progress,
  four statistics, lesson cards and activity links.
- GO02/GO04/GO05: original sprout_watering, goals_target and sprout_books
  assets and positions. GO09/GO10 use the shared progress/rating state.
- AN01–AN09: original per-screen chart data and labels, metrics, streak,
  badges and badge detail. AN09 has the orange flame and share action,
  without a rating control.
- PR01–PR05: original profile content and statistics, editable fields,
  grouped settings, switch defaults, appearance tiles and color swatches.
- PL01–PL18: original dashboard, day timeline, week time-grid, month calendar,
  six-step wizard, plan detail, checklist, history, scheduling and assessment.

All 24 PNG assets remain byte-identical to the Kotlin drawable assets.
Flows not implemented in the Kotlin reference retain their snackbar handoffs.

Run `flutter analyze` and `flutter test` from the project root. Tests render
all 52 frames at 390×844 and 360×800 and exercise search keyboard/navigation,
task state and goal progress. Representative render previews are written to
`build/parity_previews/`. Preview fonts in `test/fonts` are for tests only;
the application continues using the platform Roboto font.

These checks establish layout structure and overflow coverage. They are not
a pixel-difference comparison against screenshots from a running Kotlin APK;
platform font rendering and system insets can introduce small differences.
