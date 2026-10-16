import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import 'dice_motion_config.dart';
import 'dice_state.dart';

class DiceNotifier extends StateNotifier<DiceRollState> {
  final Random _random = Random();

  DiceNotifier()
      : super(DiceRollState(
          currentRolls: [6],
          diceType: DiceType.d6,
          diceCount: 1,
          isRolling: false,
          rollHistory: [],
        )) {
    _loadHistory();
  }

  void _loadHistory() {
    if (!StorageService.isBoxOpen(StorageService.statsBoxName)) return;
    final box = StorageService.getStatsBox();
    final List<dynamic>? historyRaw = box.get('dice_history');
    if (historyRaw != null) {
      final history = historyRaw.map((e) => List<int>.from(e as List)).toList();
      state = state.copyWith(rollHistory: history);
    }
  }

  void setDiceType(DiceType type) {
    if (state.isRolling) return;
    state = state.copyWith(
      diceType: type,
      currentRolls: List.generate(state.diceCount, (_) => type.sides),
    );
  }

  void setDiceCount(int count) {
    if (state.isRolling) return;
    state = state.copyWith(
      diceCount: count,
      currentRolls: List.generate(count, (_) => state.diceType.sides),
    );
  }

  /// Resets the current visible dice orientation to default sides without wiping history.
  void resetDice() {
    if (state.isRolling) return;
    state = state.copyWith(
      currentRolls: List.generate(state.diceCount, (_) => state.diceType.sides),
    );
  }

  /// Initiates a deterministic physical roll sequence.
  ///
  /// Flow:
  /// 1. Logical randomness generated first
  /// 2. State updated with target rolls & isRolling: true so 3D renderer animates to exact target
  /// 3. Physical animation timeline completes
  /// 4. History recorded, state marked complete (isRolling: false)
  Future<void> roll() async {
    if (state.isRolling) return;

    // 1. Generate logical random result first
    final finalRolls = List.generate(
      state.diceCount,
      (_) => _random.nextInt(state.diceType.sides) + 1,
    );

    // 2. Publish target result immediately so visual renderer computes target orientation
    state = state.copyWith(
      currentRolls: finalRolls,
      isRolling: true,
    );

    // 3. Await duration matching physical 3D animation timeline
    await Future.delayed(DiceMotionConfig.rollDuration);

    // 4. Update history upon settling
    final updatedHistory = List<List<int>>.from(state.rollHistory)..insert(0, finalRolls);
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      isRolling: false,
      rollHistory: updatedHistory,
    );

    // Persist history & statistics
    if (StorageService.isBoxOpen(StorageService.statsBoxName)) {
      final box = StorageService.getStatsBox();
      await box.put('dice_history', updatedHistory);
      final int totalRolls = box.get('total_dice_rolls', defaultValue: 0) as int;
      await box.put('total_dice_rolls', totalRolls + state.diceCount);
    }

    // Analytics event
    AnalyticsService.trackDiceRolled(state.diceCount, state.diceType.name);
  }

  void clearHistory() {
    state = state.copyWith(rollHistory: []);
    if (StorageService.isBoxOpen(StorageService.statsBoxName)) {
      StorageService.getStatsBox().delete('dice_history');
    }
  }
}

final diceProvider = StateNotifierProvider<DiceNotifier, DiceRollState>((ref) {
  return DiceNotifier();
});
