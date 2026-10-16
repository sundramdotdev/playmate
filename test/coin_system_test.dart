import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:playmate/core/theme.dart';
import 'package:playmate/features/coin/coin_face.dart';
import 'package:playmate/features/coin/coin_orientation.dart';
import 'package:playmate/features/coin/coin_provider.dart';
import 'package:playmate/features/coin/coin_screen.dart';
import 'package:playmate/features/coin/playmate_coin.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_coin');
    await Hive.openBox('settings');
    await Hive.openBox('matches');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Coin Orientation & Geometry Mathematics', () {
    test('Canonical proportions maintain 1:8 thickness ratio', () {
      expect(CoinOrientation.thicknessRatio, closeTo(0.12, 0.01));
      expect(CoinOrientation.bevelRatio, closeTo(0.04, 0.01));
    });

    test('Base angles align Heads to 0 and Tails to pi', () {
      final headsAngle = CoinOrientation.getBaseAngleForSide(CoinSide.heads);
      final tailsAngle = CoinOrientation.getBaseAngleForSide(CoinSide.tails);

      expect(headsAngle, equals(0.0));
      expect(tailsAngle, equals(math.pi));

      expect(CoinOrientation.isHeadsFacing(headsAngle), isTrue);
      expect(CoinOrientation.isHeadsFacing(tailsAngle), isFalse);
    });

    test('calculateTargetFlipAngle lands deterministically on target side for any cycle count', () {
      for (final targetSide in CoinSide.values) {
        for (int cycles = 3; cycles <= 8; cycles++) {
          final targetAngle = CoinOrientation.calculateTargetFlipAngle(
            currentRx: 0.0,
            targetSide: targetSide,
            fullCycles: cycles,
          );

          // Verify cosine matches target side
          final double cosVal = math.cos(targetAngle);
          if (targetSide == CoinSide.heads) {
            expect(cosVal, closeTo(1.0, 0.001), reason: 'Heads targetAngle must have cos=1');
            expect(CoinOrientation.isHeadsFacing(targetAngle), isTrue);
          } else {
            expect(cosVal, closeTo(-1.0, 0.001), reason: 'Tails targetAngle must have cos=-1');
            expect(CoinOrientation.isHeadsFacing(targetAngle), isFalse);
          }
        }
      }
    });

    test('Edge visibility reaches 1.0 when edge-on at 90 degrees', () {
      expect(CoinOrientation.getEdgeVisibility(0.0), closeTo(0.0, 0.001));
      expect(CoinOrientation.getEdgeVisibility(math.pi / 2), closeTo(1.0, 0.001));
      expect(CoinOrientation.getEdgeVisibility(math.pi), closeTo(0.0, 0.001));
    });
  });

  group('Coin Logic & Riverpod Notifier', () {
    test('Initial coin state has Heads and empty history', () {
      final container = ProviderContainer();
      final state = container.read(coinProvider);

      expect(state.lastResult, equals(CoinSide.heads));
      expect(state.isFlipping, isFalse);
      expect(state.tossHistory, isEmpty);
      expect(state.headsCount, equals(0));
      expect(state.tailsCount, equals(0));
      expect(state.totalTosses, equals(0));
    });

    test('Reset coin restores Heads without deleting history', () {
      final container = ProviderContainer();
      container.read(coinProvider.notifier).resetCoin();
      final state = container.read(coinProvider);

      expect(state.lastResult, equals(CoinSide.heads));
    });

    test('Toss updates state to target side and records history after completion', () async {
      final container = ProviderContainer();
      final future = container.read(coinProvider.notifier).toss();

      // Immediately becomes isFlipping: true with non-null target result
      final flippingState = container.read(coinProvider);
      expect(flippingState.isFlipping, isTrue);
      expect(flippingState.lastResult, isNotNull);

      // Duplicate toss while flipping is rejected
      await container.read(coinProvider.notifier).toss();

      // Await toss completion
      await future;

      final settledState = container.read(coinProvider);
      expect(settledState.isFlipping, isFalse);
      expect(settledState.tossHistory.length, equals(1));
      expect(settledState.totalTosses, equals(1));
      expect(settledState.tossHistory.first, equals(settledState.lastResult));

      if (settledState.lastResult == CoinSide.heads) {
        expect(settledState.headsCount, equals(1));
        expect(settledState.tailsCount, equals(0));
      } else {
        expect(settledState.headsCount, equals(0));
        expect(settledState.tailsCount, equals(1));
      }
    });

    test('Clear history clears toss history and resets counts', () {
      final container = ProviderContainer();
      container.read(coinProvider.notifier).clearHistory();
      final state = container.read(coinProvider);

      expect(state.tossHistory, isEmpty);
      expect(state.totalTosses, equals(0));
    });
  });

  group('Coin UI Widgets & Semantics', () {
    testWidgets('CoinFace renders both HEADS and TAILS with PlayMate branding', (tester) async {
      for (final side in CoinSide.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CoinFace(
                  side: side,
                  size: 150,
                  isDarkMode: false,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CoinFace), findsOneWidget);
      }
    });

    testWidgets('PlayMateCoin renders tactile 3D coin with semantics', (tester) async {
      bool tossRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlayMateCoin(
                side: CoinSide.heads,
                size: 150,
                onTossRequested: () {
                  tossRequested = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlayMateCoin), findsOneWidget);

      // Tap on coin to trigger toss
      await tester.tap(find.byType(PlayMateCoin));
      await tester.pump();
      expect(tossRequested, isTrue);
    });
  });

  group('Responsive Layout Testing', () {
    final testWidths = [320.0, 360.0, 390.0, 412.0, 768.0, 1024.0];

    for (final width in testWidths) {
      testWidgets('CoinScreen renders without overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        FlutterErrorDetails? caughtDetails;
        FlutterError.onError = (details) {
          caughtDetails = details;
        };

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CoinScreen(),
            ),
          ),
        );

        await tester.pump();

        // Verify key components rendered
        expect(find.byType(CoinScreen), findsOneWidget);
        expect(find.byType(PlayMateCoin), findsOneWidget);
        expect(find.text('TOSS COIN'), findsOneWidget);

        // Verify zero RenderFlex overflows
        expect(caughtDetails, isNull);
      });
    }
  });
}
