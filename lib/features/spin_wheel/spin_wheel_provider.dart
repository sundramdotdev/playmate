import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import 'spin_wheel_models.dart';
import 'spin_wheel_motion_config.dart';

class SpinWheelState {
  final List<WheelOption> options;
  final WheelOption? selectedWinner;
  final bool isSpinning;
  final List<SpinWheelRecord> history;
  final String activePresetId;

  const SpinWheelState({
    required this.options,
    this.selectedWinner,
    required this.isSpinning,
    this.history = const [],
    this.activePresetId = 'truth_or_dare',
  });

  SpinWheelState copyWith({
    List<WheelOption>? options,
    WheelOption? selectedWinner,
    bool clearWinner = false,
    bool? isSpinning,
    List<SpinWheelRecord>? history,
    String? activePresetId,
  }) {
    return SpinWheelState(
      options: options ?? this.options,
      selectedWinner: clearWinner ? null : (selectedWinner ?? this.selectedWinner),
      isSpinning: isSpinning ?? this.isSpinning,
      history: history ?? this.history,
      activePresetId: activePresetId ?? this.activePresetId,
    );
  }

  /// Convenience getter for backward compatibility
  String? get selectedResult => selectedWinner?.label;

  /// Total spins recorded
  int get totalSpins => history.length;
}

class SpinWheelNotifier extends StateNotifier<SpinWheelState> {
  final Random _random = Random();

  SpinWheelNotifier()
      : super(SpinWheelState(
          options: SpinWheelPreset.builtInPresets.first.toOptions(),
          isSpinning: false,
          history: const [],
          activePresetId: 'truth_or_dare',
        )) {
    _loadPersistedData();
  }

  void _loadPersistedData() {
    if (!StorageService.isBoxOpen(StorageService.statsBoxName)) return;
    final box = StorageService.getStatsBox();

    // 1. Load custom options if saved
    final List<dynamic>? savedOptionsRaw = box.get('spin_wheel_options');
    List<WheelOption>? loadedOptions;
    if (savedOptionsRaw != null && savedOptionsRaw.isNotEmpty) {
      try {
        loadedOptions = savedOptionsRaw
            .map((e) => WheelOption.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        loadedOptions = null;
      }
    }

    // 2. Load history
    final List<dynamic>? savedHistoryRaw = box.get('spin_wheel_history');
    List<SpinWheelRecord> loadedHistory = [];
    if (savedHistoryRaw != null) {
      try {
        loadedHistory = savedHistoryRaw
            .map((e) => SpinWheelRecord.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        loadedHistory = [];
      }
    }

    final String savedPresetId =
        box.get('spin_wheel_active_preset', defaultValue: 'truth_or_dare') as String;

    if (loadedOptions != null && loadedOptions.length >= 2) {
      state = state.copyWith(
        options: loadedOptions,
        history: loadedHistory,
        activePresetId: savedPresetId,
      );
    } else {
      state = state.copyWith(
        history: loadedHistory,
        activePresetId: savedPresetId,
      );
    }
  }

  Future<void> _persistOptions() async {
    if (!mounted || !StorageService.isBoxOpen(StorageService.statsBoxName)) return;
    final box = StorageService.getStatsBox();
    await box.put(
      'spin_wheel_options',
      state.options.map((o) => o.toJson()).toList(),
    );
    if (!mounted) return;
    await box.put('spin_wheel_active_preset', state.activePresetId);
  }

  Future<void> _persistHistory() async {
    if (!mounted || !StorageService.isBoxOpen(StorageService.statsBoxName)) return;
    final box = StorageService.getStatsBox();
    await box.put(
      'spin_wheel_history',
      state.history.map((r) => r.toJson()).toList(),
    );
    final totalSpins = box.get('total_wheel_spins', defaultValue: 0) as int;
    await box.put('total_wheel_spins', totalSpins + 1);
  }

  /// Adds a new option to the wheel. Minimum 2 options constraint is respected.
  void addOption(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    if (state.options.length >= 16) return; // Prevent unreasonable segment squeeze

    final newOption = WheelOption(
      id: 'opt_${DateTime.now().microsecondsSinceEpoch}',
      label: trimmed,
    );

    state = state.copyWith(
      options: [...state.options, newOption],
      activePresetId: 'custom',
    );
    _persistOptions();
  }

  /// Updates the label of an existing option by [id].
  void updateOption(String id, String newLabel) {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty) return;

    final updated = state.options.map((opt) {
      if (opt.id == id) {
        return opt.copyWith(label: trimmed);
      }
      return opt;
    }).toList();

    state = state.copyWith(
      options: updated,
      activePresetId: 'custom',
    );
    _persistOptions();
  }

  /// Removes an option by [id]. Wheel requires at least 2 options to operate.
  void removeOptionById(String id) {
    if (state.options.length <= 2) return;

    final updated = state.options.where((opt) => opt.id != id).toList();
    state = state.copyWith(
      options: updated,
      clearWinner: state.selectedWinner?.id == id,
      activePresetId: 'custom',
    );
    _persistOptions();
  }

  /// Removes the currently selected winner from the wheel (game-night elimination mechanic).
  void removeWinner() {
    if (state.selectedWinner == null || state.options.length <= 2) return;
    removeOptionById(state.selectedWinner!.id);
  }

  /// For backward compatibility with existing string removal
  void removeOption(String label) {
    final match = state.options.where((opt) => opt.label == label).toList();
    if (match.isNotEmpty) {
      removeOptionById(match.first.id);
    }
  }

  /// Loads a predefined game-night preset.
  void applyPreset(SpinWheelPreset preset) {
    if (state.isSpinning) return;
    state = state.copyWith(
      options: preset.toOptions(),
      clearWinner: true,
      activePresetId: preset.id,
    );
    _persistOptions();
  }

  /// Initiates an authoritative, deterministic spin sequence.
  ///
  /// Flow:
  /// 1. Logical random winner is chosen immediately.
  /// 2. State published with `selectedWinner` and `isSpinning: true`.
  /// 3. Physical wheel widget animates decelerating smoothly onto that exact sector.
  /// 4. After timeline completes, history and statistics are committed, `isSpinning: false`.
  Future<void> spin() async {
    if (state.isSpinning || state.options.length < 2) return;

    // 1. Authoritative logical outcome picked first
    final int winnerIndex = _random.nextInt(state.options.length);
    final WheelOption chosenWinner = state.options[winnerIndex];

    // 2. Publish target winner immediately so the renderer targets this sector
    state = state.copyWith(
      isSpinning: true,
      selectedWinner: chosenWinner,
    );

    // 3. Await duration matching the physical spin timeline
    await Future.delayed(SpinWheelMotionConfig.spinDuration);

    // 4. Record to history upon settling
    final record = SpinWheelRecord(
      winnerLabel: chosenWinner.label,
      timestamp: DateTime.now(),
    );

    final updatedHistory = List<SpinWheelRecord>.from(state.history)..insert(0, record);
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      isSpinning: false,
      selectedWinner: chosenWinner,
      history: updatedHistory,
    );

    await _persistHistory();
    AnalyticsService.trackSpinWheelUsed();
  }

  /// Clears historical outcomes
  void clearHistory() {
    state = state.copyWith(history: const []);
    if (StorageService.isBoxOpen(StorageService.statsBoxName)) {
      StorageService.getStatsBox().delete('spin_wheel_history');
    }
  }

  /// Resets to default preset
  void resetOptions() {
    applyPreset(SpinWheelPreset.builtInPresets.first);
  }
}

final spinWheelProvider =
    StateNotifierProvider<SpinWheelNotifier, SpinWheelState>((ref) {
  return SpinWheelNotifier();
});
