enum TimerMode { countdown, stopwatch, turn, chess }

class TimerState {
  final TimerMode mode;
  final Duration elapsed;
  final Duration remaining;
  final Duration initialDuration;
  final bool isRunning;

  // Chess specific timer states
  final Duration chessPlayerARemaining;
  final Duration chessPlayerBRemaining;
  final bool isPlayerATurn; // true = Player A active, false = Player B active

  TimerState({
    required this.mode,
    required this.elapsed,
    required this.remaining,
    required this.initialDuration,
    required this.isRunning,
    required this.chessPlayerARemaining,
    required this.chessPlayerBRemaining,
    required this.isPlayerATurn,
  });

  TimerState copyWith({
    TimerMode? mode,
    Duration? elapsed,
    Duration? remaining,
    Duration? initialDuration,
    bool? isRunning,
    Duration? chessPlayerARemaining,
    Duration? chessPlayerBRemaining,
    bool? isPlayerATurn,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      elapsed: elapsed ?? this.elapsed,
      remaining: remaining ?? this.remaining,
      initialDuration: initialDuration ?? this.initialDuration,
      isRunning: isRunning ?? this.isRunning,
      chessPlayerARemaining: chessPlayerARemaining ?? this.chessPlayerARemaining,
      chessPlayerBRemaining: chessPlayerBRemaining ?? this.chessPlayerBRemaining,
      isPlayerATurn: isPlayerATurn ?? this.isPlayerATurn,
    );
  }
}
