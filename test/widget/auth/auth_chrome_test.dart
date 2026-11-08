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

  void expectChrome(WidgetTester tester, RegistrationStep step) {
    expect(find.byType(AuthScaffold), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    final ring = tester.widget<RegistrationProgressRing>(
      find.byType(RegistrationProgressRing),
    );
    expect(ring.step, step);
  }

  testWidgets('OtpScreen: AuthScaffold + otp ring', (tester) async {
    await pump(tester, const OtpScreen());
    expectChrome(tester, RegistrationStep.otp);
  });

  testWidgets('NameScreen: AuthScaffold + name ring', (tester) async {
    await pump(tester, const NameScreen());
    expectChrome(tester, RegistrationStep.name);
  });

  testWidgets('DobScreen: AuthScaffold + dob ring, check when valid', (
    tester,
  ) async {
    await pump(tester, const DobScreen());
    expectChrome(tester, RegistrationStep.dob);
    expect(find.byIcon(Icons.check), findsNothing);
    await tester.enterText(find.byKey(const Key('dobMonthField')), '01');
    await tester.enterText(find.byKey(const Key('dobDayField')), '15');
    await tester.enterText(find.byKey(const Key('dobYearField')), '1990');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('WelcomeScreen: no back button, no legal footer', (tester) async {
    await pump(tester, const WelcomeScreen());
    expect(find.byType(AuthScaffold), findsOneWidget);
    expect(find.byType(AppBackButton), findsNothing);
    expect(find.byType(AppLegalFooter), findsNothing);
    expect(find.byKey(const Key('letsExploreButton')), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
