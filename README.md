# PlayMate 🎲 🪙 🏏 🏆

> **Everything you need for offline games.**

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod%202.6-blue)](https://riverpod.dev)
[![Storage](https://img.shields.io/badge/Storage-Hive%202.2-yellow)](https://docs.hivedb.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-brightgreen)](#supported-platforms)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](./docs/LICENSE.md)

**PlayMate** is a production-ready, offline-first mobile companion engineered for board games, casual sports, tabletop RPGs, and friendly gatherings. Instead of downloading fragmented, ad-ridden utilities, PlayMate gives players and referees a comprehensive toolkit in one lightweight, ad-free application—completely offline.

---

## 📑 Documentation Suite

PlayMate features an exhaustive documentation suite located in [`docs/`](./docs/):

* [**ABOUT.md**](./docs/ABOUT.md) — Product philosophy, problem statement, and long-term vision.
* [**ARCHITECTURE.md**](./docs/ARCHITECTURE.md) — Clean Architecture, Riverpod state flow, and data layers.
* [**DESIGN_SYSTEM.md**](./docs/DESIGN_SYSTEM.md) — Color tokens, typography hierarchy, and UI components.
* [**HIVE_DATABASE.md**](./docs/HIVE_DATABASE.md) — Local persistence, box schemas, and non-destructive migrations.
* [**FIREBASE_SETUP.md**](./docs/FIREBASE_SETUP.md) — Telemetry, Crashlytics, and environment configurations.
* [**ANALYTICS.md**](./docs/ANALYTICS.md) — Comprehensive event catalog and privacy safeguards.
* [**SPLASH_PERFORMANCE.md**](./docs/SPLASH_PERFORMANCE.md) — Startup performance benchmarks and zero-delay architecture.
* [**ASO_KEYWORDS.md**](./docs/ASO_KEYWORDS.md) — App Store keyword research, intent mapping, and priority matrix.
* [**SEO.md**](./docs/SEO.md) — Web discovery, Schema.org structured data, and search intent clusters.
* [**TESTING_GUIDE.md**](./docs/TESTING_GUIDE.md) — Unit, Widget, and integration test guidelines.
* [**DEPLOYMENT.md**](./docs/DEPLOYMENT.md) — Keystore signing, App Bundle build, and release engineering.
* [**RELEASE_CHECKLIST.md**](./docs/RELEASE_CHECKLIST.md) — Multi-phase release verification gatekeeper.
* [**CODE_STYLE.md**](./docs/CODE_STYLE.md) — SOLID design rules and coding standards.
* [**CONTRIBUTING.md**](./docs/CONTRIBUTING.md) — Branch strategies, conventional commits, and PR workflow.
* [**CHANGELOG.md**](./docs/CHANGELOG.md) — Release notes following Keep a Changelog.
* [**VERSIONING.md**](./docs/VERSIONING.md) — Semantic Versioning (SemVer 2.0.0) standard.
* [**PRIVACY_POLICY.md**](./docs/PRIVACY_POLICY.md) — In-depth privacy policy and data protection terms.
* [**TERMS_AND_CONDITIONS.md**](./docs/TERMS_AND_CONDITIONS.md) — Commercial terms of service.
* [**SECURITY_POLICY.md**](./docs/SECURITY_POLICY.md) — Security protocols and vulnerability disclosure.
* [**LICENSE.md**](./docs/LICENSE.md) — MIT Open Source License.

---

## ✨ Features

* 🎲 **Polyhedral Dice Roller:** Single and multi-dice (1–6), D4, D6, D8, D10, D12, D20, shake-to-roll physics, and roll history.
* 🪙 **3D Physics Coin Toss:** Fair 50/50 virtual coin flipper, multi-coin mode, and streak probability bar.
* 👥 **Smart Team Generator:** 2 to 8 team partitions with pure random or skill-weighted balancing.
* 📊 **Universal Score Tracker:** Multi-round player scorecard supporting up to 16 players with instant undo/redo.
* 🏏 **Gully Cricket Scorer:** Dedicated ball-by-ball scorer tracking runs, wickets, extras (wides/no-balls), overs, and run rate math.
* 🎡 **Custom Spin Wheel:** Customizable wheel slices, elimination mode, and realistic angular decay physics.
* 🏆 **Tournament Generator:** Automated 4 to 32 team knockout bracket generation with interactive advancement.
* ⏱️ **Game Timers Suite:** Countdown, Stopwatch, Dual Chess Clock with Fischer increments, and audible Turn Timer.
* ℹ️ **Dynamic About & Legal Hub:** Dynamic version/build number display, developer social profiles, and in-app legal docs.

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
*(High-resolution screenshots for 6.7" iPhone and 6.67" Android available in `assets/screenshots/` and documented in [STORE_ASSETS.md](./docs/STORE_ASSETS.md).)*

---

## 🛠️ Technology Stack & Architecture

* **Framework:** Flutter 3.24+ (Stable Channel)
* **Language:** Dart 3.5+ (Sound Null Safety)
* **Architecture:** Clean Architecture + Feature-First Modularity
* **State Management:** Flutter Riverpod 2.6
* **Navigation:** GoRouter 17.3
* **Local Persistence:** Hive 2.2 / Hive Flutter 1.1
* **Metadata & Links:** `package_info_plus`, `url_launcher`, `flutter_linkify`
* **Hardware & Audio:** `sensors_plus`, `audioplayers`
* **Telemetry (Optional):** Firebase Core, Analytics, Crashlytics

---

## 🚀 Installation & Getting Started

### Prerequisites
* Flutter SDK `>= 3.24.0`
* Dart SDK `>= 3.5.0 < 4.0.0`
* JDK 17 (LTS) or JDK 21 (LTS)
* Android Studio (Ladybug+) or Xcode (15+)

### Setup
```bash
# Clone the repository
git clone https://github.com/sundramdotdev/playmate.git
cd playmate

# Install dependencies
flutter pub get

# Generate code models (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run the app in debug mode
flutter run
```

---

## ⚡ Build & Verification Commands

```bash
# Run unit and widget test suite
flutter test

# Run static analysis
dart analyze

# Format code
dart format lib test

# Build Android App Bundle (.aab)
flutter build appbundle --release

# Build iOS App (.ipa)
flutter build ipa --release
```

---

## 👤 Developer Information

Developed with care by **Sundramdotdev**.

* **GitHub:** [https://github.com/sundramdotdev](https://github.com/sundramdotdev)
* **LinkedIn:** [https://linkedin.com/in/sundramdotdev](https://linkedin.com/in/sundramdotdev)
* **Instagram:** [https://www.instagram.com/devsundram_?stkn=dXBva2IwMzZxbHY1](https://www.instagram.com/devsundram_?stkn=dXBva2IwMzZxbHY1)
* **Support Email:** support@playmateapp.com
