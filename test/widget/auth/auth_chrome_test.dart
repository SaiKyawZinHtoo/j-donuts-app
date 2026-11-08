import 'package:bloc_test/bloc_test.dart';
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

  Future<void> enterDob(WidgetTester t, String m, String d, String y) async {
    await t.enterText(find.byKey(const Key('dobMonthField')), m);
    await t.enterText(find.byKey(const Key('dobDayField')), d);
    await t.enterText(find.byKey(const Key('dobYearField')), y);
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
    await pump(tester, const DobScreen());
    expectChrome(tester, RegistrationStep.dob);
    expect(find.byIcon(Icons.check), findsNothing);
    await enterDob(tester, '01', '15', '1990');
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(continueEnabled(tester), isTrue);
    await expectBackDispatches(tester);
  });

  testWidgets('DobScreen: invalid dates show no check, Continue disabled', (
    tester,
  ) async {
    await pump(tester, const DobScreen());
    for (final d in [
      ['13', '01', '1990'],
      ['02', '30', '1990'],
    ]) {
      await enterDob(tester, d[0], d[1], d[2]);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(continueEnabled(tester), isFalse);
    }
  });

  testWidgets('WelcomeScreen: no back button, no legal footer', (tester) async {
    await pump(tester, const WelcomeScreen());
    expect(tester.widget<AuthScaffold>(find.byType(AuthScaffold)).titleGap, isFalse);
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
