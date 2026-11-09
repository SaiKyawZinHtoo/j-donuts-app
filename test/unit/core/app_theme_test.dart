import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

void main() {
  test('AppTheme.light matches reference tokens', () {
    final shape = AppTheme.light.elevatedButtonTheme.style!.shape!.resolve(
      <WidgetState>{},
    ) as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(AppSpacing.buttonRadius));
    expect(AppTheme.light.appBarTheme.backgroundColor, Colors.transparent);
    expect(AppTheme.light.inputDecorationTheme.filled, true);
    expect(AppColors.gradientColors.length, AppColors.gradientStops.length);
    expect(
      AppTheme.light.inputDecorationTheme.floatingLabelStyle?.color,
      AppColors.accent,
    );
    final fg = AppTheme.light.textButtonTheme.style!.foregroundColor!.resolve(
      <WidgetState>{},
    );
    expect(fg, AppColors.accent);
    expect(AppColors.primary, const Color(0xFF34C4E8));
  });
}
