import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/sound_service.dart';
import '../../services/storage_service.dart';
import 'dice_state.dart';

class DiceNotifier extends StateNotifier<DiceRollState> {
  final Random _random = Random();

  DiceNotifier() : super(DiceRollState(
    currentRolls: [6],
    diceType: DiceType.d6,
    diceCount: 1,
    isRolling: false,
    rollHistory: [],
  )) {
    _loadHistory();
  }

  void _loadHistory() {
    final box = StorageService.getStatsBox();
    final List<dynamic>? historyRaw = box.get('dice_history');
    if (historyRaw != null) {
      final history = historyRaw.map((e) => List<int>.from(e as List)).toList();
      state = state.copyWith(rollHistory: history);
    }
  }

  void setDiceType(DiceType type) {
    state = state.copyWith(
      diceType: type,
      currentRolls: List.generate(state.diceCount, (_) => type.sides),
    );
  }

  void setDiceCount(int count) {
    state = state.copyWith(
      diceCount: count,
      currentRolls: List.generate(count, (_) => state.diceType.sides),
    );
  }

  Future<void> roll() async {
    if (state.isRolling) return;
    state = state.copyWith(isRolling: true);
    
    // Simulate rolling animation with multi-step sound & values
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      SoundService.playRollSound();
      state = state.copyWith(
        currentRolls: List.generate(
          state.diceCount,
          (_) => _random.nextInt(state.diceType.sides) + 1,
        ),
      );
    }

    final finalRolls = List.generate(
      state.diceCount,
      (_) => _random.nextInt(state.diceType.sides) + 1,
    );
    SoundService.triggerHaptic();

    final updatedHistory = List<List<int>>.from(state.rollHistory)..insert(0, finalRolls);
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      currentRolls: finalRolls,
      isRolling: false,
      rollHistory: updatedHistory,
    );

    // Save history & statistics
    final box = StorageService.getStatsBox();
    await box.put('dice_history', updatedHistory);

    // Update global dice rolls counter
    final int totalRolls = box.get('total_dice_rolls', defaultValue: 0) as int;
    await box.put('total_dice_rolls', totalRolls + state.diceCount);

    // Analytics
    AnalyticsService.trackDiceRolled(state.diceCount, state.diceType.name);
  }

  void clearHistory() {
    state = state.copyWith(rollHistory: []);
    StorageService.getStatsBox().delete('dice_history');
  }
}

final diceProvider = StateNotifierProvider<DiceNotifier, DiceRollState>((ref) {
  return DiceNotifier();
});
