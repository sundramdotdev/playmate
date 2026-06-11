import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';

class CricketMatchState {
  final int runs;
  final int wickets;
  final int balls; // Total balls bowled in the current innings
  final int maxOvers; // Total overs for the match
  final int? target; // Target runs to score if in second innings
  final bool isInningsCompleted;
  final String statusMessage;

  CricketMatchState({
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.maxOvers,
    this.target,
    required this.isInningsCompleted,
    required this.statusMessage,
  });

  int get oversBowled => balls ~/ 6;
  int get ballsInOver => balls % 6;
  String get formattedOvers => '$oversBowled.${balls % 6}';

  CricketMatchState copyWith({
    int? runs,
    int? wickets,
    int? balls,
    int? maxOvers,
    int? target,
    bool? isInningsCompleted,
    String? statusMessage,
  }) {
    return CricketMatchState(
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      balls: balls ?? this.balls,
      maxOvers: maxOvers ?? this.maxOvers,
      target: target ?? this.target,
      isInningsCompleted: isInningsCompleted ?? this.isInningsCompleted,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class CricketNotifier extends StateNotifier<CricketMatchState?> {
  CricketNotifier() : super(null);

  void startMatch(int overs, [int? target]) {
    state = CricketMatchState(
      runs: 0,
      wickets: 0,
      balls: 0,
      maxOvers: overs,
      target: target,
      isInningsCompleted: false,
      statusMessage: target == null ? '1st Innings: Batting' : '2nd Innings: Chasing $target',
    );
    AnalyticsService.trackCricketMatchCreated();
  }

  void addRuns(int runsToAdd) {
    if (state == null || state!.isInningsCompleted) return;

    final newRuns = state!.runs + runsToAdd;
    final newBalls = state!.balls + 1; // Standard delivery increments ball count

    _checkMatchProgress(newRuns, state!.wickets, newBalls);
  }

  void addWicket() {
    if (state == null || state!.isInningsCompleted) return;

    final newWickets = state!.wickets + 1;
    final newBalls = state!.balls + 1;

    _checkMatchProgress(state!.runs, newWickets, newBalls);
  }

  void addExtra(int runsToAdd, bool countsAsBall) {
    if (state == null || state!.isInningsCompleted) return;

    final newRuns = state!.runs + runsToAdd;
    final newBalls = countsAsBall ? state!.balls + 1 : state!.balls;

    _checkMatchProgress(newRuns, state!.wickets, newBalls);
  }

  void _checkMatchProgress(int runs, int wickets, int balls) {
    final maxBalls = state!.maxOvers * 6;
    bool isCompleted = false;
    String status = state!.statusMessage;

    if (state!.target != null) {
      // 2nd innings logic
      if (runs >= state!.target!) {
        isCompleted = true;
        status = 'Match Won by Chasing Team!';
        _saveToHistory(runs, wickets, balls, true);
      } else if (wickets >= 10 || balls >= maxBalls) {
        isCompleted = true;
        status = 'Match Lost! Target not reached.';
        _saveToHistory(runs, wickets, balls, false);
      } else {
        status = 'Chasing ${state!.target!}: Need ${state!.target! - runs} runs from ${maxBalls - balls} balls';
      }
    } else {
      // 1st innings logic
      if (wickets >= 10 || balls >= maxBalls) {
        isCompleted = true;
        status = '1st Innings Over! Target: ${runs + 1}';
      } else {
        status = '1st Innings: Batting. Overs remaining: ${((maxBalls - balls) / 6).toStringAsFixed(1)}';
      }
    }

    state = state!.copyWith(
      runs: runs,
      wickets: wickets,
      balls: balls,
      isInningsCompleted: isCompleted,
      statusMessage: status,
    );
  }

  Future<void> _saveToHistory(int runs, int wickets, int balls, bool won) async {
    final box = StorageService.getMatchBox();
    final List<dynamic> history = box.get('cricket_matches', defaultValue: []) as List<dynamic>;
    
    final match = {
      'date': DateTime.now().toIso8601String(),
      'type': 'Cricket Scorer',
      'runs': runs,
      'wickets': wickets,
      'overs': '${balls ~/ 6}.${balls % 6}',
      'target': state!.target,
      'won': won,
    };

    await box.put('cricket_matches', [...history, match]);
  }

  void reset() {
    state = null;
  }
}

final cricketProvider = StateNotifierProvider<CricketNotifier, CricketMatchState?>((ref) {
  return CricketNotifier();
});
