import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';

Widget _host(Widget child, {required bool reduce}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  for (final reduce in [true, false]) {
    final expected = reduce ? Duration.zero : MotionTokens.kTabSwitchDuration;

    testWidgets('TabSwitcher durations (reduce=$reduce)', (tester) async {
      await tester.pumpWidget(
        _host(
          TabSwitcher(activeTab: RewardsTab.earn, onChanged: (_) {}),
          reduce: reduce,
        ),
      );
      for (final c in tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      )) {
        expect(c.duration, expected);
      }
    });

    testWidgets('ChallengeCard press scale duration (reduce=$reduce)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ChallengeCard(
            challenge: const Challenge(
              id: 'c1',
              title: 't',
              current: 1,
              target: 1,
              rewardPts: 5,
              artType: 'donut',
            ),
            entrance: const AlwaysStoppedAnimation(1),
          ),
          reduce: reduce,
        ),
      );
      // Outer scale is the card's; AppButton's own AnimatedScale is nested inside it.
      final outer = tester
          .widgetList<AnimatedScale>(find.byType(AnimatedScale))
          .first;
      expect(outer.duration, expected);
    });
  }
}
