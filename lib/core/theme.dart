import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A1A), // Sleek charcoal
        brightness: Brightness.light,
        primary: const Color(0xFF1A1A1A),
        onPrimary: Colors.white,
        secondary: const Color(0xFF757575),
        surface: const Color(0xFFF9F9F9),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        color: const Color(0xFFF5F5F5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Color(0xFF1A1A1A)),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Color(0xFF1A1A1A)),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2C2C2C)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A1A),
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: const Color(0xFF121212),
        secondary: const Color(0xFF8E8E93),
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFA0A0A0)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
