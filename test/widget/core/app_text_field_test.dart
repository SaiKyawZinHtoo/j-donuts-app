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
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('+95'), findsOneWidget);
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
}
