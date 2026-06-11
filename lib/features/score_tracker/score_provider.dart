import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';

class MatchScore {
  final String matchName;
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final List<List<int>> scoreHistory; // List of [teamAScore, teamBScore]
  final bool isCompleted;

  MatchScore({
    required this.matchName,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.scoreHistory,
    required this.isCompleted,
  });

  MatchScore copyWith({
    String? matchName,
    String? teamAName,
    String? teamBName,
    int? teamAScore,
    int? teamBScore,
    List<List<int>>? scoreHistory,
    bool? isCompleted,
  }) {
    return MatchScore(
      matchName: matchName ?? this.matchName,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      scoreHistory: scoreHistory ?? this.scoreHistory,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ScoreTrackerNotifier extends StateNotifier<MatchScore?> {
  ScoreTrackerNotifier() : super(null);

  void startNewMatch(String name, String teamA, String teamB) {
    state = MatchScore(
      matchName: name.isEmpty ? 'Casual Match' : name,
      teamAName: teamA.isEmpty ? 'Team A' : teamA,
      teamBName: teamB.isEmpty ? 'Team B' : teamB,
      teamAScore: 0,
      teamBScore: 0,
      scoreHistory: [],
      isCompleted: false,
    );
  }

  void incrementScore(bool isTeamA) {
    if (state == null || state!.isCompleted) return;

    final currentScoreA = state!.teamAScore;
    final currentScoreB = state!.teamBScore;

    // Record history for undo
    final updatedHistory = List<List<int>>.from(state!.scoreHistory)
      ..add([currentScoreA, currentScoreB]);

    state = state!.copyWith(
      teamAScore: isTeamA ? currentScoreA + 1 : currentScoreA,
      teamBScore: isTeamA ? currentScoreB : currentScoreB + 1,
      scoreHistory: updatedHistory,
    );

    AnalyticsService.trackScoreUpdated(state!.matchName);
  }

  void decrementScore(bool isTeamA) {
    if (state == null || state!.isCompleted) return;

    final currentScoreA = state!.teamAScore;
    final currentScoreB = state!.teamBScore;

    if (isTeamA && currentScoreA == 0) return;
    if (!isTeamA && currentScoreB == 0) return;

    final updatedHistory = List<List<int>>.from(state!.scoreHistory)
      ..add([currentScoreA, currentScoreB]);

    state = state!.copyWith(
      teamAScore: isTeamA ? currentScoreA - 1 : currentScoreA,
      teamBScore: isTeamA ? currentScoreB : currentScoreB - 1,
      scoreHistory: updatedHistory,
    );
  }

  void undoLastAction() {
    if (state == null || state!.scoreHistory.isEmpty || state!.isCompleted) return;

    final previousScores = state!.scoreHistory.last;
    final updatedHistory = List<List<int>>.from(state!.scoreHistory)..removeLast();

    state = state!.copyWith(
      teamAScore: previousScores[0],
      teamBScore: previousScores[1],
      scoreHistory: updatedHistory,
    );
  }

  Future<void> endAndSaveMatch() async {
    if (state == null) return;
    state = state!.copyWith(isCompleted: true);

    // Save to matches history
    final box = StorageService.getMatchBox();
    final List<dynamic> history = box.get('score_matches', defaultValue: []) as List<dynamic>;
    
    final match = {
      'date': DateTime.now().toIso8601String(),
      'type': 'Score Tracker',
      'matchName': state!.matchName,
      'teamA': state!.teamAName,
      'teamB': state!.teamBName,
      'scoreA': state!.teamAScore,
      'scoreB': state!.teamBScore,
      'winner': state!.teamAScore > state!.teamBScore 
          ? state!.teamAName 
          : (state!.teamAScore < state!.teamBScore ? state!.teamBName : 'Tie'),
    };

    await box.put('score_matches', [...history, match]);
  }

  void reset() {
    state = null;
  }
}

final scoreTrackerProvider = StateNotifierProvider<ScoreTrackerNotifier, MatchScore?>((ref) {
  return ScoreTrackerNotifier();
});
