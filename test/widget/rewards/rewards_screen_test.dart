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

  Future<void> pumpRewards(WidgetTester tester, String tier, int points, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const challenges = [
      Challenge(id: 'c1', title: 'Eat 4 Coco donuts', current: 4, target: 4, rewardPts: 100, artType: 'donut'),
      Challenge(id: 'c2', title: 'Drink 12 cups americano', current: 9, target: 12, rewardPts: 150, artType: 'coffee'),
      Challenge(id: 'c3', title: 'Try 3 Matcha donuts', current: 1, target: 3, rewardPts: 80, artType: 'donut'),
    ];
    when(() => mockGetRewards.call()).thenAnswer((_) async => Result.ok(RewardsBundle(
          member: Member(
            id: 'm1',
            name: 'Shan',
            photoUrl: '',
            tier: tier,
            points: points,
            nextTierPoints: 2000,
            totalPoints: 680000,
          ),
          challenges: challenges,
        )));
    final bloc = RewardsBloc(getRewardsUseCase: mockGetRewards)..add(const RewardsRequested());
    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
  }

  for (final size in const [Size(360, 740), Size(430, 932)]) {
    testWidgets('layout: no overflow, comma total, 3 tiers at $size', (tester) async {
      await pumpRewards(tester, 'Silver', 1500, size);
      expect(tester.takeException(), isNull);
      expect(find.text('680,000'), findsOneWidget);
      expect(find.text('Silver'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Platinum'), findsOneWidget);
      expect(find.text("You're here now"), findsOneWidget);
      expect(find.text('500 pts Remaining to become Gold'), findsOneWidget);
      expect(find.text("You'll be here soon"), findsOneWidget);
      expect(find.text('Eat more earn more'), findsOneWidget);
      expect(find.byKey(const Key('rewardsBadge')), findsOneWidget);
    });
  }

  testWidgets('top tier shows the last three tiers', (tester) async {
    await pumpRewards(tester, 'Platinum', 2000, const Size(360, 740));
    expect(find.text('Bronze'), findsNothing);
    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Reached'), findsNWidgets(2));
    expect(find.text("You're here now"), findsOneWidget);
  });
}
