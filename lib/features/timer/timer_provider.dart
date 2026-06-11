import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/sound_service.dart';
import 'timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _ticker;

  TimerNotifier() : super(TimerState(
    mode: TimerMode.countdown,
    elapsed: Duration.zero,
    remaining: const Duration(minutes: 5),
    initialDuration: const Duration(minutes: 5),
    isRunning: false,
    chessPlayerARemaining: const Duration(minutes: 5),
    chessPlayerBRemaining: const Duration(minutes: 5),
    isPlayerATurn: true,
  ));

  void setMode(TimerMode mode) {
    stop();
    state = state.copyWith(
      mode: mode,
      elapsed: Duration.zero,
      remaining: mode == TimerMode.stopwatch ? Duration.zero : const Duration(minutes: 5),
      initialDuration: const Duration(minutes: 5),
      chessPlayerARemaining: const Duration(minutes: 5),
      chessPlayerBRemaining: const Duration(minutes: 5),
      isPlayerATurn: true,
    );
  }

  void configureCountdown(Duration duration) {
    stop();
    state = state.copyWith(
      remaining: duration,
      initialDuration: duration,
      elapsed: Duration.zero,
    );
  }

  void configureChess(Duration duration) {
    stop();
    state = state.copyWith(
      chessPlayerARemaining: duration,
      chessPlayerBRemaining: duration,
      isPlayerATurn: true,
    );
  }

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });

    AnalyticsService.trackTimerStarted(state.mode.name);
  }

  void stop() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    stop();
    state = state.copyWith(
      elapsed: Duration.zero,
      remaining: state.initialDuration,
      chessPlayerARemaining: state.initialDuration,
      chessPlayerBRemaining: state.initialDuration,
      isPlayerATurn: true,
    );
  }

  void switchChessTurn() {
    if (state.mode != TimerMode.chess) return;
    SoundService.triggerHaptic();
    state = state.copyWith(isPlayerATurn: !state.isPlayerATurn);
  }

  void _tick() {
    switch (state.mode) {
      case TimerMode.countdown:
      case TimerMode.turn:
        if (state.remaining.inSeconds <= 1) {
          stop();
          SoundService.triggerHaptic();
          state = state.copyWith(remaining: Duration.zero);
        } else {
          state = state.copyWith(
            remaining: state.remaining - const Duration(seconds: 1),
            elapsed: state.elapsed + const Duration(seconds: 1),
          );
        }
        break;

      case TimerMode.stopwatch:
        state = state.copyWith(
          elapsed: state.elapsed + const Duration(seconds: 1),
        );
        break;

      case TimerMode.chess:
        if (state.isPlayerATurn) {
          if (state.chessPlayerARemaining.inSeconds <= 1) {
            stop();
            SoundService.triggerHaptic();
            state = state.copyWith(chessPlayerARemaining: Duration.zero);
          } else {
            state = state.copyWith(
              chessPlayerARemaining: state.chessPlayerARemaining - const Duration(seconds: 1),
            );
          }
        } else {
          if (state.chessPlayerBRemaining.inSeconds <= 1) {
            stop();
            SoundService.triggerHaptic();
            state = state.copyWith(chessPlayerBRemaining: Duration.zero);
          } else {
            state = state.copyWith(
              chessPlayerBRemaining: state.chessPlayerBRemaining - const Duration(seconds: 1),
            );
          }
        }
        break;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
