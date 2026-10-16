import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:playmate/core/theme.dart';
import 'package:playmate/features/spin_wheel/playmate_spin_wheel.dart';
import 'package:playmate/features/spin_wheel/spin_wheel_math.dart';
import 'package:playmate/features/spin_wheel/spin_wheel_models.dart';
import 'package:playmate/features/spin_wheel/spin_wheel_provider.dart';
import 'package:playmate/features/spin_wheel/spin_wheel_screen.dart';
import 'package:playmate/features/spin_wheel/wheel_pointer.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_spin_wheel');
    await Hive.openBox('settings');
    await Hive.openBox('matches');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Spin Wheel Mathematics & Determinism', () {
    test('getSweepAngle accurately divides full circle by segment count', () {
      expect(SpinWheelMath.getSweepAngle(4), closeTo(math.pi / 2, 0.0001));
      expect(SpinWheelMath.getSweepAngle(6), closeTo(math.pi / 3, 0.0001));
      expect(SpinWheelMath.getSweepAngle(8), closeTo(math.pi / 4, 0.0001));
    });

    test('calculateTargetRotation places winning sector center exactly at Top pointer for all N', () {
      for (int count = 2; count <= 12; count++) {
        for (int winningIndex = 0; winningIndex < count; winningIndex++) {
          final target = SpinWheelMath.calculateTargetRotation(
            currentRotation: 0.0,
            winningIndex: winningIndex,
            count: count,
            revolutions: 6,
          );

          // Sector center angle on unrotated wheel: -pi/2 + (winningIndex + 0.5) * sweep
          // When rotated by target, the position of that sector center in screen space is:
          // centerAngle + target
          final sweep = SpinWheelMath.getSweepAngle(count);
          final centerAngle = -math.pi / 2 + (winningIndex + 0.5) * sweep;
          final finalScreenAngle = (centerAngle + target) % (2 * math.pi);

          // Pointer is at -pi/2, which is 3*pi/2 mod 2pi
          final expectedPointer = (-math.pi / 2) % (2 * math.pi);
          final diff = (finalScreenAngle - expectedPointer).abs() % (2 * math.pi);
          final shortestDist = math.min(diff, 2 * math.pi - diff);

          expect(
            shortestDist,
            lessThan(0.0001),
            reason: 'Failed for count=$count, winningIndex=$winningIndex',
          );
        }
      }
    });

    test('getIndexUnderPointer accurately retrieves sector under pointer for any rotation', () {
      const count = 4;
      for (int i = 0; i < count; i++) {
        final rot = SpinWheelMath.calculateTargetRotation(
          currentRotation: 0.0,
          winningIndex: i,
          count: count,
          revolutions: 5,
        );
        final detected = SpinWheelMath.getIndexUnderPointer(rotation: rot, count: count);
        expect(detected, equals(i));
      }
    });

    test('Curated palettes guarantee contrast for odd and even segment counts', () {
      for (int count = 2; count <= 10; count++) {
        for (int i = 0; i < count; i++) {
          final lightColor = SpinWheelMath.getSegmentColor(i, count, false);
          final darkColor = SpinWheelMath.getSegmentColor(i, count, true);
          expect(lightColor, isNotNull);
          expect(darkColor, isNotNull);

          final lightTextColor = SpinWheelMath.getTextColorForSegment(lightColor, false);
          final darkTextColor = SpinWheelMath.getTextColorForSegment(darkColor, true);
          expect(lightTextColor, isNotNull);
          expect(darkTextColor, isNotNull);
        }
      }
    });
  });

  group('Spin Wheel Riverpod Notifier & State', () {
    test('Initial state loads Truth or Dare preset with at least 4 options', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(spinWheelProvider);
      expect(state.options.length, greaterThanOrEqualTo(4));
      expect(state.isSpinning, isFalse);
      expect(state.selectedWinner, isNull);
    });

    test('Add, update, and remove options maintain minimum 2 options constraint', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(spinWheelProvider.notifier);

      // Add option
      notifier.addOption('New Option');
      expect(container.read(spinWheelProvider).options.any((o) => o.label == 'New Option'), isTrue);

      // Update option
      final opt = container.read(spinWheelProvider).options.firstWhere((o) => o.label == 'New Option');
      notifier.updateOption(opt.id, 'Updated Option');
      expect(container.read(spinWheelProvider).options.any((o) => o.label == 'Updated Option'), isTrue);

      // Attempt to remove down to below 2 options
      while (container.read(spinWheelProvider).options.length > 2) {
        notifier.removeOptionById(container.read(spinWheelProvider).options.first.id);
      }
      expect(container.read(spinWheelProvider).options.length, equals(2));

      // Cannot remove below 2
      final remainingId = container.read(spinWheelProvider).options.first.id;
      notifier.removeOptionById(remainingId);
      expect(container.read(spinWheelProvider).options.length, equals(2));
    });

    test('Apply preset switches options and resets winner', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(spinWheelProvider.notifier);
      final foodPreset = SpinWheelPreset.builtInPresets.firstWhere((p) => p.id == 'food_picker');

      notifier.applyPreset(foodPreset);
      final state = container.read(spinWheelProvider);
      expect(state.activePresetId, equals('food_picker'));
      expect(state.options.length, equals(6));
      expect(state.options.first.label, equals('Pizza'));
    });

    test('Deterministic spin commits winner and updates history', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(spinWheelProvider.notifier);
      notifier.clearHistory();
      final spinFuture = notifier.spin();

      // State is immediately marked isSpinning with a pre-selected winner
      expect(container.read(spinWheelProvider).isSpinning, isTrue);
      expect(container.read(spinWheelProvider).selectedWinner, isNotNull);

      await spinFuture;

      final settledState = container.read(spinWheelProvider);
      expect(settledState.isSpinning, isFalse);
      expect(settledState.selectedWinner, isNotNull);
      expect(settledState.history.length, equals(1));
      expect(settledState.history.first.winnerLabel, equals(settledState.selectedWinner!.label));
    });

    test('Remove winner eliminates current winner and clears winner selection', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(spinWheelProvider.notifier);
      await notifier.spin();

      final winner = container.read(spinWheelProvider).selectedWinner!;
      final initialCount = container.read(spinWheelProvider).options.length;

      notifier.removeWinner();

      final state = container.read(spinWheelProvider);
      expect(state.options.length, equals(initialCount - 1));
      expect(state.options.any((o) => o.id == winner.id), isFalse);
      expect(state.selectedWinner, isNull);
    });
  });

  group('Spin Wheel UI Components & Painting', () {
    testWidgets('WheelPointer renders without errors in light and dark mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelPointer(deflectionAngle: 0.05, isDarkMode: false),
            ),
          ),
        ),
      );
      expect(find.byType(WheelPointer), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelPointer(deflectionAngle: -0.05, isDarkMode: true),
            ),
          ),
        ),
      );
      expect(find.byType(WheelPointer), findsOneWidget);
    });

    testWidgets('PlayMateSpinWheel renders hero wheel with custom painter and pointer', (tester) async {
      final options = [
        const WheelOption(id: '1', label: 'One'),
        const WheelOption(id: '2', label: 'Two'),
        const WheelOption(id: '3', label: 'Three'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: PlayMateSpinWheel(
                options: options,
                size: 260.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlayMateSpinWheel), findsOneWidget);
      expect(find.byType(WheelPointer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('SpinWheelScreen renders full interface with controls and zero overflow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SpinWheelScreen(),
          ),
        ),
      );

      expect(find.text('Spin Wheel'), findsOneWidget);
      expect(find.text('SPIN WHEEL'), findsOneWidget);
      expect(find.byType(PlayMateSpinWheel), findsOneWidget);
    });
  });

  group('Responsive Layout Testing Across Screen Widths', () {
    final testWidths = [320.0, 360.0, 390.0, 412.0, 768.0, 1024.0];

    for (final width in testWidths) {
      testWidgets('SpinWheelScreen renders without overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const SpinWheelScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'No exception or overflow at width $width');
        expect(find.text('Spin Wheel'), findsOneWidget);
        expect(find.byType(PlayMateSpinWheel), findsOneWidget);
      });
    }
  });
}
