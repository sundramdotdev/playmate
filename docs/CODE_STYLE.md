# Code Style & Engineering Standards

This document establishes the code style, design principles, and architecture rules for all code written within the **PlayMate** codebase.

---

## 🎯 Core Principles

1. **SOLID Principles:** Keep classes focused on a single responsibility, open for extension, closed for modification, and abstracted behind contracts.
2. **DRY (Don't Repeat Yourself):** Extract repeated design tokens, responsive breakpoints, and utility logic into `core/` and `shared/`.
3. **Immutability First:** All state classes must be immutable (`@immutable`, `freezed`, or `const` constructors).
4. **Declarative & Predictable:** Keep widget build methods pure. Side effects belong inside notifiers or controllers, never directly in widget render methods.

---

## 🏷️ Naming Conventions

| Entity | Convention | Example |
| :--- | :--- | :--- |
| **Folders & Directories** | `snake_case` | `team_generator/`, `score_tracker/` |
| **Dart Files** | `snake_case.dart` | `cricket_screen.dart`, `dice_provider.dart` |
| **Screens & Pages** | `PascalCase` + `Screen` | `DiceScreen`, `SettingsScreen`, `TournamentScreen` |
| **Custom Widgets** | `PascalCase` + Functional Role | `ScorePlayerCard`, `CricketKeypadButton` |
| **State Notifiers** | `PascalCase` + `Notifier` | `DiceNotifier`, `TournamentNotifier` |
| **State Classes** | `PascalCase` + `State` | `DiceState`, `TimerState` |
| **Riverpod Providers** | `camelCase` + `Provider` | `diceProvider`, `themeModeProvider` |
| **Repositories** | `PascalCase` + `Repository` | `MatchRepository`, `SettingsRepository` |
| **Services** | `PascalCase` + `Service` | `SoundService`, `StorageService` |
| **Constants & Tokens** | `camelCase` or `kCamelCase` | `kDefaultPadding`, `AppSpacing.m` |

---

## 📐 Formatting & Lint Rules

PlayMate enforces strict lint rules configured via `analysis_options.yaml` extending `package:flutter_lints`:

1. **Line Length:** 100 characters maximum.
2. **Trailing Commas:** Always include trailing commas in parameter lists and widget hierarchies. This ensures clean, readable formatting by `dart format`:
   ```dart
   // Good
   return Card(
     elevation: 0,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
     child: const Padding(
       padding: EdgeInsets.all(AppSpacing.m),
       child: Text('Hello'),
     ),
   );
   ```
3. **`const` Constructors:** Mark all immutable widget instantiations with `const` to allow Flutter's element tree to skip unnecessary rebuilds.

---

## 📝 Documentation & Comments

- **Public APIs & Providers:** Public methods, classes, and top-level providers must include doc comments (`///`):
  ```dart
  /// Manages dice rolling state, physics shake detection,
  /// and persistent roll history.
  class DiceNotifier extends StateNotifier<DiceState> {
    ...
  }
  ```
- **Self-Documenting Code:** Write clear, expressive function and variable names instead of relying on explanatory comments for trivial logic.

---

## 🧱 Architectural Boundaries

1. **Widgets Must Not Execute Data Persistence Directly:**
   ```dart
   // Bad: Direct storage call inside a button onTap
   onPressed: () {
     Hive.box('matches').put('current', matchData);
   }

   // Good: Dispatched through a Riverpod notifier
   onPressed: () {
     ref.read(cricketProvider.notifier).saveMatch();
   }
   ```

2. **Decouple Platform Hardware:**
   Always access sensors, haptics, and audio through abstract service wrappers (`SoundService`, `SensorService`). This allows mock replacements during automated widget and unit tests.
