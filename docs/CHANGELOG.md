# Changelog

All notable changes to the **PlayMate** application will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-01

### Summary
First stable, production-grade public release for Google Play Store and Apple App Store. Delivers an end-to-end suite of 8 offline gaming tools, complete Clean Architecture refactoring, Hive 2.x persistence, haptic feedback, and accessibility compliance.

### Added
- **Dice Roller Module:**
  - Multi-dice support: simultaneous rolling of 1 to 6 dice.
  - Polyhedral dice types: D4, D6, D8, D10, D12, and D20.
  - Accelerometer shake-to-roll integration with customizable sensitivity.
  - History log tracking the last 50 rolls with running totals.
- **Coin Toss Module:**
  - High-fps 3D flip animation with realistic physics deceleration.
  - Multi-coin flipping (up to 3 coins simultaneously).
  - Heads/Tails streak counter and probability analysis bar.
- **Team Generator:**
  - Dynamic roster manager with bulk name paste.
  - Smart balancing algorithms: Pure Random vs. Skill-Weighted.
  - Support for 2 to 8 team partitions with bench reserve handling.
- **Universal Score Tracker:**
  - Multiplayer scoreboard supporting up to 16 players.
  - One-tap quick scoring (+1, -1, +5, -5, +10) and custom input modal.
  - Round-by-round ledger with full undo/redo action stack.
- **Cricket Scorer (Street & Club):**
  - Ball-by-ball scoring interface with legal ball indicators.
  - Tracking for Runs (0, 1, 2, 3, 4, 6), Wickets, Extras (Wide, No-Ball, Bye, Leg-Bye).
  - Current Run Rate (CRR) and Required Run Rate (RRR) live calculations.
  - Inning summary export and historical match ledger.
- **Spin Wheel:**
  - Customizable slice wedges with color pickers and custom text.
  - Smooth physics rotation decay with haptic clicks on each peg.
  - Option to remove chosen wedge after spin (Elimination mode).
- **Tournament Generator:**
  - Single-elimination and Double-elimination bracket generators for 4 to 32 participants.
  - Interactive bracket tree with pinch-to-zoom navigation.
  - Winner progression logic with automatic round advancement.
- **Game Timers Suite:**
  - Countdown timer with custom alarm sounds.
  - Precision stopwatch with split lap times.
  - Dual-clock Chess Timer with Fischer increments (e.g., 3+2, 5+5, 10+0).
  - Audible turn timer for board games with visual warning states.
- **Core Infrastructure & Design System:**
  - Adaptive Material 3 design system with seamless Light and Dark themes.
  - Responsive screen layouts optimized for compact smartphones, foldables, and tablets.
  - Zero-latency local storage using Hive boxes with schema validation.
  - Optional, privacy-preserving Firebase telemetry (Analytics & Crashlytics).

### Changed
- Refactored entire routing layer to declarative `go_router` 17.3 for deep-link support.
- Upgraded state management architecture to `flutter_riverpod` 2.6.

### Fixed
- Fixed audio stutter on low-end Android devices by switching to pooled audio instances.
- Resolved memory leak in accelerometer sensor stream subscriptions when navigating away from the Dice screen.

---

## [0.5.0] - 2026-08-15

### Summary
Beta milestone release introducing advanced game tools, audio feedback, and local persistence.

### Added
- Dedicated Cricket Scorer prototype supporting basic 6-ball overs.
- Single-elimination Tournament Bracket generator supporting 4, 8, and 16 teams.
- Chess Clock timer mode with turn toggling.
- Audio synthesis engine powered by `audioplayers` for dice rolls and coin clinks.
- Persistent Hive storage for settings, custom team rosters, and match histories.
- Haptic feedback integration across all interaction buttons.

### Changed
- Redesigned Home screen into a responsive 2-column utility dashboard card grid.
- Replaced basic `setState` pattern with Riverpod `StateNotifier` across all features.

### Fixed
- Fixed bug where rapidly tapping "Flip Coin" caused inconsistent state animation overlaps.
- Corrected team generator division error when player count was not evenly divisible by team count.

---

## [0.2.0] - 2026-06-10

### Summary
Alpha milestone release validating core game utilities and layout structure.

### Added
- Team Generator module with simple random division.
- Multi-player Score Tracker with manual score adjustment dialogs.
- Basic Countdown and Stopwatch timers.
- Initial Light and Dark theme palette using Material 3 color seeds.
- Settings screen for sound and theme preferences.

### Changed
- Migrated navigation from basic imperative `Navigator.push` to `go_router`.

### Fixed
- Fixed layout overflow errors in Score Tracker on compact screen sizes (<360dp width).

---

## [0.1.0] - 2026-04-05

### Summary
Initial proof-of-concept internal prototype.

### Added
- Project skeleton initialized with Flutter 3.x and Dart 3.x.
- Basic 1-die D6 roll screen.
- Basic 2-sided Coin Flip screen.
- Minimalist Charcoal and Clean White UI layout.
- Prototype shake-to-roll detection using accelerometer data.
