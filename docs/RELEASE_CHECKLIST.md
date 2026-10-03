# Production Release Checklist

This gatekeeper checklist must be completed and signed off prior to releasing any build of **PlayMate** to the **Google Play Store** or **Apple App Store**.

---

## 🚦 Phase 1: Code Freeze & Version Preparation

- [ ] **Code Freeze Declared:** Merge all approved PRs into `develop` and cut release branch `release/vX.Y.Z`.
- [ ] **Update Version in `pubspec.yaml`:**
  - [ ] Increment version name (e.g., `1.0.1`).
  - [ ] Increment build number (e.g., `+2`).
- [ ] **Synchronize Changelog:**
  - [ ] Ensure [CHANGELOG.md](./CHANGELOG.md) contains accurate release date and full categorized notes (Added, Changed, Fixed).
- [ ] **Regenerate Code Artifacts:**
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 🧪 Phase 2: Code Quality & Automated Test Gate

- [ ] **Static Code Analysis:**
  ```bash
  dart analyze --fatal-infos
  ```
  *(Zero errors, zero warnings permitted)*
- [ ] **Automated Test Suite:**
  ```bash
  flutter test --coverage
  ```
  *(100% test pass rate required)*
- [ ] **Formatting Enforcement:**
  ```bash
  dart format --set-exit-if-changed lib test
  ```

---

## 📱 Phase 3: Visuals, Icons & App Assets

- [ ] **App Launcher Icons:**
  - [ ] Android adaptive icons rendered correctly on square, squircle, and round devices.
  - [ ] iOS icon assets verified at all required scale factors (1024×1024, 180×180, 120×120).
- [ ] **Native Splash Screen:**
  - [ ] Splash screens display correctly without stuttering or white flashes on both Dark and Light modes.
- [ ] **Theme Transitions:**
  - [ ] Verified smooth transition between Dark Mode and Light Mode on real OLED screens.

---

## 🛡️ Phase 4: Security, Legal & Policy Verification

- [ ] **Privacy Policy Updated:** Verified live URL for [PRIVACY_POLICY.md](./PRIVACY_POLICY.md).
- [ ] **Terms & Conditions:** Verified live URL for [TERMS_AND_CONDITIONS.md](./TERMS_AND_CONDITIONS.md).
- [ ] **No Secret Leaks:** Verify `upload-keystore.jks`, `key.properties`, and private auth tokens are excluded via `.gitignore`.
- [ ] **Zero Hardcoded Personal Identifiers:** Confirm analytics payloads contain zero PII.
- [ ] **App Store Data Safety Declarations:**
  - [ ] Google Play Data Safety form accurately reflects zero data sharing.
  - [ ] Apple App Privacy Nutrition labels indicate zero tracking.

---

## 🔍 Phase 5: Device Smoke Testing (Physical Hardware)

- [ ] **Android Smoke Test (Real Device):**
  - [ ] Install release APK/AAB via USB debugging.
  - [ ] Test Dice Roller shake gesture.
  - [ ] Test Coin Toss sound and haptic pulse.
  - [ ] Create 4 teams with 12 players in Team Generator.
  - [ ] Score 1 full cricket over (6 legal balls + 1 wide).
  - [ ] Run Chess Clock for 2 minutes with increment.
  - [ ] Test Data Reset in Settings.
- [ ] **iOS Smoke Test (TestFlight Real Device):**
  - [ ] Verify Taptic Engine vibration response.
  - [ ] Verify audio plays when phone is unmuted.
  - [ ] Test swipe-back gestures on all nested sub-screens.

---

## 🚀 Phase 6: Store Deployment & Production Promotion

- [ ] **Generate Release Bundles:**
  - [ ] Android: `flutter build appbundle --release`
  - [ ] iOS: `flutter build ipa --release`
- [ ] **Upload Artifacts:**
  - [ ] Upload `.aab` to Google Play Console Internal Track.
  - [ ] Upload `.ipa` to App Store Connect TestFlight.
- [ ] **Internal Canary Smoke (24-Hour Soak):**
  - [ ] Zero crash reports in Firebase Crashlytics.
- [ ] **Promote to Production:**
  - [ ] Staged Rollout on Google Play (10% $\rightarrow$ 25% $\rightarrow$ 100%).
  - [ ] App Store release released immediately or scheduled.
- [ ] **Tag Git Release:**
  ```bash
  git tag -a v1.0.0 -m "Production Release v1.0.0"
  git push origin v1.0.0
  ```
