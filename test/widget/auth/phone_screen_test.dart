import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc bloc;

  setUpAll(() => registerFallbackValue(const PhoneSubmitted('')));

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthInitial());
  });

  Future<void> pump(WidgetTester tester, {bool isLogin = false}) =>
      tester.pumpWidget(
        makeTestableWidget(PhoneScreen(isLogin: isLogin), bloc: bloc),
      );

  PhoneSubmitted captured() =>
      verify(() => bloc.add(captureAny())).captured.single as PhoneSubmitted;

  Future<PhoneSubmitted> submit(WidgetTester tester, String typed) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('phoneNumberField')), typed);
    await tester.pump();
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pump();
    return captured();
  }

  testWidgets('+95 prefix visible when empty and not part of the text', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('+95'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('local 09 number normalizes to +959254135592', (tester) async {
    final e = await submit(tester, '09254135592');
    expect(normalizePhone(e.raw), '+959254135592');
  });

  testWidgets('pasted +95 number is not doubled', (tester) async {
    final e = await submit(tester, '+959254135592');
    expect(normalizePhone(e.raw), '+959254135592');
    expect(e.raw, isNot(contains('+95')));
    expect(normalizePhone(e.raw), isNot(contains('+95+95')));
    expect(normalizePhone(e.raw), isNot(contains('+9595')));
  });

  testWidgets('login mode: title, LOGIN button, fingerprint, no ring', (
    tester,
  ) async {
    await pump(tester, isLogin: true);
    expect(find.text('Welcome back, Login to your profile'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byKey(const Key('fingerprintButton')), findsOneWidget);
    expect(find.byType(RegistrationProgressRing), findsNothing);
  });

  testWidgets('register mode shows ring and no fingerprint', (tester) async {
    await pump(tester);
    expect(find.byType(RegistrationProgressRing), findsOneWidget);
    expect(find.byKey(const Key('fingerprintButton')), findsNothing);
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  group('inline message on blur', () {
    final field = find.byKey(const Key('phoneNumberField'));

    Future<void> type(WidgetTester tester, String text) async {
      await tester.tap(field);
      await tester.enterText(field, text);
      await tester.pump();
    }

    Future<void> blur(WidgetTester tester) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
    }

    testWidgets('invalid number shows message only after focus is lost', (
      tester,
    ) async {
      await pump(tester);
      await type(tester, '0912');
      expect(find.textContaining('digits after the leading 9'), findsNothing);
      await blur(tester);
      expect(find.textContaining('digits after the leading 9'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('continueButton')),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('message clears once the number becomes valid', (tester) async {
      await pump(tester);
      await type(tester, '0912');
      await blur(tester);
      await type(tester, '09254135592');
      expect(find.textContaining('digits after the leading 9'), findsNothing);
    });

    testWidgets('empty field shows no message on blur', (tester) async {
      await pump(tester);
      await tester.tap(field);
      await tester.pump();
      await blur(tester);
      expect(find.textContaining('Phone number must'), findsNothing);
    });
  });
}
