part of '../core_import.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: _fieldBorder(AppColors.border),
      enabledBorder: _fieldBorder(AppColors.border),
      focusedBorder: _fieldBorder(AppColors.accent),
    ),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: AppColors.accent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        )),
        minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSpacing.buttonHeight)),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? AppColors.primaryDisabled
                : AppColors.primary),
        textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
      ),
    ),
  );

  static OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: BorderSide(color: color),
      );
}
