# PlayMate Design System

This document outlines the visual language, design tokens, UI components, and accessibility guidelines that define **PlayMate**. The design system is built upon **Material Design 3 (M3)** with custom refinements designed for high legibility, tactile gaming interaction, and contrast precision.

---

## 🎨 Design Philosophy: Sleek & Tactile Minimalist

PlayMate adopts a **Sleek Charcoal & Clean White** aesthetic:
- **Zero Visual Noise:** In games where quick glances matter (reading dice totals or counting cricket runs in bright sunlight), clutter is eliminated.
- **High Information Density with Generous Touch Targets:** All touch targets meet or exceed 48×48dp, even when data is compactly presented.
- **Tactile Feedback:** Every interactive visual state is paired with micro-animations and physical haptic pulses.

---

## 🌈 Color Palette & Tokens

The palette is derived from an ultra-modern monochromatic seed (`#1A1A1A`), with carefully calibrated secondary and surface layers for both Light and Dark themes.

### Light Theme Palette

| Token Name | Hex Value | Color Preview | Usage |
| :--- | :--- | :---: | :--- |
| `primary` | `#1A1A1A` | ![#1A1A1A](https://via.placeholder.com/15/1A1A1A/000000?text=+) | Primary brand color, primary actions, active headers |
| `onPrimary` | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | Text and icons on primary container |
| `secondary` | `#757575` | ![#757575](https://via.placeholder.com/15/757575/000000?text=+) | Secondary subtitles, helper labels, passive borders |
| `surface` | `#F9F9F9` | ![#F9F9F9](https://via.placeholder.com/15/F9F9F9/000000?text=+) | Neutral surface backgrounds |
| `cardSurface` | `#F5F5F5` | ![#F5F5F5](https://via.placeholder.com/15/F5F5F5/000000?text=+) | Card background containers |
| `borderDefault`| `#E0E0E0` | ![#E0E0E0](https://via.placeholder.com/15/E0E0E0/000000?text=+) | 1px clean card and divider outlines |
| `scaffoldBg` | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | Screen scaffold background |

### Dark Theme Palette

| Token Name | Hex Value | Color Preview | Usage |
| :--- | :--- | :---: | :--- |
| `primary` | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF/000000?text=+) | High-emphasis headers, active buttons |
| `onPrimary` | `#121212` | ![#121212](https://via.placeholder.com/15/121212/000000?text=+) | Dark icons/text on primary buttons |
| `secondary` | `#8E8E93` | ![#8E8E93](https://via.placeholder.com/15/8E8E93/000000?text=+) | Secondary text and disabled states |
| `surface` | `#1E1E1E` | ![#1E1E1E](https://via.placeholder.com/15/1E1E1E/000000?text=+) | Elevated panels and bottom sheets |
| `cardSurface` | `#1E1E1E` | ![#1E1E1E](https://via.placeholder.com/15/1E1E1E/000000?text=+) | Grid utility card container background |
| `borderDefault`| `#2C2C2C` | ![#2C2C2C](https://via.placeholder.com/15/2C2C2C/000000?text=+) | 1px subdued dark mode borders |
| `scaffoldBg` | `#121212` | ![#121212](https://via.placeholder.com/15/121212/000000?text=+) | Deep true-black OLED background |

---

## 🔤 Typography Hierarchy

The app uses standard system fonts (San Francisco on iOS, Roboto on Android) to guarantee zero-latency font rendering and native OS integration.

| Style Role | Font Size | Font Weight | Letter Spacing | Context / Usage |
| :--- | :---: | :---: | :---: | :--- |
| `headlineLarge` | 32sp | Bold (700) | -0.5px | Large numeric displays (e.g., dice roll totals, cricket score tallies) |
| `headlineMedium`| 24sp | Bold (700) | -0.5px | Screen header banners, winner announcements |
| `titleLarge` | 18sp | Semi-Bold (600) | 0.0px | Dashboard card titles, modal dialog headers |
| `bodyLarge` | 16sp | Regular (400) | 0.15px | Primary text, player names in scorecards |
| `bodyMedium` | 14sp | Regular (400) | 0.25px | Tool descriptions, timestamps, metadata |
| `labelLarge` | 14sp | Bold (700) | 0.1px | Button call-to-actions, chips, tabs |

---

## 📐 Spacing & Layout Tokens

Spacing follows an **8-point grid** scale to maintain rhythmic alignment:

```dart
class AppSpacing {
  static const double xs = 4.0;   // Micro padding, badge offsets
  static const double s  = 8.0;   // Element grouping, chip padding
  static const double m  = 16.0;  // Standard screen margin, card padding
  static const double l  = 24.0;  // Section separators
  static const double xl = 32.0;  // Hero visual margins
}
```

---

## 🧩 UI Component Specifications

### 1. Cards
- **Geometry:** 12dp rounded corners (`BorderRadius.circular(12)`).
- **Elevation:** Flat (`elevation: 0`).
- **Borders:** 1px solid stroke (`Color(0xFFE0E0E0)` in light mode, `Color(0xFF2C2C2C)` in dark mode).
- **Interaction:** Integrated `InkWell` splash effect with bounding border radius.

### 2. Action Buttons
- **Primary Buttons:** High-contrast pill/rounded rectangle with 12dp radius, min height 52dp, bold text.
- **Keypad Buttons (Cricket & Scores):** High-touch tactile square buttons (64×64dp) with distinct colored badges for boundaries (4s and 6s) and wickets (red).
- **Haptic Association:** All button taps trigger `HapticFeedback.lightImpact()`.

### 3. Modals & Dialogs
- **Confirmation Sheets:** Bottom sheet modal anchored to screen bottom with draggable handle pill.
- **Quick Input Dialogs:** Centered alert dialog with autoselected numeric text fields and direct "OK" / "Cancel" actions.

---

## 📱 Responsive & Adaptive Design

PlayMate adapts across three layout classes via `ResponsiveLayout`:

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  // Breakpoints:
  // Compact Mobile: < 600dp width (2-column card grid)
  // Tablet: 600dp – 1024dp (3-to-4 column grid or split-pane view)
  // Desktop/Landscape: > 1024dp (multi-column dashboard)
}
```

---

## ♿ Accessibility (a11y) Standards

1. **WCAG 2.1 AAA Contrast:** All textual elements maintain a contrast ratio $> 7:1$ against their respective backgrounds in both Light and Dark themes.
2. **Screen Reader (Semantics):** Every icon button provides a descriptive `tooltip` and `Semantics(label: "...")` tag.
3. **Dynamic Font Scaling:** UI containers use flexible constraints (`Flexible`, `Expanded`, `FittedBox`) to prevent layout clipping when users increase OS font scaling up to 200%.
4. **Haptic & Visual Redundancy:** Sound cues are always mirrored by physical haptic vibration and on-screen animation for hearing-impaired users.

---

## 🏷️ Reusable Widget Guidelines & Naming Conventions

- **Component Names:** Always postfix custom widgets with their functional role (e.g., `DiceDisplayCard`, `TeamRosterTile`, `CricketKeypadButton`).
- **Stateless by Default:** Presentation components should remain `StatelessWidget` or `ConsumerWidget` with state handled exclusively through Riverpod notifiers.
