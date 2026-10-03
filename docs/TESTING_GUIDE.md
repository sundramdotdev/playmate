# Testing & Quality Assurance Guide

This guide establishes the comprehensive testing and quality assurance methodology for **PlayMate**, ensuring high reliability, zero runtime crashes, and consistent performance across diverse mobile hardware.

---

## 🧪 Testing Pyramid Overview

```text
               ▲
              / \
             /   \     End-to-End & Integration (10%)
            /  E2E\    Full user journeys & sensor mocks
           /───────\
          / Widget  \   Widget & Golden Tests (30%)
         /   Tests   \  Component rendering & UI interactions
        /─────────────\
       /  Unit Tests   \  Unit Tests (60%)
      /                 \ Pure domain logic, notifiers & algorithms
     /───────────────────\
```

---

## 1. Unit Testing

Unit tests focus on state machines, game algorithms, and mathematical logic without spinning up the Flutter rendering engine.

### Key Targets:
- Team generation partitioning algorithms (edge cases: odd numbers, empty inputs, single player).
- Cricket scoring run rate math (over division, legal balls calculation).
- Dice randomness distribution.
- Tournament bracket tree advancement.

### Example Unit Test (`test/features/cricket_test.dart`):

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cricket Scoring Logic', () {
    test('Calculates run rate accurately', () {
      int runs = 45;
      int legalBalls = 30; // 5.0 overs

      double overs = (legalBalls ~/ 6) + ((legalBalls % 6) / 6.0);
      double runRate = runs / overs;

      expect(runRate, equals(9.0));
    });

    test('Wides do not increment legal ball count', () {
      int legalBalls = 10;
      bool isWide = true;

      if (!isWide) {
        legalBalls++;
      }

      expect(legalBalls, equals(10));
    });
  });
}
```

---

## 2. Widget Testing

Widget tests verify user interaction, widget tree construction, and reactive updates from Riverpod providers.

### Key Practices:
- Always wrap widgets in `ProviderScope` with appropriate overrides.
- Use `tester.pumpAndSettle()` for animations.

### Example Widget Test (`test/features/dice_screen_test.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playmate/features/dice/dice_screen.dart';

void main() {
  testWidgets('DiceScreen displays roll action button and total', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DiceScreen(),
        ),
      ),
    );

    // Verify initial layout elements
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Roll'), findsOneWidget);

    // Tap the roll button
    await tester.tap(find.textContaining('Roll'));
    await tester.pumpAndSettle();

    // Verify state was rendered
    expect(find.byType(Card), findsWidgets);
  });
}
```

---

## 3. Golden Testing

Golden tests capture pixel-accurate visual snapshots across Light and Dark themes to protect against inadvertent UI regressions.

```bash
# Update golden files baseline
flutter test --update-goldens
```

Golden test assertions compare rendered widgets against golden raster images stored in `test/goldens/`.

---

## 4. Integration Testing (`integration_test`)

Integration tests run directly on real Android and iOS devices to validate end-to-end user journeys:
1. Launch app $\rightarrow$ Open Coin Toss $\rightarrow$ Flip Coin $\rightarrow$ Navigate back to Home.
2. Open Team Generator $\rightarrow$ Enter 10 names $\rightarrow$ Generate 2 teams $\rightarrow$ Assert 5 members per team.

### Running Integration Tests:
```bash
flutter test integration_test/app_flow_test.dart -d <device_id>
```

---

## 5. Manual QA & Device Matrix

Before any production release, physical devices spanning different form factors and OS versions must be tested:

| Device Category | Target Devices | Screen Spec | Focus Areas |
| :--- | :--- | :--- | :--- |
| **Compact Android** | Pixel 4a / Samsung Galaxy A13 | 5.8", 1080×2340, Android 11 | Font overflow, bottom button clipping |
| **Standard Android** | Pixel 8 / Samsung Galaxy S23 | 6.2", 1080×2400, Android 14 | 120Hz smooth animations, gesture navigation |
| **Large/Foldable** | Galaxy Z Fold 5 / Pixel Tablet | 7.6", 1812×2176, Android 14 | Responsive grid layout adaptability |
| **Compact iOS** | iPhone SE (3rd Gen) | 4.7", 750×1334, iOS 16 | Small viewport scrolling, home button nav |
| **Modern iOS** | iPhone 15 Pro / 16 Pro Max | 6.1" & 6.9", Dynamic Island, iOS 17/18 | Safe area insets, ProMotion 120fps |

---

## 6. Performance & Battery Testing

### Profiling Render Frame Rates
Run the app in profile mode to measure rendering performance:
```bash
flutter run --profile
```
- **Frame Budget:** Target 60fps (16.6ms per frame) or 120fps (8.3ms per frame) on ProMotion displays.
- **Sensor Stream Optimization:** Ensure accelerometer streams from `sensors_plus` are paused when the user navigates away from the Dice Roller to conserve battery life.

### Memory Leak Profiling
1. Open Flutter DevTools:
   ```bash
   dart devtools
   ```
2. Navigate between all 8 tools 20 times in succession.
3. Verify that memory consumption stabilizes without upward drift.
