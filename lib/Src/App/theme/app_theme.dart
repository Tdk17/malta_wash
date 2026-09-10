import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _brand = Color(0xFFFF6A00);
  static const _ink = Color(0xFF111827);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.light,
      surface: const Color(0xFFF7F8FA),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brand,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE7EAF0)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: _ink),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: _ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: _ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: _ink),
        bodyLarge: TextStyle(color: Color(0xFF374151)),
        bodyMedium: TextStyle(color: Color(0xFF4B5563)),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brand,
          brightness: Brightness.dark,
        ),
      );
}
