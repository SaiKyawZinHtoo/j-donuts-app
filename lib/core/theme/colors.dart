part of '../core_import.dart';

/// Semantic color tokens. Widgets must read from here, never literal colors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF34C4E8); // cyan
  static const Color primaryDisabled = Color(0xFFBCB2B6);
  static const Color accent = Color(0xFFE6197F); // pink
  static const Color ringCyan = Color(0xFF64CDE9);
  static const Color ringPink = Color(0xFFF259A1);
  static const Color background = Color(0xFFFFFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF2FAE63);
  static const Color textPrimary = Color(0xFF231A1E);
  static const Color textSecondary = Color(0xFF8A7A80);
  static const Color border = Color(0xFFEBD9DF);

  static const List<Color> gradientColors = [
    Color(0xFFFDD6E5),
    Color(0xFFFEE1EB),
    Color(0xFFFFEAF1),
    Color(0xFFFEF2F6),
    Color(0xFFFEFEFE),
  ];
  static const List<double> gradientStops = [0, 0.3, 0.5, 0.7, 1];
}
