import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

void main() {
  test('registration ring blue is the lighter cyan', () {
    expect(AppColors.ringCyan, const Color(0xFF9BDDF0));
    // Lighter than the previous 0xFF64CDE9.
    expect(
      AppColors.ringCyan.computeLuminance(),
      greaterThan(const Color(0xFF64CDE9).computeLuminance()),
    );
  });

  test('button text is bold with 2 px letter spacing', () {
    expect(AppTextStyles.button.fontWeight, FontWeight.w700);
    expect(AppTextStyles.button.letterSpacing, 2);
  });

  test('phone hint starts with 09 in English and Burmese', () {
    expect(lookupAppLocalizations(const Locale('en')).phoneHint, '09xxxxxxxx');
    expect(lookupAppLocalizations(const Locale('my')).phoneHint, '09xxxxxxxx');
  });

  test('field labels are faded until the label floats', () {
    final theme = AppTheme.light.inputDecorationTheme;
    expect(theme.labelStyle?.color, AppColors.hint);
    expect(theme.floatingLabelStyle?.color, AppColors.accent);
  });
}
