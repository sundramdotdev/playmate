import 'package:flutter/services.dart';

class SoundService {
  static Future<void> playRollSound() async {
    // Standard system tick sound as a fallback/clean roll feedback
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playTossSound() async {
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> triggerHaptic() async {
    await HapticFeedback.mediumImpact();
  }
}
