import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';

class TournamentRound {
  final List<String> matches; // "Team A vs Team B" or placeholders
  final List<String> winners;

  TournamentRound({required this.matches, required this.winners});
}

class TournamentState {
  final List<String> teams;
  final List<TournamentRound> rounds; // Rounds from quarters/semis/finals
  final String? champion;
  final bool isGenerated;

  TournamentState({
    required this.teams,
    required this.rounds,
    this.champion,
    required this.isGenerated,
  });

  TournamentState copyWith({
    List<String>? teams,
    List<TournamentRound>? rounds,
    String? champion,
    bool? isGenerated,
  }) {
    return TournamentState(
      teams: teams ?? this.teams,
      rounds: rounds ?? this.rounds,
      champion: champion ?? this.champion,
      isGenerated: isGenerated ?? this.isGenerated,
    );
  }
}

class TournamentNotifier extends StateNotifier<TournamentState> {
  TournamentNotifier() : super(TournamentState(
    teams: [],
    rounds: [],
    isGenerated: false,
  ));

  void addTeam(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty || state.teams.contains(cleaned)) return;
    state = state.copyWith(teams: [...state.teams, cleaned]);
  }

  void removeTeam(String name) {
    state = state.copyWith(
      teams: List<String>.from(state.teams)..remove(name),
      isGenerated: false,
      rounds: [],
      champion: null,
    );
  }

  void generateBrackets() {
    final teamCount = state.teams.length;
    if (teamCount != 4 && teamCount != 8 && teamCount != 16 && teamCount != 32) return;

    final shuffled = List<String>.from(state.teams)..shuffle();
    final List<TournamentRound> rounds = [];

    // Initialize round 1 matches
    final List<String> round1Matches = [];
    for (int i = 0; i < shuffled.length; i += 2) {
      round1Matches.add('${shuffled[i]} vs ${shuffled[i + 1]}');
    }

    rounds.add(TournamentRound(
      matches: round1Matches,
      winners: List.filled(round1Matches.length, ''),
    ));

    // Fill remaining rounds with empty placeholders
    int nextRoundMatchesCount = round1Matches.length ~/ 2;
    while (nextRoundMatchesCount > 0) {
      rounds.add(TournamentRound(
        matches: List.filled(nextRoundMatchesCount, 'TBD vs TBD'),
        winners: List.filled(nextRoundMatchesCount, ''),
      ));
      nextRoundMatchesCount ~/= 2;
    }

    state = state.copyWith(
      rounds: rounds,
      isGenerated: true,
      champion: null,
    );

    AnalyticsService.trackTournamentCreated(teamCount);
  }

  void advanceWinner(int roundIndex, int matchIndex, String winner) {
    final updatedRounds = List<TournamentRound>.from(state.rounds);
    final currentRound = updatedRounds[roundIndex];

    final updatedWinners = List<String>.from(currentRound.winners);
    updatedWinners[matchIndex] = winner;
    updatedRounds[roundIndex] = TournamentRound(
      matches: currentRound.matches,
      winners: updatedWinners,
    );

    // If it's the final round, set the champion
    if (roundIndex == state.rounds.length - 1) {
      state = state.copyWith(rounds: updatedRounds, champion: winner);
      _saveTournament(winner);
      return;
    }

    // Advance to next round
    final nextRoundIndex = roundIndex + 1;
    final nextRound = updatedRounds[nextRoundIndex];
    final nextMatchIndex = matchIndex ~/ 2;

    final nextMatches = List<String>.from(nextRound.matches);
    final currentNextMatch = nextMatches[nextMatchIndex];
    final teamsInNextMatch = currentNextMatch.split(' vs ');

    if (matchIndex % 2 == 0) {
      // First slot in next match
      nextMatches[nextMatchIndex] = '$winner vs ${teamsInNextMatch.length > 1 ? teamsInNextMatch[1] : 'TBD'}';
    } else {
      // Second slot in next match
      nextMatches[nextMatchIndex] = '${teamsInNextMatch[0]} vs $winner';
    }

    updatedRounds[nextRoundIndex] = TournamentRound(
      matches: nextMatches,
      winners: nextRound.winners,
    );

    state = state.copyWith(rounds: updatedRounds);
  }

  Future<void> _saveTournament(String champion) async {
    final box = StorageService.getMatchBox();
    final List<dynamic> history = box.get('tournament_matches', defaultValue: []) as List<dynamic>;

    final match = {
      'date': DateTime.now().toIso8601String(),
      'type': 'Tournament',
      'champion': champion,
      'teams': state.teams,
    };

    await box.put('tournament_matches', [...history, match]);
  }

  void reset() {
    state = TournamentState(
      teams: [],
      rounds: [],
      isGenerated: false,
      champion: null,
    );
  }
}

final tournamentProvider = StateNotifierProvider<TournamentNotifier, TournamentState>((ref) {
  return TournamentNotifier();
});
