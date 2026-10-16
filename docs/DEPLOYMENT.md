# Deployment & Release Engineering Guide

This document is the operational playbook for building, signing, and deploying **PlayMate** to the **Google Play Store** and **Apple App Store**.

---

## 🏗️ Pre-Requisite Environments

Before starting a production release:
1. Ensure the working tree is clean on the `release/*` or `main` branch.
2. Flutter SDK: `>= 3.24.0`
3. JDK: `17` or `21` configured in environment (`JAVA_HOME`).
4. Xcode: `>= 15.0` with command-line tools installed.
5. Fastlane (optional, for automated pipelines).

---

## 🤖 Android Deployment Pipeline

### 1. Keystore Generation (One-Time Setup)
Generate a 2048-bit RSA upload key using `keytool`:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias playmate-upload-key
```

### 2. Configure Keystore Credentials
Create a private `android/key.properties` file (ensure this is added to `.gitignore`):

```properties
storePassword=YOUR_SECURE_STORE_PASSWORD
keyPassword=YOUR_SECURE_KEY_PASSWORD
keyAlias=playmate-upload-key
storeFile=../upload-keystore.jks
```

### 3. Update `android/app/build.gradle.kts`
Configure the release signing configuration:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 4. Build Production Android App Bundle (.aab)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
The output bundle will be located at:
```text
build/app/outputs/bundle/release/app-release.aab
```

### 5. Google Play Console Release Flow
1. Navigate to **Google Play Console** $\rightarrow$ **PlayMate** $\rightarrow$ **Release** $\rightarrow$ **Testing** $\rightarrow$ **Internal testing**.
2. Click **Create new release** and upload `app-release.aab`.
3. Provide Release Notes (from [CHANGELOG.md](./CHANGELOG.md)).
4. Promote from **Internal Testing** $\rightarrow$ **Closed Testing** $\rightarrow$ **Production**.

---

## 🍎 iOS Deployment Pipeline

### 1. Apple Developer Portal Setup
1. Create App Identifier: `com.sundramdotdev.playmate` (matching application bundle ID).
2. Generate an **Apple Distribution Certificate** in Xcode or Apple Developer Portal.
3. Create an **App Store Provisioning Profile** tied to the App ID and Certificate.

### 2. Xcode Configuration
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select target **Runner** $\rightarrow$ **Signing & Capabilities**.
3. Select your registered Team and check **Automatically manage signing**.
4. Set **Bundle Identifier** to matching ID.

### 3. Build Signed IPA via Flutter CLI
```bash
flutter clean
flutter pub get
flutter build ipa --release
```
The output archive and `.ipa` file will be generated at:
```text
build/ios/archive/Runner.xcarchive
build/ios/ipa/PlayMate.ipa
```

### 4. Upload to App Store Connect
Upload the `.ipa` using Xcode Organizer or via command-line `altool` / Transporter:

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/PlayMate.ipa \
  -u "YOUR_APPLE_ID" \
  -p "YOUR_APP_SPECIFIC_PASSWORD"
```

### 5. App Store Connect & TestFlight
1. Go to [App Store Connect](https://appstoreconnect.apple.com/) $\rightarrow$ **Apps** $\rightarrow$ **PlayMate**.
2. Under **TestFlight**, monitor processing until status turns to **Ready to Submit**.
3. Distribute to internal testers first for smoke testing.
4. Prepare App Store submission: add metadata, screenshots, and age rating from [STORE_LISTING.md](./STORE_LISTING.md).

---

## 🔢 Version Code & Version Name Ingestion

Both platforms read their version numbers directly from `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

During automated builds, inject build increments using CLI arguments:

```bash
# Android Release with explicit build parameters
flutter build appbundle --release --build-name=1.0.1 --build-number=2

# iOS Release with explicit build parameters
flutter build ipa --release --build-name=1.0.1 --build-number=2
```

---

## 🚀 Fastlane Automation Script Example (`Fastfile`)

```ruby
default_platform(:android)

platform :android do
  desc "Build and upload to Google Play Internal track"
  lane :internal do
    sh("flutter build appbundle --release")
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    sh("flutter build ipa --release")
    upload_to_testflight(
      ipa: '../build/ios/ipa/PlayMate.ipa'
    )
  end
end
```
