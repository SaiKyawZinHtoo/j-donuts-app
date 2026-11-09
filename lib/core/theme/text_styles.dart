part of '../core_import.dart';

/// Typography scale. Widgets must read from here, never literal TextStyles.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    shadows: _boldDark,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    shadows: _boldDark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.surface,
    shadows: _boldWhite,
  );

  /// Banner headline on a coloured card.
  static const TextStyle bannerTitle = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
    shadows: _boldWhite,
  );

  /// Bold body text (Mija; every bold place uses the heading face).
  static const TextStyle bodyBold = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    shadows: _boldDark,
  );

  /// Bold small text (badges, nav labels).
  static const TextStyle captionBold = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    shadows: _boldGrey,
  );
}

/// Mija ships only a Regular weight, so "bold" is faked by drawing the glyphs
/// four more times, half a pixel off in each direction, in the text colour.
/// Remove this (and the [FauxBold.embolden] calls) once Mija Bold is bundled.
List<Shadow> _shadowsOf(Color c) => [
  Shadow(color: c, offset: const Offset(0.35, 0)),
  Shadow(color: c, offset: const Offset(-0.35, 0)),
  Shadow(color: c, offset: const Offset(0, 0.35)),
  Shadow(color: c, offset: const Offset(0, -0.35)),
];

const _boldDark = [
  Shadow(color: AppColors.textPrimary, offset: Offset(0.35, 0)),
  Shadow(color: AppColors.textPrimary, offset: Offset(-0.35, 0)),
  Shadow(color: AppColors.textPrimary, offset: Offset(0, 0.35)),
  Shadow(color: AppColors.textPrimary, offset: Offset(0, -0.35)),
];
const _boldWhite = [
  Shadow(color: AppColors.surface, offset: Offset(0.35, 0)),
  Shadow(color: AppColors.surface, offset: Offset(-0.35, 0)),
  Shadow(color: AppColors.surface, offset: Offset(0, 0.35)),
  Shadow(color: AppColors.surface, offset: Offset(0, -0.35)),
];
const _boldGrey = [
  Shadow(color: AppColors.textSecondary, offset: Offset(0.35, 0)),
  Shadow(color: AppColors.textSecondary, offset: Offset(-0.35, 0)),
  Shadow(color: AppColors.textSecondary, offset: Offset(0, 0.35)),
  Shadow(color: AppColors.textSecondary, offset: Offset(0, -0.35)),
];

extension FauxBold on TextStyle {
  /// Re-derives the faux-bold shadows from the current colour. Call it after
  /// any `copyWith(color: ...)` on a bold token so the thickening matches.
  TextStyle embolden() =>
      copyWith(shadows: _shadowsOf(color ?? AppColors.textPrimary));
}
