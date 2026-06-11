import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/sound_service.dart';
import '../../services/storage_service.dart';

enum CoinSide { heads, tails }

class CoinState {
  final CoinSide? lastResult;
  final bool isFlipping;
  final List<CoinSide> tossHistory;

  CoinState({
    this.lastResult,
    required this.isFlipping,
    required this.tossHistory,
  });

  CoinState copyWith({
    CoinSide? lastResult,
    bool? isFlipping,
    List<CoinSide>? tossHistory,
  }) {
    return CoinState(
      lastResult: lastResult ?? this.lastResult,
      isFlipping: isFlipping ?? this.isFlipping,
      tossHistory: tossHistory ?? this.tossHistory,
    );
  }
}

class CoinNotifier extends StateNotifier<CoinState> {
  final Random _random = Random();

  CoinNotifier() : super(CoinState(isFlipping: false, tossHistory: [])) {
    _loadHistory();
  }

  void _loadHistory() {
    final box = StorageService.getStatsBox();
    final List<dynamic>? historyRaw = box.get('coin_history');
    if (historyRaw != null) {
      final history = historyRaw.map((e) => CoinSide.values.firstWhere((element) => element.name == e)).toList();
      state = state.copyWith(tossHistory: history);
    }
  }

  Future<void> toss() async {
    if (state.isFlipping) return;
    state = state.copyWith(isFlipping: true);

    // Simulate flipping delay
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      SoundService.playTossSound();
    }

    final CoinSide result = _random.nextBool() ? CoinSide.heads : CoinSide.tails;
    SoundService.triggerHaptic();

    final updatedHistory = List<CoinSide>.from(state.tossHistory)..insert(0, result);
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      lastResult: result,
      isFlipping: false,
      tossHistory: updatedHistory,
    );

    // Save history
    final box = StorageService.getStatsBox();
    await box.put('coin_history', updatedHistory.map((e) => e.name).toList());

    // Statistics
    final totalTosses = box.get('total_coin_tosses', defaultValue: 0) as int;
    await box.put('total_coin_tosses', totalTosses + 1);

    // Analytics
    AnalyticsService.trackCoinToss(result.name);
  }

  void clearHistory() {
    state = state.copyWith(tossHistory: []);
    StorageService.getStatsBox().delete('coin_history');
  }
}

final coinProvider = StateNotifierProvider<CoinNotifier, CoinState>((ref) {
  return CoinNotifier();
});
