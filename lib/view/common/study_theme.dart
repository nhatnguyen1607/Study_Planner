import 'package:flutter/material.dart';

abstract final class StudyColors {
  static const green800 = Color(0xFF237A38);
  static const green500 = Color(0xFF36A653);
  static const green400 = Color(0xFF58B96B);
  static const green100 = Color(0xFFD9EFDE);
  static const green50 = Color(0xFFEDF8EF);
  static const surface = Color(0xFFF8FBF8);
  static const border = Color(0xFFDCE7DE);
  static const textPrimary = Color(0xFF17231A);
  static const textSecondary = Color(0xFF627066);
  static const navy = Color(0xFF345D83);
  static const peach = Color(0xFFDF967E);
  static const danger = Color(0xFFA43E3E);
  static const yellow = Color(0xFFF4D578);
}

ThemeData buildStudyTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: StudyColors.green500,
    brightness: Brightness.light,
    surface: StudyColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: StudyColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: StudyColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: StudyColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
        color: StudyColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        color: StudyColors.textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha(235),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: StudyColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: StudyColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: StudyColors.green500, width: 1.6),
      ),
    ),
  );
}
