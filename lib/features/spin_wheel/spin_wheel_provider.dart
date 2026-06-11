import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/sound_service.dart';

class SpinWheelState {
  final List<String> options;
  final String? selectedResult;
  final bool isSpinning;

  SpinWheelState({
    required this.options,
    this.selectedResult,
    required this.isSpinning,
  });

  SpinWheelState copyWith({
    List<String>? options,
    String? selectedResult,
    bool? isSpinning,
  }) {
    return SpinWheelState(
      options: options ?? this.options,
      selectedResult: selectedResult ?? this.selectedResult,
      isSpinning: isSpinning ?? this.isSpinning,
    );
  }
}

class SpinWheelNotifier extends StateNotifier<SpinWheelState> {
  final Random _random = Random();

  SpinWheelNotifier() : super(SpinWheelState(
    options: ['Truth', 'Dare', 'Pass', 'Double Dare'],
    isSpinning: false,
  ));

  void addOption(String option) {
    final trimmed = option.trim();
    if (trimmed.isEmpty || state.options.contains(trimmed)) return;
    state = state.copyWith(options: [...state.options, trimmed]);
  }

  void removeOption(String option) {
    if (state.options.length <= 2) return; // Need at least 2 options to spin
    state = state.copyWith(
      options: List<String>.from(state.options)..remove(option),
      selectedResult: null,
    );
  }

  Future<void> spin() async {
    if (state.isSpinning || state.options.isEmpty) return;
    state = state.copyWith(isSpinning: true, selectedResult: null);

    // Dynamic tick simulation
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 100 + (i * 20)));
      SoundService.playRollSound();
    }

    final selected = state.options[_random.nextInt(state.options.length)];
    SoundService.triggerHaptic();

    state = state.copyWith(
      isSpinning: false,
      selectedResult: selected,
    );

    AnalyticsService.trackSpinWheelUsed();
  }

  void resetOptions() {
    state = SpinWheelState(
      options: ['Truth', 'Dare', 'Pass', 'Double Dare'],
      isSpinning: false,
    );
  }
}

final spinWheelProvider = StateNotifierProvider<SpinWheelNotifier, SpinWheelState>((ref) {
  return SpinWheelNotifier();
});
