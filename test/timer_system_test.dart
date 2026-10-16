import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:playmate/core/theme.dart';
import 'package:playmate/features/timer/domain/time_formatter.dart';
import 'package:playmate/features/timer/domain/time_source.dart';
import 'package:playmate/services/storage_service.dart';
import 'package:playmate/features/timer/timer_provider.dart';
import 'package:playmate/features/timer/timer_screen.dart';
import 'package:playmate/features/timer/timer_state.dart';
import 'package:playmate/features/timer/widgets/lap_list.dart';
import 'package:playmate/features/timer/widgets/time_display.dart';
import 'package:playmate/features/timer/widgets/timer_controls.dart';
import 'package:playmate/features/timer/widgets/timer_mode_selector.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_timer');
    await Hive.openBox('settings');
    await Hive.openBox('matches');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('TimeFormatter Unit Tests', () {
    test('formatMmSs formats MM:SS and HH:MM:SS accurately', () {
      expect(TimeFormatter.formatMmSs(Duration.zero), equals('00:00'));
      expect(TimeFormatter.formatMmSs(const Duration(seconds: 45)), equals('00:45'));
      expect(TimeFormatter.formatMmSs(const Duration(minutes: 5, seconds: 9)), equals('05:09'));
      expect(TimeFormatter.formatMmSs(const Duration(hours: 1, minutes: 2, seconds: 3)), equals('1:02:03'));
    });

    test('formatStopwatch includes centiseconds', () {
      expect(
        TimeFormatter.formatStopwatch(const Duration(minutes: 1, seconds: 23, milliseconds: 450)),
        equals('01:23.45'),
      );
    });

    test('formatChess shows tenths when under 10 seconds', () {
      expect(
        TimeFormatter.formatChess(const Duration(seconds: 7, milliseconds: 400)),
        equals('7.4s'),
      );
      expect(
        TimeFormatter.formatChess(const Duration(minutes: 2)),
        equals('02:00'),
      );
    });
  });

  group('Monotonic Timing Engine & Notifier', () {
    late TestTimeSource timeSource;
    late TimerNotifier notifier;

    setUp(() {
      if (StorageService.isBoxOpen(StorageService.settingsBoxName)) {
        StorageService.getSettingsBox().delete('timer_countdown_seconds');
        StorageService.getSettingsBox().delete('timer_chess_base_seconds');
        StorageService.getSettingsBox().delete('timer_chess_inc_seconds');
        StorageService.getSettingsBox().delete('timer_chess_preset');
      }
      timeSource = TestTimeSource(1000000); // 1 sec base
      notifier = TimerNotifier(timeSource: timeSource);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initial mode is Countdown at 5 minutes', () {
      expect(notifier.state.mode, equals(TimerMode.countdown));
      expect(notifier.state.countdownRemaining, equals(const Duration(minutes: 5)));
      expect(notifier.state.isRunning, isFalse);
    });

    test('Countdown: Start, pause, resume does not lose accumulated time', () {
      notifier.configureCountdown(const Duration(minutes: 1));
      notifier.start();
      expect(notifier.state.isRunning, isTrue);

      // Advance clock by 15 seconds
      timeSource.advance(const Duration(seconds: 15));
      notifier.stop();

      expect(notifier.state.isRunning, isFalse);
      expect(notifier.state.countdownRemaining, equals(const Duration(seconds: 45)));

      // Resume and advance another 10 seconds
      notifier.start();
      timeSource.advance(const Duration(seconds: 10));
      notifier.stop();

      expect(notifier.state.countdownRemaining, equals(const Duration(seconds: 35)));
    });

    test('Countdown: Reset restores initial duration', () {
      notifier.configureCountdown(const Duration(minutes: 2));
      notifier.start();
      timeSource.advance(const Duration(seconds: 30));
      notifier.stop();

      expect(notifier.state.countdownRemaining, equals(const Duration(seconds: 90)));
      notifier.reset();
      expect(notifier.state.countdownRemaining, equals(const Duration(minutes: 2)));
    });

    test('Stopwatch: Elapsed time accumulation and lap recording', () {
      notifier.setMode(TimerMode.stopwatch);
      notifier.start();

      timeSource.advance(const Duration(seconds: 10, milliseconds: 500));
      notifier.stop();
      expect(notifier.state.stopwatchElapsed, equals(const Duration(seconds: 10, milliseconds: 500)));

      // Record lap while running
      notifier.start();
      timeSource.advance(const Duration(seconds: 5));
      notifier.recordStopwatchLap();

      expect(notifier.state.stopwatchLaps.length, equals(1));
      expect(notifier.state.stopwatchLaps.first.lapNumber, equals(1));
      expect(notifier.state.stopwatchLaps.first.totalTime, equals(const Duration(seconds: 15, milliseconds: 500)));
      expect(notifier.state.stopwatchLaps.first.splitTime, equals(const Duration(seconds: 15, milliseconds: 500)));

      timeSource.advance(const Duration(seconds: 4));
      notifier.recordStopwatchLap();

      expect(notifier.state.stopwatchLaps.length, equals(2));
      expect(notifier.state.stopwatchLaps.first.lapNumber, equals(2));
      expect(notifier.state.stopwatchLaps.first.splitTime, equals(const Duration(seconds: 4)));
    });

    test('Turn Timer: Advances players and increments round on loop', () {
      notifier.setMode(TimerMode.turn);
      notifier.configureTurnTimer(
        turnDuration: const Duration(seconds: 30),
        players: const [
          TurnPlayer(id: 'p1', name: 'Alice'),
          TurnPlayer(id: 'p2', name: 'Bob'),
        ],
      );

      expect(notifier.state.turnPlayers[notifier.state.activePlayerIndex].name, equals('Alice'));
      expect(notifier.state.currentTurnRound, equals(1));

      // Advance turn to Bob
      notifier.advanceTurn();
      expect(notifier.state.turnPlayers[notifier.state.activePlayerIndex].name, equals('Bob'));
      expect(notifier.state.currentTurnRound, equals(1));

      // Advance turn back to Alice (New round)
      notifier.advanceTurn();
      expect(notifier.state.turnPlayers[notifier.state.activePlayerIndex].name, equals('Alice'));
      expect(notifier.state.currentTurnRound, equals(2));
    });

    test('Chess Clock: Switches player and applies increment atomically', () {
      notifier.setMode(TimerMode.chess);
      notifier.configureChess(
        baseTime: const Duration(minutes: 3),
        increment: const Duration(seconds: 2),
      );

      notifier.start();
      expect(notifier.state.isPlayerATurn, isTrue);

      // Player A thinks for 10 seconds and moves
      timeSource.advance(const Duration(seconds: 10));
      notifier.switchChessTurn();

      expect(notifier.state.isPlayerATurn, isFalse);
      expect(notifier.state.chessPlayerAMoves, equals(1));
      // Remaining = 3m - 10s + 2s inc = 2m 52s = 172s
      expect(notifier.state.chessPlayerARemaining, equals(const Duration(seconds: 172)));

      // Player B thinks for 5 seconds and moves
      timeSource.advance(const Duration(seconds: 5));
      notifier.switchChessTurn();

      expect(notifier.state.isPlayerATurn, isTrue);
      expect(notifier.state.chessPlayerBMoves, equals(1));
      // Remaining = 3m - 5s + 2s inc = 2m 57s = 177s
      expect(notifier.state.chessPlayerBRemaining, equals(const Duration(seconds: 177)));
    });

    test('Round Timer: Work and rest transitions', () {
      notifier.setMode(TimerMode.timer);
      notifier.configureRoundTimer(const RoundTimerConfig(
        workDuration: Duration(minutes: 1),
        restDuration: Duration(seconds: 15),
        totalRounds: 2,
      ));

      expect(notifier.state.currentRound, equals(1));
      expect(notifier.state.intervalPhase, equals(IntervalPhase.work));
      expect(notifier.state.roundRemaining, equals(const Duration(minutes: 1)));
    });
  });

  group('UI Components & Presentation Tests', () {
    testWidgets('TimerModeSelector renders all 5 modes', (tester) async {
      TimerMode? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerModeSelector(
              selectedMode: TimerMode.countdown,
              onModeChanged: (m) => selected = m,
            ),
          ),
        ),
      );

      expect(find.text('Countdown'), findsOneWidget);
      expect(find.text('Round Timer'), findsOneWidget);
      expect(find.text('Stopwatch'), findsOneWidget);
      expect(find.text('Turn Timer'), findsOneWidget);
      expect(find.text('Chess Clock'), findsOneWidget);

      await tester.tap(find.text('Stopwatch'));
      await tester.pump();
      expect(selected, equals(TimerMode.stopwatch));
    });

    testWidgets('TimeDisplay renders tabular digits without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimeDisplay(
              formattedTime: '05:00',
              subtitle: 'Ready',
            ),
          ),
        ),
      );

      expect(find.text('05:00'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('LapList renders list of laps with split calculations', (tester) async {
      const laps = [
        StopwatchLap(lapNumber: 2, splitTime: Duration(seconds: 4), totalTime: Duration(seconds: 14)),
        StopwatchLap(lapNumber: 1, splitTime: Duration(seconds: 10), totalTime: Duration(seconds: 10)),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LapList(laps: laps),
          ),
        ),
      );

      expect(find.text('Lap 02'), findsOneWidget);
      expect(find.text('Lap 01'), findsOneWidget);
    });

    testWidgets('TimerControls renders Start, Pause, and Reset', (tester) async {
      bool resetPressed = false;
      bool startPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerControls(
              isRunning: false,
              onStart: () => startPressed = true,
              onPause: () {},
              onReset: () => resetPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('START'), findsOneWidget);
      expect(find.text('RESET'), findsOneWidget);

      await tester.tap(find.text('START'));
      expect(startPressed, isTrue);

      await tester.tap(find.text('RESET'));
      expect(resetPressed, isTrue);
    });
  });

  group('Responsive Screen Testing Across Widths', () {
    final testWidths = [320.0, 360.0, 390.0, 412.0, 768.0, 1024.0];

    for (final width in testWidths) {
      testWidgets('TimerScreen renders without overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const TimerScreen(),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'No exception or overflow at width $width');
        expect(find.text('Timers'), findsOneWidget);
        expect(find.byType(TimerModeSelector), findsOneWidget);
      });
    }

    testWidgets('TimerScreen switches between all 5 modes without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const TimerScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Countdown'), findsOneWidget);

      // Switch to Round Timer
      await tester.tap(find.text('Round Timer'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Switch to Stopwatch
      await tester.tap(find.text('Stopwatch'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Switch to Turn Timer
      await tester.tap(find.text('Turn Timer'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Switch to Chess Clock
      await tester.tap(find.text('Chess Clock'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('PLAYER A'), findsOneWidget);
      expect(find.text('PLAYER B'), findsOneWidget);
    });
  });
}
