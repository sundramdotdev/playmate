# Known Issues & Technical Limitations

This document tracks current limitations, hardware constraints, platform nuances, and known issues within the **PlayMate** codebase as of release **v1.0.0**.

---

## ⚠️ Known Limitations & Hardware Nuances

### 1. Accelerometer Shake Sensitivity Variations
- **Symptom:** On certain Android OEM devices (notably low-end devices with low-cost MEMS sensors), physical wrist shakes may occasionally fail to trigger or require more vigorous motion compared to iOS Taptic/accelerometer hardware.
- **Root Cause:** Android device manufacturers calibrate accelerometer axes and sampling frequencies (`SENSOR_DELAY_GAME` vs `SENSOR_DELAY_UI`) differently.
- **Workaround:** Users can adjust the **Shake Sensitivity** slider in Settings or use the reliable on-screen **"Roll"** button.
- **Target Resolution:** Calibrated dynamic threshold filtering planned for v1.1.0.

### 2. Audio Backgrounding in Timers
- **Symptom:** If the user minimizes the app or turns off the screen while a Countdown Timer is running, standard audio playback can be silenced by aggressive OS battery-saving daemons (e.g., Xiaomi MIUI / Samsung OneUI Battery Optimization).
- **Root Cause:** Full background audio services require specialized foreground service permissions (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`) which consume battery.
- **Workaround:** Keep the screen active or use the on-screen wake-lock toggle while running critical game clocks.
- **Target Resolution:** Optional native foreground notification service planned for v1.2.0.

### 3. Extremely Large Tournament Brackets on Small Displays
- **Symptom:** Generating a 32-player Double-Elimination tournament bracket requires significant horizontal panning and pinching on compact screens under 5 inches.
- **Workaround:** Use landscape orientation or view via tablet.
- **Target Resolution:** Interactive list-based match queue view alongside graphical tree planned for v1.1.0.

---

## 📱 Platform Differences

| Feature | Android Behavior | iOS Behavior |
| :--- | :--- | :--- |
| **Haptic Feedback** | Uses Android `Vibrator` service with calibrated amplitude pulses. | Uses iOS `UIImpactFeedbackGenerator` with crisp Taptic Engine feedback. |
| **System Back Action** | Hardware/gesture back pops current route to home screen. | Interactive edge swipe navigates backward seamlessly. |
| **Audio Routing** | Routes through Android Media stream. | Respects the iOS Silent/Ringer hardware switch unless overridden. |

---

## 🛠️ Minor Non-Critical Bugs Under Investigation

1. **Bug #104 — Spin Wheel Label Truncation:**
   - *Description:* Entering slice labels exceeding 18 characters may cause text truncation on the outer radius of smaller wheels ($< 280\text{dp}$).
   - *Status:* Fix scheduled for patch release `v1.0.1`.
2. **Bug #112 — Coin Flip State Race Condition on Triple Rapid Tap:**
   - *Description:* Extremely fast tapping ($> 10\text{Hz}$) on the flip button can briefly restart the flip sound buffer before the previous flip finishes.
   - *Status:* Debounce logic applied to `coin_provider.dart` in pending PR.
