# Security Policy & Vulnerability Disclosure

Security and user trust are fundamental pillars of **PlayMate**. This policy outlines our internal security protocols, data protection standards, and guidelines for responsible vulnerability disclosure.

---

## 🛡️ Supported Versions

We actively provide security patches for the following versions:

| Version | Supported | Maintenance Level |
| :--- | :---: | :--- |
| `1.0.x` | ✅ Yes | Full active security and bug fix updates |
| `< 1.0.0` | ❌ No | Deprecated development prototypes |

---

## 🔒 Data Security Architecture

### 1. OS-Level Application Sandboxing
PlayMate operates entirely within the native sandboxed storage boundaries enforced by Android and iOS:
- **Android:** App data is written to private internal storage (`/data/data/com.example.playmate/`), preventing access by other installed applications without root privileges.
- **iOS:** Storage is restricted to the private application container (`Application Support` and `Documents` directory), shielded by iOS hardware encryption.

### 2. Local Database Security & Hive Encryption
- Settings and temporary counters reside in standard binary Hive boxes.
- For sensitive tournament records or future authenticated cloud records, Hive supports AES-256 binary encryption using keys securely stored in the **Android Keystore** or **iOS Keychain**:
  ```dart
  import 'package:hive/hive.dart';
  import 'dart:convert';
  import 'dart:typed_data';

  Future<Box> openSecureBox(String boxName, Uint8List encryptionKey) async {
    return await Hive.openBox(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
  ```

### 3. Network & Transport Layer Security (TLS)
- All network interactions with Firebase Analytics and Crashlytics enforce **TLS 1.3** with strict certificate verification.
- Cleartext HTTP traffic is disabled at the native platform manifest level:
  - Android: `android:usesCleartextTraffic="false"`
  - iOS: `NSAppTransportSecurity` requires HTTPS.

---

## 🔍 Dependency Management & Automated Audits

1. **Regular Patching:** Dependencies are monitored continuously using `flutter pub outdated` and automated GitHub Dependabot alerts.
2. **Static Analysis & Secret Scanning:** Continuous integration scans for accidental credential commits (e.g., Google service secrets, keystores) via pre-commit hooks and GitGuardian scanning.

---

## 🚨 Reporting a Vulnerability

We value the security research community and encourage responsible disclosure of potential security vulnerabilities.

### Submission Process
If you discover a security vulnerability in PlayMate:
1. **Do not disclose the issue publicly** (e.g., in GitHub public issues or social media).
2. Email your findings directly to our security engineering team at:
   **`security@playmateapp.com`**
3. Include the following details in your report:
   - Detailed description of the vulnerability.
   - Proof of Concept (PoC) code or step-by-step reproduction instructions.
   - Affected device model, OS version, and app version.
   - Potential impact assessment.

### Our Commitment
- **Acknowledgment:** We will acknowledge receipt of your vulnerability report within **48 hours**.
- **Assessment:** We will confirm the vulnerability and provide a status update within **5 business days**.
- **Remediation:** We commit to releasing a patch within **30 days** of verification for high-severity issues.
- **Credit:** We will publicly acknowledge your contribution in our release notes (unless you request anonymity).
