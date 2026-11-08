part of '../core_import.dart';

/// Semantic color tokens. Widgets must read from here, never literal colors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE85A8A); // pink
  static const Color accent = Color(0xFF2AB5A5); // teal
  static const Color background = Color(0xFFFFFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF2FAE63);
  static const Color textPrimary = Color(0xFF231A1E);
  static const Color textSecondary = Color(0xFF8A7A80);
  static const Color border = Color(0xFFEBD9DF);
}
