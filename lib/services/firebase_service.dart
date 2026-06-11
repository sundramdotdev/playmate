import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> initialize() async {
    // In a local development environment, we mock Firebase initialization to avoid needing configuration files.
    // If the configuration is loaded/available, we would initialize standard Firebase.
    debugPrint("Firebase Initialized (Mocked for offline compatibility)");
  }
}

class AnalyticsService {
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    debugPrint("Analytics Log Event: $name | Params: $parameters");
  }

  static void trackDiceRolled(int count, String diceType) {
    logEvent('dice_roll', {'count': count, 'type': diceType});
  }

  static void trackCoinToss(String result) {
    logEvent('coin_toss', {'result': result});
  }

  static void trackTeamGenerated(int teamsCount, int playersCount) {
    logEvent('team_generated', {'teams': teamsCount, 'players': playersCount});
  }

  static void trackScoreUpdated(String matchName) {
    logEvent('score_updated', {'match': matchName});
  }

  static void trackCricketMatchCreated() {
    logEvent('cricket_match_created');
  }

  static void trackTournamentCreated(int teams) {
    logEvent('tournament_created', {'teams': teams});
  }

  static void trackSpinWheelUsed() {
    logEvent('spin_wheel_used');
  }

  static void trackTimerStarted(String type) {
    logEvent('timer_started', {'type': type});
  }

  static void trackAchievementUnlocked(String id) {
    logEvent('achievement_unlocked', {'id': id});
  }
}
