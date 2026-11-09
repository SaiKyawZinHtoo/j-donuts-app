part of '../core_import.dart';

/// Font families bundled in `assets/fonts/` (declared in pubspec.yaml).
/// Widgets never name a family: they use [AppTextStyles].
class AppFonts {
  AppFonts._();

  /// Headings, every bold text and button labels.
  static const String heading = 'Mija';

  /// Body text and the app-wide default.
  static const String body = 'InterDisplay';
}
