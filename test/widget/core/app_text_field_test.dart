import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

void main() {
  testWidgets('prefix renders and is not part of the text', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(controller: c, prefix: const Text('+95')),
        ),
      ),
    );
    // Unfocused and empty: prefix must still be visible.
    expect(find.text('+95'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('+95'),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );
    await tester.enterText(find.byType(TextField), '9254135592');
    expect(c.text, '9254135592');
  });

  testWidgets('errorText uses error color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            errorText: 'bad',
          ),
        ),
      ),
    );
    expect(tester.widget<Text>(find.text('bad')).style!.color, AppColors.error);
  });

  testWidgets('error shows with themed field-radius border', (tester) async {
    final b =
        AppTheme.light.inputDecorationTheme.errorBorder as OutlineInputBorder;
    expect(b.borderRadius, BorderRadius.circular(AppSpacing.fieldRadius));
    expect(b.borderSide.color, AppColors.error);
    final f =
        AppTheme.light.inputDecorationTheme.focusedErrorBorder
            as OutlineInputBorder;
    expect(f.borderRadius, BorderRadius.circular(AppSpacing.fieldRadius));
  });
}
