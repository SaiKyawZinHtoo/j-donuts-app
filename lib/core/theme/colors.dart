part of '../core_import.dart';

/// Semantic color tokens. Widgets must read from here, never literal colors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF34C4E8); // cyan
  static const Color primaryDisabled = Color(0xFFBCB2B6);
  static const Color accent = Color(0xFFE6197F); // pink
  static const Color ringCyan = Color(0xFFBCE9F6);
  static const Color ringPinkLight = Color(0xFFFFB0D4);
  static const Color ringPinkMid = Color(0xFFF77DB8);
  static const Color ringPink = Color(0xFFF259A1);
  static const Color background = Color(0xFFFFFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF2FAE63);
  static const Color textPrimary = Color(0xFF231A1E);
  static const Color textSecondary = Color(0xFF8A7A80);
  static const Color hint = Color(0x808A7A80); // textSecondary @50%
  static const Color border = Color(0xFFEBD9DF);
  static const Color tileCyan = Color(0xFF35C4E8);
  static const Color tileBeige = Color(0xFFF9DCCB);
  static const Color tileBlue = Color(0xFFBFD8F2);
  static const Color tilePurple = Color(0xFFCBB8EE);

  static const List<Color> gradientColors = [
    Color(0xFFFDD6E5),
    Color(0xFFFEE1EB),
    Color(0xFFFFEAF1),
    Color(0xFFFEF2F6),
    Color(0xFFFEFEFE),
  ];
  static const List<double> gradientStops = [0, 0.3, 0.5, 0.7, 1];
  static const Color badge = Color(0xFFF28B30);
  static const Color pageGrey = Color(0xFFEEF0F2);
  static const Color navBar = Color(0xFF77CDE6);
  static const Color navPill = Color(0xFFE8629F);
  static const Color tierBronze = Color(0xFFD9A06B);
  static const Color tierSilver = Color(0xFFC4C7CC);
  static const Color avatarGold = Color(0xFFF7B84B);
  static const Color tierGold = Color(0xFFF0D27C);
  static const Color tierPlatinum = Color(0xFFBFE3F2);
  static const Color headerPeach = Color(0xFFFCE3D0);
}
