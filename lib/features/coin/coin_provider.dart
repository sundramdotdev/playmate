import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import 'coin_motion_config.dart';
import 'coin_orientation.dart';

// Re-export CoinSide so existing imports continue working seamlessly
export 'coin_orientation.dart' show CoinSide;

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

  int get headsCount => tossHistory.where((s) => s == CoinSide.heads).length;
  int get tailsCount => tossHistory.where((s) => s == CoinSide.tails).length;
  int get totalTosses => tossHistory.length;
}

class CoinNotifier extends StateNotifier<CoinState> {
  final Random _random = Random();

  CoinNotifier()
      : super(CoinState(
          lastResult: CoinSide.heads,
          isFlipping: false,
          tossHistory: [],
        )) {
    _loadHistory();
  }

  void _loadHistory() {
    if (!StorageService.isBoxOpen(StorageService.statsBoxName)) return;
    final box = StorageService.getStatsBox();
    final List<dynamic>? historyRaw = box.get('coin_history');
    if (historyRaw != null) {
      final history = historyRaw
          .map((e) => CoinSide.values.firstWhere(
                (element) => element.name == e,
                orElse: () => CoinSide.heads,
              ))
          .toList();
      state = state.copyWith(tossHistory: history);
    }
  }

  /// Resets the current visible coin to default Heads without wiping history.
  void resetCoin() {
    if (state.isFlipping) return;
    state = state.copyWith(lastResult: CoinSide.heads);
  }

  /// Initiates a deterministic physical coin toss sequence.
  ///
  /// Flow:
  /// 1. Logical random result generated first
  /// 2. State published with target result & isFlipping: true so 3D renderer animates to exact target
  /// 3. Physical flip timeline completes
  /// 4. History recorded, state marked complete (isFlipping: false)
  Future<void> toss() async {
    if (state.isFlipping) return;

    // 1. Generate authoritative logical result first
    final CoinSide result = _random.nextBool() ? CoinSide.heads : CoinSide.tails;

    // 2. Publish target result immediately so visual renderer computes target orientation
    state = state.copyWith(
      lastResult: result,
      isFlipping: true,
    );

    // 3. Await duration matching physical 3D animation timeline
    await Future.delayed(CoinMotionConfig.flipDuration);

    // 4. Update history upon settling
    final updatedHistory = List<CoinSide>.from(state.tossHistory)..insert(0, result);
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      isFlipping: false,
      tossHistory: updatedHistory,
    );

    // Save history & statistics in storage
    if (StorageService.isBoxOpen(StorageService.statsBoxName)) {
      final box = StorageService.getStatsBox();
      await box.put('coin_history', updatedHistory.map((e) => e.name).toList());

      final totalTosses = box.get('total_coin_tosses', defaultValue: 0) as int;
      await box.put('total_coin_tosses', totalTosses + 1);
    }

    // Analytics event
    AnalyticsService.trackCoinToss(result.name);
  }

  void clearHistory() {
    state = state.copyWith(tossHistory: []);
    if (StorageService.isBoxOpen(StorageService.statsBoxName)) {
      StorageService.getStatsBox().delete('coin_history');
    }
  }
}

final coinProvider = StateNotifierProvider<CoinNotifier, CoinState>((ref) {
  return CoinNotifier();
});
