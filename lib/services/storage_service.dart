import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String settingsBoxName = 'settings';
  static const String matchBoxName = 'matches';
  static const String achievementsBoxName = 'achievements';
  static const String statsBoxName = 'statistics';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open all necessary boxes concurrently to minimize splash startup delay
    await Future.wait([
      Hive.openBox(settingsBoxName),
      Hive.openBox(matchBoxName),
      Hive.openBox(achievementsBoxName),
      Hive.openBox(statsBoxName),
    ]);
  }

  static Box getSettingsBox() => Hive.box(settingsBoxName);
  static Box getMatchBox() => Hive.box(matchBoxName);
  static Box getAchievementsBox() => Hive.box(achievementsBoxName);
  static Box getStatsBox() => Hive.box(statsBoxName);
  static bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  // Helper getters/setters for simple state
  static bool isDarkMode() {
    return getSettingsBox().get('dark_mode', defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool value) async {
    await getSettingsBox().put('dark_mode', value);
  }

  static Future<void> clearAllData() async {
    await getMatchBox().clear();
    await getAchievementsBox().clear();
    await getStatsBox().clear();
  }
}
