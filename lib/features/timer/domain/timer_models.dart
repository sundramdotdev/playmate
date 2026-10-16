import 'package:flutter/foundation.dart';

/// Supported timing modes in PlayMate
enum TimerMode {
  countdown,
  timer,
  stopwatch,
  turn,
  chess,
}

extension TimerModeDetails on TimerMode {
  String get displayName {
    switch (this) {
      case TimerMode.countdown:
        return 'Countdown';
      case TimerMode.timer:
        return 'Round Timer';
      case TimerMode.stopwatch:
        return 'Stopwatch';
      case TimerMode.turn:
        return 'Turn Timer';
      case TimerMode.chess:
        return 'Chess Clock';
    }
  }

  String get shortDescription {
    switch (this) {
      case TimerMode.countdown:
        return 'Count down to zero';
      case TimerMode.timer:
        return 'Work & rest rounds';
      case TimerMode.stopwatch:
        return 'Laps & split timing';
      case TimerMode.turn:
        return 'Player turn manager';
      case TimerMode.chess:
        return 'Dual clock & increments';
    }
  }
}

/// Represents an individual recorded lap in Stopwatch mode.
@immutable
class StopwatchLap {
  final int lapNumber;
  final Duration splitTime;
  final Duration totalTime;

  const StopwatchLap({
    required this.lapNumber,
    required this.splitTime,
    required this.totalTime,
  });

  Map<String, dynamic> toJson() => {
        'lapNumber': lapNumber,
        'splitTimeMs': splitTime.inMilliseconds,
        'totalTimeMs': totalTime.inMilliseconds,
      };

  factory StopwatchLap.fromJson(Map<String, dynamic> json) => StopwatchLap(
        lapNumber: json['lapNumber'] as int,
        splitTime: Duration(milliseconds: json['splitTimeMs'] as int),
        totalTime: Duration(milliseconds: json['totalTimeMs'] as int),
      );
}

/// Interval phase for General / Round Timer.
enum IntervalPhase {
  work,
  rest,
  complete,
}

/// Config for Round / Interval Timer.
@immutable
class RoundTimerConfig {
  final Duration workDuration;
  final Duration restDuration;
  final int totalRounds;

  const RoundTimerConfig({
    this.workDuration = const Duration(minutes: 3),
    this.restDuration = const Duration(seconds: 30),
    this.totalRounds = 3,
  });

  RoundTimerConfig copyWith({
    Duration? workDuration,
    Duration? restDuration,
    int? totalRounds,
  }) {
    return RoundTimerConfig(
      workDuration: workDuration ?? this.workDuration,
      restDuration: restDuration ?? this.restDuration,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }
}

/// Player representation for Turn Timer.
@immutable
class TurnPlayer {
  final String id;
  final String name;

  const TurnPlayer({
    required this.id,
    required this.name,
  });

  TurnPlayer copyWith({
    String? id,
    String? name,
  }) {
    return TurnPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

/// Pre-configured time controls for Chess Clock.
@immutable
class ChessTimeControlPreset {
  final String id;
  final String name;
  final Duration baseTime;
  final Duration increment;

  const ChessTimeControlPreset({
    required this.id,
    required this.name,
    required this.baseTime,
    this.increment = Duration.zero,
  });

  static const List<ChessTimeControlPreset> presets = [
    ChessTimeControlPreset(
      id: 'bullet_1_0',
      name: 'Bullet 1+0',
      baseTime: Duration(minutes: 1),
      increment: Duration.zero,
    ),
    ChessTimeControlPreset(
      id: 'blitz_3_2',
      name: 'Blitz 3+2',
      baseTime: Duration(minutes: 3),
      increment: Duration(seconds: 2),
    ),
    ChessTimeControlPreset(
      id: 'blitz_5_0',
      name: 'Blitz 5+0',
      baseTime: Duration(minutes: 5),
      increment: Duration.zero,
    ),
    ChessTimeControlPreset(
      id: 'rapid_10_0',
      name: 'Rapid 10+0',
      baseTime: Duration(minutes: 10),
      increment: Duration.zero,
    ),
    ChessTimeControlPreset(
      id: 'rapid_15_10',
      name: 'Rapid 15+10',
      baseTime: Duration(minutes: 15),
      increment: Duration(seconds: 10),
    ),
  ];
}

