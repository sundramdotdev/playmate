# Firebase Integration & Configuration Guide

This document describes how Firebase is integrated into **PlayMate**, how environments are configured, and the step-by-step setup procedure for production and staging builds.

---

## ⚡ Overview & Offline-First Decoupling

PlayMate uses Firebase strictly as an **optional telemetry and secondary cloud sync layer**:
- If Firebase is not configured or network access is offline, the app operates at 100% functionality using local fallbacks.
- Development builds mock the Firebase service by default (`FirebaseService.initialize()`), ensuring developers can clone and run the app instantly without needing confidential keys.

---

## 📦 Enabled Firebase Services

| Service | Purpose | Offline Behavior |
| :--- | :--- | :--- |
| **Firebase Analytics** | Aggregated telemetry on tool usage and user journey friction. | Queued locally by Google Play Services / iOS SDK; flushed on next connection. |
| **Firebase Crashlytics** | Real-time crash logging, non-fatal exception reports, and stack traces. | Written to local disk cache; uploaded immediately upon network recovery. |
| **Cloud Firestore** | (Phase 4 Roadmap) Encrypted cloud backup of matches and custom rosters. | Completely bypassed; Hive serves as single source of truth. |
| **Firebase Auth** | (Phase 4 Roadmap) Optional anonymous & social authentication. | Local guest mode is default; no login required. |
| **Remote Config** | Feature flags, version deprecation alerts, and seasonal promotional text. | Cached defaults loaded from bundled assets if offline. |

---

## 🛠️ Step-by-Step Project Setup

### 1. Create Projects in Firebase Console
Create two distinct Firebase projects:
- `playmate-app-dev` (Development & QA staging)
- `playmate-app-prod` (Official Production release)

### 2. Configure Android App
1. Register Android Package: `com.sundramdotdev.playmate` (or custom commercial package e.g. `com.playmate.offline`).
2. Add your **SHA-1** and **SHA-256** fingerprint hashes (for debug and production keystores).
3. Download the generated `google-services.json`.
4. Place the file at:
   ```text
   android/app/google-services.json
   ```
5. Ensure `android/build.gradle.kts` has the Google Services dependency:
   ```kotlin
   plugins {
       id("com.google.gms.google-services") version "4.4.2" apply false
       id("com.google.firebase.crashlytics") version "3.0.2" apply false
   }
   ```
6. In `android/app/build.gradle.kts`, apply the plugins:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services")
       id("com.google.firebase.crashlytics")
   }
   ```

### 3. Configure iOS App
1. Register iOS Bundle Identifier: `com.sundramdotdev.playmate` (or `com.playmate.offline`).
2. Add your App Store ID and Team ID.
3. Download `GoogleService-Info.plist`.
4. Open the Xcode workspace (`ios/Runner.xcworkspace`) and drag `GoogleService-Info.plist` into `Runner/` (ensure *Copy items if needed* is checked).

---

## 🔐 Environment Configuration

To keep production keys out of public repositories, environment-specific configuration files can be passed via Flutter compile-time arguments or flavor configurations:

```bash
# Running with Dev Firebase
flutter run --dart-define=ENVIRONMENT=dev

# Building Production Release
flutter build appbundle --release --dart-define=ENVIRONMENT=prod
```

### Application Bootstrap Code (`lib/services/firebase_service.dart`)

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      if (kIsWeb || !kReleaseMode) {
        // Optional: Local mock during development
        debugPrint("Firebase: Initialized in development mode (Mocked/Safe)");
        return;
      }

      await Firebase.initializeApp();
      
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      debugPrint("Firebase: Production initialization successful");
    } catch (e) {
      debugPrint("Firebase initialization suppressed: $e");
    }
  }
}
```

---

## 🔒 Security Rules (Cloud Firestore - Phase 4)

When Cloud Firestore sync is enabled, strict user-scoped security rules are applied:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Matches and game records are strictly confined to the owning authenticated user
    match /users/{userId}/matches/{matchId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Custom tournament brackets
    match /users/{userId}/tournaments/{tournamentId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Default deny all other paths
    match /{document=**} {
      allow read, write: false;
    }
  }
}
```

---

## 🚀 Deployment Instructions

To deploy security rules and remote config defaults via Firebase CLI:

```bash
# Login to Firebase
firebase login

# Set active project
firebase use playmate-app-prod

# Deploy Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes

# Deploy Remote Config template
firebase deploy --only remoteconfig
```
