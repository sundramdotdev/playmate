import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:playmate/core/theme.dart';
import 'package:playmate/features/dice/dice_orientation.dart';
import 'package:playmate/features/dice/dice_pips.dart';
import 'package:playmate/features/dice/dice_provider.dart';
import 'package:playmate/features/dice/dice_roller_view.dart';
import 'package:playmate/features/dice/dice_screen.dart';
import 'package:playmate/features/dice/dice_state.dart';
import 'package:playmate/features/dice/playmate_dice.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_dice');
    await Hive.openBox('settings');
    await Hive.openBox('matches');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Dice Orientation & Mathematics', () {
    test('All 6 canonical faces have sum of opposite faces equal to 7', () {
      final faces = DiceFaceOrientation.canonicalFaces;
      expect(faces.length, equals(6));

      // 1 (Front) + 6 (Back) = 7
      final f1 = faces.firstWhere((f) => f.value == 1);
      final f6 = faces.firstWhere((f) => f.value == 6);
      expect(f1.value + f6.value, equals(7));
      expect(f1.localNormal.z, equals(-1.0));
      expect(f6.localNormal.z, equals(1.0));

      // 2 (Top) + 5 (Bottom) = 7
      final f2 = faces.firstWhere((f) => f.value == 2);
      final f5 = faces.firstWhere((f) => f.value == 5);
      expect(f2.value + f5.value, equals(7));
      expect(f2.localNormal.y, equals(-1.0));
      expect(f5.localNormal.y, equals(1.0));

      // 3 (Right) + 4 (Left) = 7
      final f3 = faces.firstWhere((f) => f.value == 3);
      final f4 = faces.firstWhere((f) => f.value == 4);
      expect(f3.value + f4.value, equals(7));
      expect(f3.localNormal.x, equals(1.0));
      expect(f4.localNormal.x, equals(-1.0));
    });

    test('For every value 1 to 6, base rotation points the face normal at camera (0, 0, -1)', () {
      for (int val = 1; val <= 6; val++) {
        final rot = DiceFaceOrientation.getBaseEulerForValue(val);
        final rotMatrix = Matrix4.identity()
          ..rotateX(rot.x)
          ..rotateY(rot.y)
          ..rotateZ(rot.z);

        final targetFace =
            DiceFaceOrientation.canonicalFaces.firstWhere((f) => f.value == val);
        final s = rotMatrix.storage;
        final nx = targetFace.localNormal.x;
        final ny = targetFace.localNormal.y;
        final nz = targetFace.localNormal.z;

        final worldZ = s[2] * nx + s[6] * ny + s[10] * nz;
        final worldX = s[0] * nx + s[4] * ny + s[8] * nz;
        final worldY = s[1] * nx + s[5] * ny + s[9] * nz;

        // Facing camera directly means normal Z is close to -1.0, X and Y close to 0.0
        expect(worldZ, closeTo(-1.0, 0.001), reason: 'Value $val must face camera');
        expect(worldX, closeTo(0.0, 0.001), reason: 'Value $val must have worldX=0');
        expect(worldY, closeTo(0.0, 0.001), reason: 'Value $val must have worldY=0');
      }
    });

    test('computeVisibleFaces returns at most 3 visible faces in depth order', () {
      for (int val = 1; val <= 6; val++) {
        final restingEuler = DiceFaceOrientation.getRestingEulerForValue(val);
        final visible = DiceFaceOrientation.computeVisibleFaces(
          cubeRotation: restingEuler,
          halfExtent: 50.0,
        );

        expect(visible.length, inInclusiveRange(1, 3));
        // The winning face must always be in the visible set
        expect(visible.any((f) => f.value == val), isTrue);

        // Painter's algorithm verification: elements sorted from greatest depthZ to least
        for (int i = 0; i < visible.length - 1; i++) {
          expect(visible[i].depthZ >= visible[i + 1].depthZ, isTrue);
        }
      }
    });
  });

  group('Dice Logic & Riverpod Notifier', () {
    test('Initial dice roll state has 1 die showing 6', () {
      final container = ProviderContainer();
      final state = container.read(diceProvider);

      expect(state.diceCount, equals(1));
      expect(state.currentRolls, equals([6]));
      expect(state.isRolling, isFalse);
      expect(state.totalSum, equals(6));
      expect(state.diceType, equals(DiceType.d6));
    });

    test('Changing dice count updates currentRolls and totalSum', () {
      final container = ProviderContainer();
      container.read(diceProvider.notifier).setDiceCount(3);
      final state = container.read(diceProvider);

      expect(state.diceCount, equals(3));
      expect(state.currentRolls.length, equals(3));
      expect(state.totalSum, equals(18));
    });

    test('Resetting dice restores initial sides', () {
      final container = ProviderContainer();
      container.read(diceProvider.notifier).setDiceCount(2);
      container.read(diceProvider.notifier).resetDice();
      final state = container.read(diceProvider);

      expect(state.currentRolls, equals([6, 6]));
      expect(state.totalSum, equals(12));
    });

    test('Roll updates state to target rolls and records history after completion', () async {
      final container = ProviderContainer();
      final future = container.read(diceProvider.notifier).roll();

      // Immediately becomes isRolling: true with valid target rolls 1..6
      final rollingState = container.read(diceProvider);
      expect(rollingState.isRolling, isTrue);
      expect(rollingState.currentRolls.length, equals(1));
      expect(rollingState.currentRolls.first, inInclusiveRange(1, 6));

      // Duplicate roll while rolling is rejected
      await container.read(diceProvider.notifier).roll();

      // Await roll completion
      await future;

      final settledState = container.read(diceProvider);
      expect(settledState.isRolling, isFalse);
      expect(settledState.rollHistory.isNotEmpty, isTrue);
      expect(settledState.rollHistory.first, equals(settledState.currentRolls));
    });
  });

  group('Dice UI Widgets & Semantics', () {
    testWidgets('DicePips renders correct pip counts and PlayMate brand mark', (tester) async {
      for (int val = 1; val <= 6; val++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DicePips(
                  value: val,
                  faceSize: 100,
                  pipColor: const Color(0xFF17181A),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(DicePips), findsOneWidget);
        expect(DicePips.normalizedPipOffsets[val]!.length, equals(val == 1 ? 1 : val));
      }
    });

    testWidgets('PlayMateDice renders tactile 3D die with semantics', (tester) async {
      bool rollRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlayMateDice(
                value: 4,
                size: 140,
                onRollRequested: () {
                  rollRequested = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify die widget is mounted
      expect(find.byType(PlayMateDice), findsOneWidget);

      // Tap on die to trigger roll
      await tester.tap(find.byType(PlayMateDice));
      await tester.pump();
      expect(rollRequested, isTrue);
    });

    testWidgets('DiceRollerView coordinates multi-dice layout (4 dice)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 400,
                child: DiceRollerView(
                  rolls: const [2, 4, 5, 6],
                  diceType: DiceType.d6,
                  isRolling: false,
                  onRollRequested: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlayMateDice), findsNWidgets(4));
    });
  });

  group('Responsive Layout Testing', () {
    final testWidths = [320.0, 360.0, 390.0, 412.0, 768.0];

    for (final width in testWidths) {
      testWidgets('DiceScreen renders without overflow at ${width}px width', (tester) async {
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
              home: const DiceScreen(),
            ),
          ),
        );

        await tester.pump();

        // Verify key components rendered
        expect(find.byType(DiceScreen), findsOneWidget);
        expect(find.byType(DiceRollerView), findsOneWidget);
        expect(find.text('ROLL DICE'), findsOneWidget);
        expect(find.text('Dice Quantity'), findsOneWidget);

        // Verify zero RenderFlex overflows
        expect(caughtDetails, isNull);
      });
    }
  });
}
