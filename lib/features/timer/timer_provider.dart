import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase_service.dart';
import '../../services/sound_service.dart';
import '../../services/storage_service.dart';
import 'domain/time_source.dart';
import 'timer_state.dart';

/// Central StateNotifier managing all 5 timer modes in PlayMate with
/// monotonic elapsed-time calculations, zero-drift accuracy, and lifecycle safeguards.
class TimerNotifier extends StateNotifier<TimerState> {
  final TimeSource _timeSource;
  Timer? _ticker;

  // Authoritative monotonic anchor timestamp in microseconds for current running interval
  int _intervalStartUs = 0;

  // Snapshot of accumulated time at interval start
  Duration _accumulatedCountdownElapsed = Duration.zero;
  Duration _accumulatedRoundElapsed = Duration.zero;
  Duration _accumulatedStopwatchElapsed = Duration.zero;
  Duration _accumulatedTurnElapsed = Duration.zero;
  Duration _accumulatedChessPlayerAElapsed = Duration.zero;
  Duration _accumulatedChessPlayerBElapsed = Duration.zero;

  // Snapshot of previous lap total time for stopwatch split calculation
  Duration _lastLapTotalTime = Duration.zero;

  // Completion debounce flags
  bool _hasFiredCountdownComplete = false;
  bool _hasFiredRoundComplete = false;
  bool _hasFiredTurnComplete = false;
  bool _hasFiredChessFlag = false;

  TimerNotifier({TimeSource? timeSource})
      : _timeSource = timeSource ?? const SystemTimeSource(),
        super(TimerState.initial()) {
    _loadPersistedSettings();
  }

  void _loadPersistedSettings() {
    if (!StorageService.isBoxOpen(StorageService.settingsBoxName)) return;
    final box = StorageService.getSettingsBox();

    final countdownSec = box.get('timer_countdown_seconds', defaultValue: 300) as int;
    final chessBaseSec = box.get('timer_chess_base_seconds', defaultValue: 300) as int;
    final chessIncSec = box.get('timer_chess_inc_seconds', defaultValue: 0) as int;
    final chessPreset = box.get('timer_chess_preset', defaultValue: 'blitz_5_0') as String;

    state = state.copyWith(
      countdownInitial: Duration(seconds: countdownSec),
      countdownRemaining: Duration(seconds: countdownSec),
      chessBaseTime: Duration(seconds: chessBaseSec),
      chessIncrement: Duration(seconds: chessIncSec),
      chessPlayerARemaining: Duration(seconds: chessBaseSec),
      chessPlayerBRemaining: Duration(seconds: chessBaseSec),
      activePresetId: chessPreset,
    );
  }

  Future<void> _persistSettings() async {
    if (!mounted || !StorageService.isBoxOpen(StorageService.settingsBoxName)) return;
    final box = StorageService.getSettingsBox();
    await box.put('timer_countdown_seconds', state.countdownInitial.inSeconds);
    if (!mounted) return;
    await box.put('timer_chess_base_seconds', state.chessBaseTime.inSeconds);
    if (!mounted) return;
    await box.put('timer_chess_inc_seconds', state.chessIncrement.inSeconds);
    if (!mounted) return;
    await box.put('timer_chess_preset', state.activePresetId);
  }

  /// Changes the active timer mode. Freezes and resets the running interval.
  void setMode(TimerMode mode) {
    if (state.mode == mode) return;
    stop();
    state = state.copyWith(mode: mode);
  }

  // ==========================================
  // CONFIGURATION METHODS
  // ==========================================

  void configureCountdown(Duration duration) {
    if (duration <= Duration.zero) return;
    stop();
    _accumulatedCountdownElapsed = Duration.zero;
    _hasFiredCountdownComplete = false;

    state = state.copyWith(
      countdownInitial: duration,
      countdownRemaining: duration,
      countdownFinished: false,
    );
    _persistSettings();
  }

  void configureRoundTimer(RoundTimerConfig config) {
    if (config.workDuration <= Duration.zero || config.totalRounds < 1) return;
    stop();
    _accumulatedRoundElapsed = Duration.zero;
    _hasFiredRoundComplete = false;

    state = state.copyWith(
      roundConfig: config,
      currentRound: 1,
      intervalPhase: IntervalPhase.work,
      roundRemaining: config.workDuration,
      roundFinished: false,
    );
  }

  void configureTurnTimer({
    required Duration turnDuration,
    List<TurnPlayer>? players,
  }) {
    if (turnDuration <= Duration.zero) return;
    stop();
    _accumulatedTurnElapsed = Duration.zero;
    _hasFiredTurnComplete = false;

    state = state.copyWith(
      turnDuration: turnDuration,
      turnRemaining: turnDuration,
      turnPlayers: players ?? state.turnPlayers,
      activePlayerIndex: 0,
      currentTurnRound: 1,
      turnExpired: false,
    );
  }

  void updateTurnPlayerName(int index, String newName) {
    if (index < 0 || index >= state.turnPlayers.length) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final updated = List<TurnPlayer>.from(state.turnPlayers);
    updated[index] = updated[index].copyWith(name: trimmed);
    state = state.copyWith(turnPlayers: updated);
  }

  void addTurnPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.turnPlayers.length >= 10) return;
    final newPlayer = TurnPlayer(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed,
    );
    state = state.copyWith(turnPlayers: [...state.turnPlayers, newPlayer]);
  }

  void removeTurnPlayer(int index) {
    if (state.turnPlayers.length <= 2) return; // Need at least 2 players
    final updated = List<TurnPlayer>.from(state.turnPlayers)..removeAt(index);
    final newActiveIndex = state.activePlayerIndex >= updated.length ? 0 : state.activePlayerIndex;
    state = state.copyWith(
      turnPlayers: updated,
      activePlayerIndex: newActiveIndex,
    );
  }

  void configureChess({
    required Duration baseTime,
    Duration increment = Duration.zero,
    String presetId = 'custom',
  }) {
    if (baseTime <= Duration.zero) return;
    stop();
    _accumulatedChessPlayerAElapsed = Duration.zero;
    _accumulatedChessPlayerBElapsed = Duration.zero;
    _hasFiredChessFlag = false;

    state = state.copyWith(
      chessBaseTime: baseTime,
      chessIncrement: increment,
      chessPlayerARemaining: baseTime,
      chessPlayerBRemaining: baseTime,
      isPlayerATurn: true,
      chessPlayerAMoves: 0,
      chessPlayerBMoves: 0,
      chessPlayerAFlagged: false,
      chessPlayerBFlagged: false,
      activePresetId: presetId,
    );
    _persistSettings();
  }

  void applyChessPreset(ChessTimeControlPreset preset) {
    configureChess(
      baseTime: preset.baseTime,
      increment: preset.increment,
      presetId: preset.id,
    );
  }

  // ==========================================
  // CORE TIMING CONTROLS (START / PAUSE / RESET)
  // ==========================================

  /// Authoritative Start: commits running timestamp anchor and begins UI refresh loop.
  void start() {
    if (state.isRunning) return;

    // Guard against starting an already expired state without reset
    if (state.mode == TimerMode.countdown && state.countdownFinished) return;
    if (state.mode == TimerMode.timer && state.roundFinished) return;
    if (state.mode == TimerMode.chess && (state.chessPlayerAFlagged || state.chessPlayerBFlagged)) return;

    _intervalStartUs = _timeSource.nowMicroseconds;
    state = state.copyWith(isRunning: true);

    // High precision tick interval (50ms for stopwatch centiseconds, 100ms for timers)
    final Duration tickInterval = state.mode == TimerMode.stopwatch
        ? const Duration(milliseconds: 35)
        : const Duration(milliseconds: 80);

    _ticker?.cancel();
    _ticker = Timer.periodic(tickInterval, (_) => _onAuthoritativeTick());

    AnalyticsService.trackTimerStarted(state.mode.name);
  }

  /// Authoritative Pause: freezes accumulated elapsed time and stops ticker.
  void stop() {
    if (!state.isRunning) return;

    _ticker?.cancel();
    _ticker = null;

    // Freeze monotonic delta into accumulated counters
    final int nowUs = _timeSource.nowMicroseconds;
    final Duration intervalDelta = Duration(microseconds: nowUs - _intervalStartUs);

    _commitIntervalDelta(intervalDelta);

    Duration? updatedCountdownRemaining;
    Duration? updatedStopwatchElapsed;
    Duration? updatedTurnRemaining;
    Duration? updatedRoundRemaining;
    Duration? updatedChessPlayerARemaining;
    Duration? updatedChessPlayerBRemaining;

    switch (state.mode) {
      case TimerMode.countdown:
        updatedCountdownRemaining = state.countdownInitial - _accumulatedCountdownElapsed;
        if (updatedCountdownRemaining < Duration.zero) updatedCountdownRemaining = Duration.zero;
        break;
      case TimerMode.timer:
        final target = state.intervalPhase == IntervalPhase.work
            ? state.roundConfig.workDuration
            : state.roundConfig.restDuration;
        updatedRoundRemaining = target - _accumulatedRoundElapsed;
        if (updatedRoundRemaining < Duration.zero) updatedRoundRemaining = Duration.zero;
        break;
      case TimerMode.stopwatch:
        updatedStopwatchElapsed = _accumulatedStopwatchElapsed;
        break;
      case TimerMode.turn:
        updatedTurnRemaining = state.turnDuration - _accumulatedTurnElapsed;
        if (updatedTurnRemaining < Duration.zero) updatedTurnRemaining = Duration.zero;
        break;
      case TimerMode.chess:
        if (state.isPlayerATurn) {
          updatedChessPlayerARemaining = state.chessBaseTime - _accumulatedChessPlayerAElapsed;
          if (updatedChessPlayerARemaining < Duration.zero) updatedChessPlayerARemaining = Duration.zero;
        } else {
          updatedChessPlayerBRemaining = state.chessBaseTime - _accumulatedChessPlayerBElapsed;
          if (updatedChessPlayerBRemaining < Duration.zero) updatedChessPlayerBRemaining = Duration.zero;
        }
        break;
    }

    state = state.copyWith(
      isRunning: false,
      countdownRemaining: updatedCountdownRemaining,
      roundRemaining: updatedRoundRemaining,
      stopwatchElapsed: updatedStopwatchElapsed,
      turnRemaining: updatedTurnRemaining,
      chessPlayerARemaining: updatedChessPlayerARemaining,
      chessPlayerBRemaining: updatedChessPlayerBRemaining,
    );
  }

  /// Authoritative Reset: invalidates previous interval and restores initial values.
  void reset() {
    stop();
    _intervalStartUs = 0;

    switch (state.mode) {
      case TimerMode.countdown:
        _accumulatedCountdownElapsed = Duration.zero;
        _hasFiredCountdownComplete = false;
        state = state.copyWith(
          countdownRemaining: state.countdownInitial,
          countdownFinished: false,
        );
        break;

      case TimerMode.timer:
        _accumulatedRoundElapsed = Duration.zero;
        _hasFiredRoundComplete = false;
        state = state.copyWith(
          currentRound: 1,
          intervalPhase: IntervalPhase.work,
          roundRemaining: state.roundConfig.workDuration,
          roundFinished: false,
        );
        break;

      case TimerMode.stopwatch:
        _accumulatedStopwatchElapsed = Duration.zero;
        _lastLapTotalTime = Duration.zero;
        state = state.copyWith(
          stopwatchElapsed: Duration.zero,
          stopwatchLaps: const [],
        );
        break;

      case TimerMode.turn:
        _accumulatedTurnElapsed = Duration.zero;
        _hasFiredTurnComplete = false;
        state = state.copyWith(
          turnRemaining: state.turnDuration,
          activePlayerIndex: 0,
          currentTurnRound: 1,
          turnExpired: false,
        );
        break;

      case TimerMode.chess:
        _accumulatedChessPlayerAElapsed = Duration.zero;
        _accumulatedChessPlayerBElapsed = Duration.zero;
        _hasFiredChessFlag = false;
        state = state.copyWith(
          chessPlayerARemaining: state.chessBaseTime,
          chessPlayerBRemaining: state.chessBaseTime,
          isPlayerATurn: true,
          chessPlayerAMoves: 0,
          chessPlayerBMoves: 0,
          chessPlayerAFlagged: false,
          chessPlayerBFlagged: false,
        );
        break;
    }
  }

  // ==========================================
  // MODE SPECIFIC ACTIONS
  // ==========================================

  /// Records a lap in Stopwatch mode.
  void recordStopwatchLap() {
    if (state.mode != TimerMode.stopwatch || !state.isRunning) return;

    final int nowUs = _timeSource.nowMicroseconds;
    final Duration currentIntervalDelta = Duration(microseconds: nowUs - _intervalStartUs);
    final Duration currentTotal = _accumulatedStopwatchElapsed + currentIntervalDelta;
    final Duration split = currentTotal - _lastLapTotalTime;
    _lastLapTotalTime = currentTotal;

    final newLap = StopwatchLap(
      lapNumber: state.stopwatchLaps.length + 1,
      splitTime: split,
      totalTime: currentTotal,
    );

    SoundService.triggerHaptic();
    state = state.copyWith(
      stopwatchElapsed: currentTotal,
      stopwatchLaps: [newLap, ...state.stopwatchLaps],
    );
  }

  /// Advances to the next player in Turn Timer mode.
  void advanceTurn() {
    if (state.mode != TimerMode.turn) return;

    SoundService.triggerHaptic();

    // Reset turn accumulation
    _accumulatedTurnElapsed = Duration.zero;
    _intervalStartUs = _timeSource.nowMicroseconds;
    _hasFiredTurnComplete = false;

    final nextIndex = (state.activePlayerIndex + 1) % state.turnPlayers.length;
    final isNewRound = nextIndex == 0;

    state = state.copyWith(
      activePlayerIndex: nextIndex,
      turnRemaining: state.turnDuration,
      turnExpired: false,
      currentTurnRound: isNewRound ? state.currentTurnRound + 1 : state.currentTurnRound,
    );
  }

  /// Switches active player clock in Chess Clock mode with atomic Fischer increment.
  void switchChessTurn() {
    if (state.mode != TimerMode.chess || !state.isRunning) return;
    if (state.chessPlayerAFlagged || state.chessPlayerBFlagged) return;

    SoundService.triggerHaptic();

    // 1. Commit current interval
    final int nowUs = _timeSource.nowMicroseconds;
    final Duration delta = Duration(microseconds: nowUs - _intervalStartUs);
    _intervalStartUs = nowUs; // reset anchor for new player

    if (state.isPlayerATurn) {
      _accumulatedChessPlayerAElapsed += delta;
      // Apply increment to Player A who just finished move
      final remaining = (state.chessBaseTime - _accumulatedChessPlayerAElapsed + state.chessIncrement);
      state = state.copyWith(
        isPlayerATurn: false,
        chessPlayerARemaining: remaining > Duration.zero ? remaining : Duration.zero,
        chessPlayerAMoves: state.chessPlayerAMoves + 1,
      );
      // Adjust accumulated so future ticks calculate from the incremented value
      _accumulatedChessPlayerAElapsed = state.chessBaseTime - state.chessPlayerARemaining;
    } else {
      _accumulatedChessPlayerBElapsed += delta;
      // Apply increment to Player B who just finished move
      final remaining = (state.chessBaseTime - _accumulatedChessPlayerBElapsed + state.chessIncrement);
      state = state.copyWith(
        isPlayerATurn: true,
        chessPlayerBRemaining: remaining > Duration.zero ? remaining : Duration.zero,
        chessPlayerBMoves: state.chessPlayerBMoves + 1,
      );
      _accumulatedChessPlayerBElapsed = state.chessBaseTime - state.chessPlayerBRemaining;
    }
  }

  // ==========================================
  // AUTHORITATIVE TICK CALCULATION
  // ==========================================

  void _onAuthoritativeTick() {
    if (!state.isRunning) return;

    final int nowUs = _timeSource.nowMicroseconds;
    final Duration currentIntervalDelta = Duration(microseconds: nowUs - _intervalStartUs);

    switch (state.mode) {
      case TimerMode.countdown:
        final totalElapsed = _accumulatedCountdownElapsed + currentIntervalDelta;
        final remaining = state.countdownInitial - totalElapsed;

        if (remaining <= Duration.zero) {
          stop();
          state = state.copyWith(
            countdownRemaining: Duration.zero,
            countdownFinished: true,
          );
          if (!_hasFiredCountdownComplete) {
            _hasFiredCountdownComplete = true;
            HapticFeedback.heavyImpact();
            SoundService.playRollSound();
          }
        } else {
          state = state.copyWith(countdownRemaining: remaining);
        }
        break;

      case TimerMode.timer:
        _handleRoundTimerTick(currentIntervalDelta);
        break;

      case TimerMode.stopwatch:
        final totalElapsed = _accumulatedStopwatchElapsed + currentIntervalDelta;
        state = state.copyWith(stopwatchElapsed: totalElapsed);
        break;

      case TimerMode.turn:
        final totalElapsed = _accumulatedTurnElapsed + currentIntervalDelta;
        final remaining = state.turnDuration - totalElapsed;

        if (remaining <= Duration.zero) {
          state = state.copyWith(
            turnRemaining: Duration.zero,
            turnExpired: true,
          );
          if (!_hasFiredTurnComplete) {
            _hasFiredTurnComplete = true;
            HapticFeedback.heavyImpact();
            SoundService.playRollSound();
          }
        } else {
          state = state.copyWith(turnRemaining: remaining);
        }
        break;

      case TimerMode.chess:
        _handleChessTick(currentIntervalDelta);
        break;
    }
  }

  void _handleRoundTimerTick(Duration currentIntervalDelta) {
    final targetDuration = state.intervalPhase == IntervalPhase.work
        ? state.roundConfig.workDuration
        : state.roundConfig.restDuration;

    final totalElapsed = _accumulatedRoundElapsed + currentIntervalDelta;
    final remaining = targetDuration - totalElapsed;

    if (remaining <= Duration.zero) {
      // Transition between Work and Rest or advance Round
      _accumulatedRoundElapsed = Duration.zero;
      _intervalStartUs = _timeSource.nowMicroseconds;
      HapticFeedback.mediumImpact();

      if (state.intervalPhase == IntervalPhase.work) {
        if (state.roundConfig.restDuration > Duration.zero) {
          state = state.copyWith(
            intervalPhase: IntervalPhase.rest,
            roundRemaining: state.roundConfig.restDuration,
          );
        } else {
          _advanceRound();
        }
      } else {
        _advanceRound();
      }
    } else {
      state = state.copyWith(roundRemaining: remaining);
    }
  }

  void _advanceRound() {
    if (state.currentRound >= state.roundConfig.totalRounds) {
      stop();
      state = state.copyWith(
        intervalPhase: IntervalPhase.complete,
        roundRemaining: Duration.zero,
        roundFinished: true,
      );
      if (!_hasFiredRoundComplete) {
        _hasFiredRoundComplete = true;
        HapticFeedback.heavyImpact();
        SoundService.playRollSound();
      }
    } else {
      state = state.copyWith(
        currentRound: state.currentRound + 1,
        intervalPhase: IntervalPhase.work,
        roundRemaining: state.roundConfig.workDuration,
      );
    }
  }

  void _handleChessTick(Duration currentIntervalDelta) {
    if (state.isPlayerATurn) {
      final totalElapsed = _accumulatedChessPlayerAElapsed + currentIntervalDelta;
      final remaining = state.chessBaseTime - totalElapsed;

      if (remaining <= Duration.zero) {
        stop();
        state = state.copyWith(
          chessPlayerARemaining: Duration.zero,
          chessPlayerAFlagged: true,
        );
        if (!_hasFiredChessFlag) {
          _hasFiredChessFlag = true;
          HapticFeedback.heavyImpact();
          SoundService.playRollSound();
        }
      } else {
        state = state.copyWith(chessPlayerARemaining: remaining);
      }
    } else {
      final totalElapsed = _accumulatedChessPlayerBElapsed + currentIntervalDelta;
      final remaining = state.chessBaseTime - totalElapsed;

      if (remaining <= Duration.zero) {
        stop();
        state = state.copyWith(
          chessPlayerBRemaining: Duration.zero,
          chessPlayerBFlagged: true,
        );
        if (!_hasFiredChessFlag) {
          _hasFiredChessFlag = true;
          HapticFeedback.heavyImpact();
          SoundService.playRollSound();
        }
      } else {
        state = state.copyWith(chessPlayerBRemaining: remaining);
      }
    }
  }

  void _commitIntervalDelta(Duration delta) {
    switch (state.mode) {
      case TimerMode.countdown:
        _accumulatedCountdownElapsed += delta;
        break;
      case TimerMode.timer:
        _accumulatedRoundElapsed += delta;
        break;
      case TimerMode.stopwatch:
        _accumulatedStopwatchElapsed += delta;
        break;
      case TimerMode.turn:
        _accumulatedTurnElapsed += delta;
        break;
      case TimerMode.chess:
        if (state.isPlayerATurn) {
          _accumulatedChessPlayerAElapsed += delta;
        } else {
          _accumulatedChessPlayerBElapsed += delta;
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
