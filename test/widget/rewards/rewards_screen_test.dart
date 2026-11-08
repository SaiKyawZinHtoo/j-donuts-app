import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';

class MockGetRewardsUseCase extends Mock implements GetRewardsUseCase {}

Widget makeTestableWidget(RewardsBloc bloc) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<RewardsBloc>.value(value: bloc, child: const RewardsScreen()),
  );
}

void main() {
  late MockGetRewardsUseCase mockGetRewards;

  setUp(() {
    mockGetRewards = MockGetRewardsUseCase();
  });

  RewardsBundle bundleWith(Challenge challenge) => RewardsBundle(
        member: const Member(
          id: 'm1',
          name: 'Shan',
          photoUrl: '',
          tier: 'Silver',
          points: 100,
          nextTierPoints: 500,
          totalPoints: 100,
        ),
        challenges: [challenge],
      );

  testWidgets('Earn button is disabled below target', (tester) async {
    const challenge =
        Challenge(id: 'c1', title: 'Buy 3', current: 1, target: 3, rewardPts: 50, artType: 'donut');
    when(() => mockGetRewards.call()).thenAnswer((_) async => Result.ok(bundleWith(challenge)));

    final bloc = RewardsBloc(getRewardsUseCase: mockGetRewards)..add(const RewardsRequested());

    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final button = tester.widget<AppButton>(find.byKey(const Key('challengeEarnButton_c1')));
    expect(button.onPressed, isNull);
  });

  testWidgets('Earn button is enabled at target', (tester) async {
    const challenge =
        Challenge(id: 'c1', title: 'Buy 3', current: 3, target: 3, rewardPts: 50, artType: 'donut');
    when(() => mockGetRewards.call()).thenAnswer((_) async => Result.ok(bundleWith(challenge)));

    final bloc = RewardsBloc(getRewardsUseCase: mockGetRewards)..add(const RewardsRequested());

    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final button = tester.widget<AppButton>(find.byKey(const Key('challengeEarnButton_c1')));
    expect(button.onPressed, isNotNull);
  });
}
