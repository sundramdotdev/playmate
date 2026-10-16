import 'package:flutter/foundation.dart';
import 'domain/timer_models.dart';

export 'domain/timer_models.dart';

/// Complete reactive state for the PlayMate Timer Suite across all 5 modes.
@immutable
class TimerState {
  final TimerMode mode;
  final bool isRunning;

  // --- Countdown State ---
  final Duration countdownRemaining;
  final Duration countdownInitial;
  final bool countdownFinished;

  // --- Round / General Timer State ---
  final RoundTimerConfig roundConfig;
  final int currentRound;
  final IntervalPhase intervalPhase;
  final Duration roundRemaining;
  final bool roundFinished;

  // --- Stopwatch State ---
  final Duration stopwatchElapsed;
  final List<StopwatchLap> stopwatchLaps;

  // --- Turn Timer State ---
  final List<TurnPlayer> turnPlayers;
  final int activePlayerIndex;
  final Duration turnDuration;
  final Duration turnRemaining;
  final int currentTurnRound;
  final bool turnExpired;

  // --- Chess Clock State ---
  final Duration chessPlayerARemaining;
  final Duration chessPlayerBRemaining;
  final Duration chessBaseTime;
  final Duration chessIncrement;
  final bool isPlayerATurn;
  final int chessPlayerAMoves;
  final int chessPlayerBMoves;
  final bool chessPlayerAFlagged;
  final bool chessPlayerBFlagged;
  final String activePresetId;

  const TimerState({
    required this.mode,
    required this.isRunning,
    // Countdown
    required this.countdownRemaining,
    required this.countdownInitial,
    this.countdownFinished = false,
    // Round Timer
    this.roundConfig = const RoundTimerConfig(),
    this.currentRound = 1,
    this.intervalPhase = IntervalPhase.work,
    required this.roundRemaining,
    this.roundFinished = false,
    // Stopwatch
    required this.stopwatchElapsed,
    this.stopwatchLaps = const [],
    // Turn Timer
    this.turnPlayers = const [
      TurnPlayer(id: 'p1', name: 'Player 1'),
      TurnPlayer(id: 'p2', name: 'Player 2'),
      TurnPlayer(id: 'p3', name: 'Player 3'),
      TurnPlayer(id: 'p4', name: 'Player 4'),
    ],
    this.activePlayerIndex = 0,
    this.turnDuration = const Duration(seconds: 60),
    required this.turnRemaining,
    this.currentTurnRound = 1,
    this.turnExpired = false,
    // Chess Clock
    required this.chessPlayerARemaining,
    required this.chessPlayerBRemaining,
    this.chessBaseTime = const Duration(minutes: 5),
    this.chessIncrement = Duration.zero,
    required this.isPlayerATurn,
    this.chessPlayerAMoves = 0,
    this.chessPlayerBMoves = 0,
    this.chessPlayerAFlagged = false,
    this.chessPlayerBFlagged = false,
    this.activePresetId = 'blitz_5_0',
  });

  /// Factory for clean initial state
  factory TimerState.initial() {
    return const TimerState(
      mode: TimerMode.countdown,
      isRunning: false,
      countdownRemaining: Duration(minutes: 5),
      countdownInitial: Duration(minutes: 5),
      roundRemaining: Duration(minutes: 3),
      stopwatchElapsed: Duration.zero,
      turnRemaining: Duration(seconds: 60),
      chessPlayerARemaining: Duration(minutes: 5),
      chessPlayerBRemaining: Duration(minutes: 5),
      isPlayerATurn: true,
    );
  }

  // --- Compatibility Getters for existing usages ---
  Duration get remaining {
    switch (mode) {
      case TimerMode.countdown:
        return countdownRemaining;
      case TimerMode.timer:
        return roundRemaining;
      case TimerMode.stopwatch:
        return Duration.zero;
      case TimerMode.turn:
        return turnRemaining;
      case TimerMode.chess:
        return isPlayerATurn ? chessPlayerARemaining : chessPlayerBRemaining;
    }
  }

  Duration get elapsed => stopwatchElapsed;
  Duration get initialDuration => countdownInitial;

  TimerState copyWith({
    TimerMode? mode,
    bool? isRunning,
    // Countdown
    Duration? countdownRemaining,
    Duration? countdownInitial,
    bool? countdownFinished,
    // Round Timer
    RoundTimerConfig? roundConfig,
    int? currentRound,
    IntervalPhase? intervalPhase,
    Duration? roundRemaining,
    bool? roundFinished,
    // Stopwatch
    Duration? stopwatchElapsed,
    List<StopwatchLap>? stopwatchLaps,
    // Turn Timer
    List<TurnPlayer>? turnPlayers,
    int? activePlayerIndex,
    Duration? turnDuration,
    Duration? turnRemaining,
    int? currentTurnRound,
    bool? turnExpired,
    // Chess Clock
    Duration? chessPlayerARemaining,
    Duration? chessPlayerBRemaining,
    Duration? chessBaseTime,
    Duration? chessIncrement,
    bool? isPlayerATurn,
    int? chessPlayerAMoves,
    int? chessPlayerBMoves,
    bool? chessPlayerAFlagged,
    bool? chessPlayerBFlagged,
    String? activePresetId,
    // Compat parameters
    Duration? elapsed,
    Duration? remaining,
    Duration? initialDuration,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      isRunning: isRunning ?? this.isRunning,
      countdownRemaining: countdownRemaining ?? remaining ?? this.countdownRemaining,
      countdownInitial: countdownInitial ?? initialDuration ?? this.countdownInitial,
      countdownFinished: countdownFinished ?? this.countdownFinished,
      roundConfig: roundConfig ?? this.roundConfig,
      currentRound: currentRound ?? this.currentRound,
      intervalPhase: intervalPhase ?? this.intervalPhase,
      roundRemaining: roundRemaining ?? this.roundRemaining,
      roundFinished: roundFinished ?? this.roundFinished,
      stopwatchElapsed: stopwatchElapsed ?? elapsed ?? this.stopwatchElapsed,
      stopwatchLaps: stopwatchLaps ?? this.stopwatchLaps,
      turnPlayers: turnPlayers ?? this.turnPlayers,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      turnDuration: turnDuration ?? this.turnDuration,
      turnRemaining: turnRemaining ?? this.turnRemaining,
      currentTurnRound: currentTurnRound ?? this.currentTurnRound,
      turnExpired: turnExpired ?? this.turnExpired,
      chessPlayerARemaining: chessPlayerARemaining ?? this.chessPlayerARemaining,
      chessPlayerBRemaining: chessPlayerBRemaining ?? this.chessPlayerBRemaining,
      chessBaseTime: chessBaseTime ?? this.chessBaseTime,
      chessIncrement: chessIncrement ?? this.chessIncrement,
      isPlayerATurn: isPlayerATurn ?? this.isPlayerATurn,
      chessPlayerAMoves: chessPlayerAMoves ?? this.chessPlayerAMoves,
      chessPlayerBMoves: chessPlayerBMoves ?? this.chessPlayerBMoves,
      chessPlayerAFlagged: chessPlayerAFlagged ?? this.chessPlayerAFlagged,
      chessPlayerBFlagged: chessPlayerBFlagged ?? this.chessPlayerBFlagged,
      activePresetId: activePresetId ?? this.activePresetId,
    );
  }
}
