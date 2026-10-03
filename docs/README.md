# PlayMate 🎲 🪙 🏆

> **Everything you need for offline games.**

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod%202.6-blue)](https://riverpod.dev)
[![Storage](https://img.shields.io/badge/Storage-Hive%202.2-yellow)](https://docs.hivedb.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-brightgreen)](#supported-platforms)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](./LICENSE.md)

**PlayMate** is a premier, offline-first mobile companion engineered for board game enthusiasts, sports teams, party gamers, and competitive tabletop players. Whether you're playing tabletop RPGs in a secluded cabin, scoring a fast-paced gully cricket match in the park, splitting pickup squads on the turf, or settling friendly bets with a coin toss, PlayMate brings an entire physical game-box utility kit straight to your pocket—no internet connectivity required.

---

## 📑 Table of Contents

- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [Technology Stack](#-technology-stack)
- [Architecture Overview](#-architecture-overview)
- [System Requirements](#-system-requirements)
- [Installation & Getting Started](#-installation--getting-started)
- [Project Folder Structure](#-project-folder-structure)
- [Build & Run Commands](#-build--run-commands)
- [Documentation Suite](#-documentation-suite)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [Security & Privacy](#-security--privacy)
- [License](#-license)
- [Author & Acknowledgments](#-author--acknowledgments)

---

## ✨ Key Features

| Utility | Description | Highlights |
| :--- | :--- | :--- |
| 🎲 **Dice Roller** | Cryptographically randomized polyhedral and multi-die generator. | D4, D6, D8, D10, D12, D20 dice options, 1–6 simultaneous dice, Shake-to-Roll physics, haptic feedback, roll history log. |
| 🪙 **Coin Toss** | Ultra-responsive 3D coin flipping simulator. | Fair 50/50 physics RNG, Heads/Tails tracking, streak counter, sound effects, single-tap or shake trigger. |
| 👥 **Team Generator** | Balanced and randomized squad partitioning. | Dynamic player roster input, 2–8 team generation, skill-weighted or purely random balancing, quick roster export. |
| 📊 **Score Tracker** | Universal multi-round, multi-player score register. | Unlimited players, customizable increments (+1, +5, -1, custom), leaderboards, round-by-round persistence, game presets. |
| 🏏 **Cricket Scorer** | Dedicated offline ball-by-ball scorer for gully and club cricket. | Over counters, wicket tallies, extras (wides, no-balls), run rate calculator, target projection, match summaries. |
| 🎡 **Spin Wheel** | Customizable decision wheel and prize picker. | Custom labels, customizable slice colors, realistic angular momentum decay, audible clicking sound per peg. |
| 🏆 **Tournament Generator** | Automated bracket creation for competitions. | 4 to 32 player brackets, single and double elimination, automatic winner advances, shareable final rankings. |
| ⏱️ **Versatile Timers** | Game clock hub for speed and strategy games. | Multi-mode timer: Countdown Timer, Precision Stopwatch, Chess Clock with Fischer increments, Round/Turn Timer. |
| ⚙️ **Customization** | Accessibility-first design system. | Pure Dark Mode & Light Mode, audio/haptic toggles, local storage manager, zero telemetry leaks. |

---

## 📱 Screenshots

```
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│    PLAYMATE     │   │   DICE ROLLER   │   │ CRICKET SCORER  │
│ ┌─────┐ ┌─────┐ │   │   ┌───┐ ┌───┐   │   │ TEAM A: 48/2    │
│ │🎲   │ │🪙   │ │   │   │ ⚂ │ │ ⚄ │   │   │ OVERS: 4.2      │
│ └─────┘ └─────┘ │   │   └───┘ └───┘   │   │ TARGET: 75      │
│ ┌─────┐ ┌─────┐ │   │   TOTAL: 8      │   │ [·] [1] [4] [6] │
│ │👥   │ │📊   │ │   │ [SHAKE TO ROLL] │   │ [W] [WD] [NB]   │
│ └─────┘ └─────┘ │   │                 │   │                 │
└─────────────────┘   └─────────────────┘   └─────────────────┘
```
*(High-resolution screenshots for 6.7" iPhone and 6.67" Android available in `assets/screenshots/` and documented in [STORE_ASSETS.md](./STORE_ASSETS.md).)*

---

## 🛠️ Technology Stack

- **Core Framework:** [Flutter 3.24+](https://flutter.dev) (Channel stable)
- **Programming Language:** [Dart 3.5+](https://dart.dev) with sound null-safety
- **State Management:** [Flutter Riverpod 2.6](https://riverpod.dev) (`StateNotifierProvider`, `NotifierProvider`, `ConsumerWidget`)
- **Navigation & Deep Linking:** [GoRouter 17.3](https://pub.dev/packages/go_router)
- **Local Persistence (Offline DB):** [Hive 2.2](https://docs.hivedb.dev) & [Hive Flutter 1.1](https://pub.dev/packages/hive_flutter)
- **Sensors & Hardware:** [sensors_plus 7.0](https://pub.dev/packages/sensors_plus) (accelerometer shake detection), [audioplayers 6.7](https://pub.dev/packages/audioplayers) (SFX synthesis)
- **Cloud & Telemetry (Optional/Fallback):** Firebase Core, Firebase Analytics, Firebase Crashlytics, Firebase Remote Config
- **Code Generation:** `build_runner`, `freezed`, `json_serializable`, `hive_generator`

---

## 🏗️ Architecture Overview

PlayMate adheres strictly to **Clean Architecture** organized with a **Feature-First** packaging model.

```
                  ┌───────────────────────────────┐
                  │       Presentation Layer      │
                  │  (Screens, Widgets, Notifiers) │
                  └───────────────┬───────────────┘
                                  │ watches / triggers
                                  ▼
                  ┌───────────────────────────────┐
                  │          Domain Layer         │
                  │  (Business Models & Contracts)│
                  └───────────────┬───────────────┘
                                  │ calls
                                  ▼
                  ┌───────────────────────────────┐
                  │           Data Layer          │
                  │ (Hive Boxes, Repositories)    │
                  └───────────────────────────────┘
```

For complete technical diagrams and module boundary contracts, see [ARCHITECTURE.md](./ARCHITECTURE.md).

---

## 💻 System Requirements

- **Development OS:** macOS Sonoma/Sequoia, Ubuntu 22.04 LTS+, or Windows 11
- **Flutter SDK:** `>= 3.24.0`
- **Dart SDK:** `>= 3.5.0 < 4.0.0`
- **Java Development Kit (JDK):** JDK 17 (LTS) or JDK 21 (LTS)
- **Android Studio / Xcode:** Android Studio Ladybug+ / Xcode 15+

---

## 🚀 Installation & Getting Started

### 1. Clone Repository
```bash
git clone https://github.com/your-username/playmate.git
cd playmate
```

### 2. Verify Toolchain
```bash
flutter doctor -v
```
Ensure Android SDK licenses are accepted and iOS CocoaPods (if on macOS) are updated.

### 3. Fetch Dependencies
```bash
flutter pub get
```

### 4. Run Code Generation (if modifying models)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Launch the Application
```bash
# Debug run on connected device or simulator
flutter run
```

---

## 📂 Project Folder Structure

```text
playmate/
├── android/                 # Native Android Gradle configuration
├── ios/                     # Native iOS Xcode workspace & Podfile
├── assets/                  # Audio SFX, fonts, branding icons
│   ├── audio/               # Dice rattle, coin flip, buzzer
│   └── icons/               # Launcher & feature icons
├── docs/                    # Complete production documentation suite
├── lib/
│   ├── core/                # Global themes, constants, design tokens
│   │   ├── constants.dart
│   │   └── theme.dart
│   ├── features/            # Feature-first modular modules
│   │   ├── coin/            # Coin Toss (UI, Provider, State)
│   │   ├── cricket/         # Cricket Scorer (UI, Provider, Models)
│   │   ├── dice/            # Dice Roller (UI, Provider, Sensors)
│   │   ├── home/            # Dashboard launcher & tools grid
│   │   ├── score_tracker/   # Score keeper engine
│   │   ├── settings/        # Preferences & local data management
│   │   ├── spin_wheel/      # Decision wheel physics & render
│   │   ├── team_generator/  # Roster balancing algorithm
│   │   ├── timer/           # Multi-mode stopwatch & chess clock
│   │   └── tournament/      # Bracket generator & knockout tree
│   ├── routes/              # GoRouter route declarations
│   ├── services/            # Storage (Hive) & Firebase abstractions
│   ├── shared/              # Reusable UI widgets & responsive layouts
│   └── main.dart            # Flutter entry point & ProviderScope setup
├── test/                    # Unit, widget, and integration tests
├── pubspec.yaml             # Project dependencies & metadata
└── README.md                # Repository landing documentation
```

---

## ⚡ Build & Run Commands

| Command | Purpose |
| :--- | :--- |
| `flutter run` | Starts the app in debug mode with Hot Reload enabled |
| `flutter run --profile` | Profiles performance, memory leaks, and frame raster times |
| `flutter test` | Executes the entire test suite (Unit and Widget tests) |
| `flutter test --coverage` | Generates LCOV coverage metrics (`coverage/lcov.info`) |
| `dart analyze` | Runs static analysis against `analysis_options.yaml` |
| `flutter build apk --release` | Generates production Android APK |
| `flutter build appbundle --release` | Generates Google Play Store Android App Bundle (.aab) |
| `flutter build ipa --release` | Builds signed iOS App Store bundle for TestFlight/Release |

---

## 📚 Documentation Suite

Explore the complete technical, operational, and legal documentation suite inside [`docs/`](./):

* [**ABOUT.md**](./ABOUT.md) — Product philosophy, problem statement, and long-term vision.
* [**ARCHITECTURE.md**](./ARCHITECTURE.md) — Deep dive into Clean Architecture, Riverpod state flow, and data layers.
* [**DESIGN_SYSTEM.md**](./DESIGN_SYSTEM.md) — Color palettes, typography scale, spacing tokens, and components.
* [**HIVE_DATABASE.md**](./HIVE_DATABASE.md) — Local schema, box contracts, and zero-loss migration strategies.
* [**FIREBASE_SETUP.md**](./FIREBASE_SETUP.md) — Analytics, Crashlytics, and Remote Config integration guidelines.
* [**ANALYTICS.md**](./ANALYTICS.md) — Complete event catalog, triggers, and privacy safeguards.
* [**SPLASH_PERFORMANCE.md**](./SPLASH_PERFORMANCE.md) — Startup benchmarks, zero-delay policy, and TTFF optimization.
* [**ASO_KEYWORDS.md**](./ASO_KEYWORDS.md) — App Store keyword research, intent mapping, and priority matrix.
* [**SEO.md**](./SEO.md) — Web discovery, Schema.org structured data, and search intent clusters.
* [**TESTING_GUIDE.md**](./TESTING_GUIDE.md) — Unit, Widget, Integration, and Golden test guidelines.
* [**DEPLOYMENT.md**](./DEPLOYMENT.md) — Complete signing and CI/CD distribution playbook for Play Store & App Store.
* [**RELEASE_CHECKLIST.md**](./RELEASE_CHECKLIST.md) — Step-by-step gatekeeper checklist before every release.
* [**CODE_STYLE.md**](./CODE_STYLE.md) — SOLID design rules, clean code principles, and naming conventions.
* [**CONTRIBUTING.md**](./CONTRIBUTING.md) — Branch strategies, PR requirements, and developer workflows.
* [**CHANGELOG.md**](./CHANGELOG.md) — Version release logs adhering to Keep a Changelog.
* [**VERSIONING.md**](./VERSIONING.md) — Semantic Versioning (SemVer 2.0.0) standard guidelines.
* [**ROADMAP.md**](./ROADMAP.md) — Strategic phases from initial utility set to peer-to-peer multiplayer.
* [**STORE_LISTING.md**](./STORE_LISTING.md) — App Store and Google Play descriptions, keywords, and marketing copy.
* [**STORE_ASSETS.md**](./STORE_ASSETS.md) — Asset dimensions, feature graphic specs, and screenshot guidelines.
* [**APP_INFO.md**](./APP_INFO.md) — SDK boundaries, permissions, and configuration matrices.
* [**FUTURE_FEATURES.md**](./FUTURE_FEATURES.md) — Detailed specifications for upcoming modules.
* [**KNOWN_ISSUES.md**](./KNOWN_ISSUES.md) — Current limitations and hardware workarounds.
* [**FAQ.md**](./FAQ.md) — Frequently asked questions for users and developers.
* [**PRIVACY_POLICY.md**](./PRIVACY_POLICY.md) — GDPR, CCPA, and COPPA compliant privacy policy.
* [**TERMS_AND_CONDITIONS.md**](./TERMS_AND_CONDITIONS.md) — Commercial terms of service.
* [**SECURITY_POLICY.md**](./SECURITY_POLICY.md) — Vulnerability reporting guidelines and encryption model.
* [**LICENSE.md**](./LICENSE.md) — MIT Open Source License.

---

## 🗺️ Roadmap Highlights

- [x] **Phase 1: Architecture & Foundations** (Riverpod, Clean Architecture, Hive Storage)
- [x] **Phase 2: Core Offline Utilities** (Dice, Coin, Teams, Scores, Cricket, Wheel, Brackets, Timers)
- [ ] **Phase 3: Deep Statistics & Insights** (Win/loss ratios, player performance graphs)
- [ ] **Phase 4: Encrypted Cloud Sync** (Optional Firebase sync across personal devices)
- [ ] **Phase 5: Pro Customization** (Custom 3D dice textures, custom soundboards)
- [ ] **Phase 6: Local P2P Multiplayer** (Bluetooth / Wi-Fi Direct score sharing)

See [ROADMAP.md](./ROADMAP.md) for full release breakdown.

---

## 🤝 Contributing

We welcome community contributions, bug reports, and suggestions! Please review our [CONTRIBUTING.md](./CONTRIBUTING.md) and [CODE_STYLE.md](./CODE_STYLE.md) before opening a pull request.

---

## 🔒 Security & Privacy

PlayMate is architected with an **Offline-First, Privacy-by-Default** mindset:
- Zero personal data is transmitted without explicit consent.
- Local storage is completely confined to the user device sandbox.
- To report security issues, refer to [SECURITY_POLICY.md](./SECURITY_POLICY.md).

---

## 📄 License

PlayMate is licensed under the **MIT License**. View [LICENSE.md](./LICENSE.md) for full terms.

---

## 👤 Developer Information

Developed with care by **Sundramdotdev**.
- **GitHub:** [https://github.com/sundramdotdev](https://github.com/sundramdotdev)
- **LinkedIn:** [https://linkedin.com/in/sundramdotdev](https://linkedin.com/in/sundramdotdev)
- **Instagram:** [https://www.instagram.com/devsundram_?stkn=dXBva2IwMzZxbHY1](https://www.instagram.com/devsundram_?stkn=dXBva2IwMzZxbHY1)
- **Support:** support@playmateapp.com
- **Website:** https://playmateapp.com
