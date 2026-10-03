# PlayMate Product Roadmap

This document outlines the strategic engineering and product roadmap for **PlayMate**. Milestones are structured into distinct architectural phases prioritizing stability, offline capability, utility depth, and seamless expansion.

---

## 🗺️ Milestone Overview

```text
[Phase 1] Architecture & Foundations ───► [Phase 2] Core Utilities (Current v1.0)
                                                    │
                                                    ▼
[Phase 4] Cloud Sync & Backup ◄───────── [Phase 3] Statistics & Historical Insights
         │
         ▼
[Phase 5] Premium Features & Theming ───► [Phase 6] Local P2P Multiplayer & Ecosystem
```

---

## 🚩 Milestone Breakdown

### Phase 1: Architecture & Foundations
**Status:** Completed (v0.1.0 – v0.5.0)  
**Objective:** Establish a high-performance, modular architectural backbone capable of scaling across dozens of offline utilities without tech debt.

- [x] Establish **Clean Architecture** with a strictly decoupled **Feature-First** structure.
- [x] Integrate **Flutter Riverpod 2.6** for reactive, compile-safe dependency injection and state management.
- [x] Implement **GoRouter 17.3** declarative routing supporting URL matching and deep linking.
- [x] Configure **Hive 2.2** persistent on-device binary storage with lazy box loading.
- [x] Implement unified Material 3 design system supporting pure Dark and Light modes.
- [x] Configure abstract service boundaries for audio synthesis (`audioplayers`) and sensor telemetry (`sensors_plus`).

---

### Phase 2: Core Utilities (Current Release)
**Status:** Completed (v1.0.0)  
**Objective:** Deliver 8 essential, rock-solid offline gaming tools that cover the majority of physical game companion use cases.

- [x] **Polyhedral Dice Roller:** D4, D6, D8, D10, D12, D20 dice with shake detection and roll history.
- [x] **Fair Coin Toss:** Physics-based 3D flip animation, multi-coin support, and streak tracking.
- [x] **Intelligent Team Generator:** Fast roster entry, 2–8 team split, random and skill-balanced distribution modes.
- [x] **Universal Score Tracker:** Multi-round player scoreboard with custom increments and undo/redo history.
- [x] **Cricket Scorer:** Over, ball, wicket, and extras tracking tailored for street and club matches.
- [x] **Custom Spin Wheel:** Customizable slices, custom text, angular velocity decay, and winner selection.
- [x] **Tournament Generator:** Automated 4 to 32 team single and double elimination brackets.
- [x] **Game Clock & Timers:** Countdown, Stopwatch, Chess Clock with Fischer bonus, and audible Turn Timer.

---

### Phase 3: Statistics & Historical Insights
**Status:** In Development (Target: v1.1.0 – Q4 2026)  
**Objective:** Transform raw game results into rich analytics, performance metrics, and head-to-head records stored entirely on-device.

- [ ] **Player Career Profiles:** Create permanent local player profiles with custom avatars, nicknames, and bio tags.
- [ ] **Head-to-Head Records:** Detailed win/loss matrices between players across all scored games.
- [ ] **Cricket In-Depth Match Analytics:**
  - Wagon wheel simulation and ball-by-ball run graphs.
  - Batter strike rate calculations, bowler economy rates, and partnership charts.
- [ ] **Dice & Coin Entropy Audit:** Graphical verification showing rolling frequency distributions to prove true fairness to players.
- [ ] **CSV / PDF Match Report Export:** One-tap export of tournament brackets and cricket scorecards for sharing via messaging apps.

---

### Phase 4: Encrypted Cloud Sync & Cross-Device Backup
**Status:** Planned (Target: v1.2.0 – Q1 2027)  
**Objective:** Provide optional, privacy-respecting synchronization without compromising the offline-first guarantee.

- [ ] **Anonymous Firebase Auth:** Enable optional user sign-in using Google Sign-In or Apple ID with zero required personally identifiable information (PII).
- [ ] **End-to-End Encrypted Cloud Firestore Sync:** Sync local Hive boxes to encrypted Cloud Firestore collections.
- [ ] **Conflict Resolution Engine:** Last-Write-Wins (LWW) and merge-conflict resolution protocols for offline edits made across multiple devices.
- [ ] **Manual Local Backup & Restore:** Export and import encrypted JSON/binary backup archives to local device storage, Google Drive, or iCloud Drive.

---

### Phase 5: Premium Features & Customization
**Status:** Planned (Target: v1.3.0 – Q2 2027)  
**Objective:** Introduce aesthetic customization and advanced tournament formats for power users.

- [ ] **Custom 3D Dice Skins:** Metallic, wooden, neon, and gemstone dice rendering.
- [ ] **Custom Soundboard Manager:** Record or upload custom sound effects for dice rolls, buzzers, and victory fanfare.
- [ ] **Advanced Tournament Systems:**
  - Round Robin leagues with automatic points tables and goal/run differentials.
  - Swiss System tournament pairing for chess and card game clubs.
- [ ] **Home Screen Quick Widgets:** Lock screen and Home Screen widgets for instant coin tosses and active timers on iOS and Android.

---

### Phase 6: Local P2P Multiplayer & Wearable Ecosystem
**Status:** Conceptual (Target: v2.0.0 – Q3 2027)  
**Objective:** Expand PlayMate into a local network mesh for synchronized game control across all players' screens.

- [ ] **Local Mesh Spectator Mode:** Broadcast live scoreboard state over Bluetooth Low Energy (BLE) / Wi-Fi Direct to nearby devices without requiring internet access.
- [ ] **Apple Watch & Wear OS Companion Apps:**
  - Wrist-based cricket clicker for recording runs and balls while fielding.
  - Apple Watch haptic turn timer vibration alerts.
- [ ] **Desktop & Large Screen Presentation Mode:** Optimized layouts for macOS, Windows, and iPadOS to display scoreboards on TV monitors or projectors during large game nights.
