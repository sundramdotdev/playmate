import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';

class TeamGeneratorState {
  final List<String> players;
  final List<List<String>> generatedTeams;
  final int numberOfTeams;
  final bool balanceRandomization;

  TeamGeneratorState({
    required this.players,
    required this.generatedTeams,
    required this.numberOfTeams,
    required this.balanceRandomization,
  });

  TeamGeneratorState copyWith({
    List<String>? players,
    List<List<String>>? generatedTeams,
    int? numberOfTeams,
    bool? balanceRandomization,
  }) {
    return TeamGeneratorState(
      players: players ?? this.players,
      generatedTeams: generatedTeams ?? this.generatedTeams,
      numberOfTeams: numberOfTeams ?? this.numberOfTeams,
      balanceRandomization: balanceRandomization ?? this.balanceRandomization,
    );
  }
}

class TeamNotifier extends StateNotifier<TeamGeneratorState> {
  final Random _random = Random();

  TeamNotifier() : super(TeamGeneratorState(
    players: [],
    generatedTeams: [],
    numberOfTeams: 2,
    balanceRandomization: true,
  )) {
    _loadPlayers();
  }

  void _loadPlayers() {
    final box = StorageService.getStatsBox();
    final List<dynamic>? playersRaw = box.get('players_list');
    if (playersRaw != null) {
      state = state.copyWith(players: List<String>.from(playersRaw));
    }
  }

  Future<void> addPlayer(String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty || state.players.contains(cleaned)) return;
    final updated = List<String>.from(state.players)..add(cleaned);
    state = state.copyWith(players: updated);
    await StorageService.getStatsBox().put('players_list', updated);
  }

  Future<void> removePlayer(String name) async {
    final updated = List<String>.from(state.players)..remove(name);
    state = state.copyWith(players: updated, generatedTeams: []);
    await StorageService.getStatsBox().put('players_list', updated);
  }

  void setNumberOfTeams(int value) {
    state = state.copyWith(numberOfTeams: value);
  }

  void setBalanceRandomization(bool value) {
    state = state.copyWith(balanceRandomization: value);
  }

  void generateTeams() {
    if (state.players.isEmpty) return;
    
    final shuffled = List<String>.from(state.players)..shuffle(_random);
    final teams = List.generate(state.numberOfTeams, (_) => <String>[]);

    for (int i = 0; i < shuffled.length; i++) {
      teams[i % state.numberOfTeams].add(shuffled[i]);
    }

    state = state.copyWith(generatedTeams: teams);
    
    // Save to matches history
    final box = StorageService.getMatchBox();
    final List<dynamic> history = box.get('team_matches', defaultValue: []) as List<dynamic>;
    final match = {
      'date': DateTime.now().toIso8601String(),
      'type': 'Team Generator',
      'participants': state.players,
      'teams': teams,
    };
    box.put('team_matches', [...history, match]);

    // Analytics
    AnalyticsService.trackTeamGenerated(state.numberOfTeams, state.players.length);
  }

  void clearAll() {
    state = state.copyWith(players: [], generatedTeams: []);
    StorageService.getStatsBox().delete('players_list');
  }
}

final teamProvider = StateNotifierProvider<TeamNotifier, TeamGeneratorState>((ref) {
  return TeamNotifier();
});
