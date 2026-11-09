import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AwaitingName());
  });

  final first = find.byKey(const Key('firstNameField'));
  final last = find.byKey(const Key('lastNameField'));

  Future<void> pump(WidgetTester tester) =>
      tester.pumpWidget(makeTestableWidget(const NameScreen(), bloc: bloc));

  Future<void> typeIn(WidgetTester tester, Finder f, String text) async {
    await tester.tap(f);
    await tester.enterText(f, text);
    await tester.pump();
  }

  Future<void> blur(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  testWidgets('first name with digits shows message only after blur', (
    tester,
  ) async {
    await pump(tester);
    await typeIn(tester, first, 'Ye123');
    expect(find.text('First name must contain only letters.'), findsNothing);
    await blur(tester);
    expect(
      find.text('First name must contain only letters.'),
      findsOneWidget,
    );
  });

  testWidgets('message clears once the first name is fixed', (tester) async {
    await pump(tester);
    await typeIn(tester, first, 'Ye123');
    await blur(tester);
    await typeIn(tester, first, 'Ye');
    expect(find.text('First name must contain only letters.'), findsNothing);
  });

  testWidgets('empty first name shows no message on blur', (tester) async {
    await pump(tester);
    await tester.tap(first);
    await tester.pump();
    await blur(tester);
    expect(find.textContaining('First name must'), findsNothing);
  });

  testWidgets('last name with digits shows message after blur', (tester) async {
    await pump(tester);
    await typeIn(tester, last, 'Lin99');
    await blur(tester);
    expect(find.text('Last name must contain only letters.'), findsOneWidget);
  });

  testWidgets('Myanmar digits in the name are flagged after blur', (
    tester,
  ) async {
    await pump(tester);
    await typeIn(tester, first, 'မျိုး၁၂၃');
    await blur(tester);
    expect(
      find.text('First name must contain only letters.'),
      findsOneWidget,
    );
  });
}
