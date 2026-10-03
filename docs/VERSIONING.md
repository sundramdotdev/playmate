# Versioning Strategy

**PlayMate** adheres strictly to **Semantic Versioning 2.0.0** ([SemVer](https://semver.org/)) combined with mobile platform build number standards for Google Play Store and Apple App Store.

---

## 📌 Version Format Overview

Our standard versioning string follows the schema:

$$\text{MAJOR}.\text{MINOR}.\text{PATCH} + \text{BUILD\_NUMBER}$$

Example: `1.2.0+15`

| Component | Target Location | Description |
| :--- | :--- | :--- |
| **MAJOR** | Public Version Name | Incremented when incompatible architectural changes, breaking schema shifts, or complete UI/UX overhauls occur. |
| **MINOR** | Public Version Name | Incremented when new backward-compatible features, utilities, or major enhancements are added. |
| **PATCH** | Public Version Name | Incremented for backward-compatible bug fixes, minor performance improvements, or UI polish. |
| **BUILD_NUMBER** | Monotonically Increasing Integer | Platform build identifier (`versionCode` on Android, `CFBundleVersion` on iOS) required by store ingestion pipelines. |

---

## 🔢 Version Classification Criteria

### 1. Major Releases (`X.0.0`)
A Major version bump indicates fundamental, breaking, or transformative changes to the application:
- **Breaking Hive Schema Migrations:** Fundamental structural modifications to local database models requiring non-trivial migration scripts.
- **State Architecture Migrations:** Fundamental rewrite of state management or navigation routing layers.
- **Large-Scale Rebranding:** Complete redesign of the app identity, design system, or core navigation hierarchy.
- **Minimum OS Deprecations:** Elevating minimum SDK requirements (e.g., dropping Android 6.0 or iOS 14 support).

### 2. Minor Releases (`1.X.0`)
A Minor version bump introduces substantial, backward-compatible additions:
- Addition of a brand new game utility (e.g., adding a Carrom or Poker chip tracker).
- Introducing a major feature within an existing module (e.g., adding Double Elimination to Tournaments).
- Introducing major platform integrations (e.g., Apple Watch companion app, tablet split-pane view).

### 3. Patch Releases (`1.0.X`)
A Patch release addresses issues without changing functionality scope:
- Bug fixes and defect remediation.
- Layout overflow fixes on specific screen aspect ratios.
- Audio and haptic latency tuning.
- Dependency security updates that introduce no API breaks.

### 4. Hotfix Releases (`1.0.X+hotfix`)
A Hotfix is an urgent, expedited patch released directly from the `main` branch to address severe production anomalies:
- App crash-on-launch affecting any subset of devices.
- Severe data corruption bug in Hive database write routines.
- App store policy compliance emergencies.

---

## 🏷️ Pre-Release Stages & Identifiers

For development and testing phases prior to general public availability, pre-release suffixes are appended to the version string:

```text
MAJOR.MINOR.PATCH-PRERELEASE+BUILD
```

### 1. Alpha (`-alpha.N`)
* **Target Audience:** Core internal engineering and UX team.
* **Format:** `1.1.0-alpha.1+101`
* **Stability:** Experimental. Features may be partially implemented, APIs may shift, and mock services may be active.

### 2. Beta (`-beta.N`)
* **Target Audience:** Internal QA team, company stakeholders, and opt-in closed testers via Google Play Internal Testing and Apple TestFlight.
* **Format:** `1.1.0-beta.2+105`
* **Stability:** Feature complete. Focused on usability validation, device compatibility testing, and bug hunting.

### 3. Release Candidate (`-rc.N`)
* **Target Audience:** Open Beta community and release management.
* **Format:** `1.1.0-rc.1+110`
* **Stability:** Production-candidate. No code changes are permitted except critical show-stopping bug fixes. If an RC passes a 72-hour zero-critical-issue burn-in period, it is promoted directly to public release.

---

## 📱 Mobile Platform Mapping

Flutter synchronizes `pubspec.yaml` with the native Android and iOS configuration via `flutter build`:

| `pubspec.yaml` | Android (`android/app/build.gradle.kts`) | iOS (`ios/Runner/Info.plist`) | App Store Display |
| :--- | :--- | :--- | :--- |
| `1.0.0+1` | `versionName: "1.0.0"`, `versionCode: 1` | `CFBundleShortVersionString: 1.0.0`, `CFBundleVersion: 1` | **Version 1.0.0** |
| `1.0.1+2` | `versionName: "1.0.1"`, `versionCode: 2` | `CFBundleShortVersionString: 1.0.1`, `CFBundleVersion: 2` | **Version 1.0.1** |
| `1.1.0+3` | `versionName: "1.1.0"`, `versionCode: 3` | `CFBundleShortVersionString: 1.1.0`, `CFBundleVersion: 3` | **Version 1.1.0** |

> [!IMPORTANT]
> The `BUILD_NUMBER` must **never decrease or remain identical** between consecutive uploads to Google Play Console or Apple App Store Connect. CI/CD pipelines automatically increment the build number with each commit to the `release/*` branch.

---

## 🌿 Git Tagging Conventions

Every release that reaches TestFlight, Google Play, or Production must have a corresponding signed Git tag created in the repository:

```bash
# Tagging a stable production release
git tag -a v1.0.0 -m "Release v1.0.0 (Build 1) - Production Launch"
git push origin v1.0.0

# Tagging a release candidate
git tag -a v1.1.0-rc.1 -m "Release Candidate 1 for v1.1.0 (Build 12)"
git push origin v1.1.0-rc.1
```
