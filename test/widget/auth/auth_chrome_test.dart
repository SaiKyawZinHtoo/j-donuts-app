import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const OtpAwaiting(30));
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(makeTestableWidget(screen, bloc: bloc));
    await tester.pump();
  }

  Future<void> pickDob(WidgetTester t, DateTime d) async {
    await pump(t, DobScreen(pickDate: (_, _) async => d));
    await t.tap(find.byKey(const Key('dobMonthField')));
    await t.pumpAndSettle();
  }

  bool continueEnabled(WidgetTester t) =>
      t.widget<AppButton>(find.byKey(const Key('continueButton'))).onPressed !=
      null;

  void expectChrome(WidgetTester tester, RegistrationStep step) {
    expect(find.byType(AuthScaffold), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    final ring = tester.widget<RegistrationProgressRing>(
      find.byType(RegistrationProgressRing),
    );
    expect(ring.step, step);
  }

  Future<void> expectBackDispatches(WidgetTester tester) async {
    await tester.tap(find.byType(AppBackButton));
    await tester.pump();
    verify(() => bloc.add(const BackRequested())).called(1);
  }

  testWidgets('OtpScreen: AuthScaffold + otp ring', (tester) async {
    await pump(tester, const OtpScreen());
    expectChrome(tester, RegistrationStep.otp);
    await expectBackDispatches(tester);
  });

  testWidgets('NameScreen: AuthScaffold + name ring', (tester) async {
    await pump(tester, const NameScreen());
    expectChrome(tester, RegistrationStep.name);
    await expectBackDispatches(tester);
  });

  testWidgets('DobScreen: AuthScaffold + dob ring, check when valid', (
    tester,
  ) async {
    await pump(
      tester,
      DobScreen(pickDate: (_, _) async => DateTime(1990, 1, 15)),
    );
    expectChrome(tester, RegistrationStep.dob);
    expect(find.byIcon(Icons.check), findsNothing);
    await tester.tap(find.byKey(const Key('dobMonthField')));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget);
    expect(find.text('1990'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(continueEnabled(tester), isTrue);
    await expectBackDispatches(tester);
  });

  testWidgets('DobScreen: under-13 date shows error, no check, Continue off', (
    tester,
  ) async {
    final now = DateTime.now();
    await pickDob(tester, DateTime(now.year - 5, now.month, now.day));
    expect(find.byIcon(Icons.check), findsNothing);
    expect(continueEnabled(tester), isFalse);
    expect(find.textContaining('at least'), findsOneWidget);
  });

  testWidgets('DobScreen: Android opens the Material calendar dialog', (
    tester,
  ) async {
    await pump(tester, const DobScreen());
    await tester.tap(find.byKey(const Key('dobYearField')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('DobScreen: iOS opens the Cupertino wheel sheet', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pump(tester, const DobScreen());
    await tester.tap(find.byKey(const Key('dobDayField')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await tester.tap(find.byKey(const Key('dobPickerDone')));
    await tester.pumpAndSettle();
    expect(continueEnabled(tester), isTrue);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('WelcomeScreen: no back button, no legal footer', (tester) async {
    await pump(tester, const WelcomeScreen());
    expect(
      tester.widget<AuthScaffold>(find.byType(AuthScaffold)).titleGap,
      isFalse,
    );
    expect(find.byType(AuthScaffold), findsOneWidget);
    expect(find.byType(AppBackButton), findsNothing);
    expect(find.byType(AppLegalFooter), findsNothing);
    expect(find.byKey(const Key('letsExploreButton')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('WelcomeScreen layout at ${scale}x: button at bottom', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: makeTestableWidget(const WelcomeScreen(), bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final button = tester.getRect(find.byKey(const Key('letsExploreButton')));
      final title = tester.getRect(find.text('Welcome!'));
      expect(button.bottom, greaterThan(0.7 * 667));
      expect(title.bottom, lessThan(button.top));
    });
  }
}
