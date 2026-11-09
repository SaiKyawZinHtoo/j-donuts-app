import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/home/home_import.dart';

Widget _app(Widget body) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: body),
);

void main() {
  testWidgets('AppBadge has a 1px white border and bold 14px text', (t) async {
    await t.pumpWidget(_app(const AppBadge(label: '50% off')));
    final box = t.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AppBadge),
        matching: find.byType(DecoratedBox),
      ),
    );
    final border = (box.decoration as BoxDecoration).border as Border;
    expect(border.top.width, 1);
    expect(border.top.color, AppColors.surface);
    final text = t.widget<Text>(find.text('50% off'));
    expect(text.style?.fontSize, 14);
    expect(text.style?.fontFamily, AppFonts.heading);
  });

  testWidgets('banner badge shown; peach ends at the banner bottom', (t) async {
    await t.pumpWidget(
      _app(
        SingleChildScrollView(
          child: MemberHeader(
            member: const Member(
              id: 'm',
              name: 'Hania',
              photoUrl: 'assets/images/seed/member_avatar.png',
              tier: 'Bronze',
              points: 710,
              nextTierPoints: 2000,
              totalPoints: 710,
            ),
            footer: const BannerCarousel(
              banners: [
                BannerItem(
                  id: 'b',
                  imageUrl: 'assets/images/seed/banner_seasonal.png',
                  title: 'Hello',
                  badge: 'New shop',
                  deepLinkTarget: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await t.pump();
    expect(find.text('New shop'), findsOneWidget);
    expect(
      t.getRect(find.byType(BannerCarousel)).bottom,
      closeTo(t.getRect(find.byType(MemberHeader)).bottom, 0.5),
    );
    final chip = t.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('memberHeader_pointsChip')),
        matching: find.byType(Text),
      ),
    );
    expect(chip.style?.color, AppColors.textPrimary);
  });
}
