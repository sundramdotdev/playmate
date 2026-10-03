# Store Assets & Visual Guidelines

This guide specifies the exact graphic dimensions, visual assets, framing guidelines, and metadata requirements for submitting **PlayMate** to the **Google Play Store** and **Apple App Store**.

---

## 🤖 Google Play Store Asset Specifications

### 1. App Icon
- **Dimensions:** $512 \times 512\text{ px}$
- **Format:** 32-bit PNG (with alpha channel)
- **Max File Size:** 1024 KB
- **Design Guidelines:** Flat charcoal background (`#1A1A1A`) with bold, clean white die and game trophy silhouette. No drop shadows outside the icon boundary.

### 2. Feature Graphic
- **Dimensions:** $1024 \times 500\text{ px}$
- **Format:** JPEG or 24-bit PNG (no alpha)
- **Max File Size:** 15 MB
- **Visual Composition:** 
  - Left 60%: High-contrast typographic hero headline (*"Everything You Need For Offline Games"*).
  - Right 40%: Isometric 3D mockups of the dice, coin, and cricket scorecard interface.
  - Safe Zone: Keep critical brand text centered within the middle $800 \times 400\text{ px}$ to avoid clipping across Android TV or tablet banners.

### 3. Screenshots (Phone & Tablet)
- **Minimum Upload:** At least 4 screenshots (Max 8).
- **Format:** 16:9 or 9:16 aspect ratio (recommended: $1080 \times 2400\text{ px}$ or $1440 \times 3200\text{ px}$).
- **Required Slides:**
  1. **Slide 1:** Home Dashboard Grid — *"All Your Game Utilities In One Place"*
  2. **Slide 2:** Polyhedral Dice Roller — *"D4 to D20. Shake To Roll!"*
  3. **Slide 3:** 3D Coin Toss — *"Fair 50/50 Flips with Haptic Clinks"*
  4. **Slide 4:** Gully Cricket Scorer — *"Ball-by-Ball Tracking & Run Rate Math"*
  5. **Slide 5:** Universal Score Tracker — *"Multi-Player Rounds with One-Tap Undo"*
  6. **Slide 6:** Team Generator — *"Instant Balanced Squads for Any Sport"*

---

## 🍎 Apple App Store Asset Specifications

### 1. App Store Icon
- **Dimensions:** $1024 \times 1024\text{ px}$
- **Format:** PNG (no transparency / alpha strictly prohibited)
- **Color Space:** Display P3 or sRGB

### 2. Required Screenshot Formats
| Device Class | Resolution | Display Size | Orientation |
| :--- | :--- | :--- | :--- |
| **iPhone 6.7" Super Retina** | $1290 \times 2796\text{ px}$ | iPhone 15 Pro Max / 16 Pro Max | Portrait |
| **iPhone 6.5" Super Retina** | $1242 \times 2688\text{ px}$ | iPhone 11 Pro Max / XS Max | Portrait |
| **iPad Pro 12.9" (6th Gen)** | $2048 \times 2732\text{ px}$ | iPad Pro (12.9-inch) | Portrait |

---

## 🏷️ Privacy Nutrition Labels & Data Safety

### Apple App Store Privacy Nutrition Label

| Category | Data Collected | Linked to Identity? | Used for Tracking? |
| :--- | :--- | :---: | :---: |
| **Diagnostics** | Crash Data & Performance Metrics | No | No |
| **Usage Data** | Product Interaction (Aggregated counters) | No | No |
| **Contact Info**| None | No | No |
| **Location** | None | No | No |

*Verdict:* **Data Not Linked to You** / **No Tracking**.

---

### Google Play Data Safety Form

1. **Does your app collect or share user data?** Yes (Diagnostics only).
2. **Is all of the user data collected by your app encrypted in transit?** Yes (TLS 1.3).
3. **Do you provide a way for users to request that their data be deleted?** Yes (In-app one-tap data reset + email request).
4. **Data Types:**
   - *App Info and Performance:* Crash logs, diagnostics.
   - *App Activity:* App interactions (aggregated counts of dice rolled/coins tossed).
