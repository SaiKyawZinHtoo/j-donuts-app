# Final fix wave
- I1: removed Home spacer; NearbyShopsRow bottom padding = paddingOf.bottom + md (backdrop runs behind nav). Test: home_screen_test end-of-scroll with bottom inset 34, asserts gap to viewport bottom <= 8 (old double-count gave ~194pt).
- M1: cutout Hero wraps image only (inside Padding). Test: product_card_test "cutout Hero wraps only the image".
- M2: semantics label "label, trailing". Test in app_button_test.
- M3: RefreshIndicator edgeOffset = top padding.
- M4: navInactive, 4 ARB keys (both locales), banner_rewards.png removed (unreferenced; addToCartButton was only a widget Key); gen-l10n regenerated.
- M7: member_header Colors.white -> AppColors.surface.
- M10: product detail scroll bottom padding += safe area.
- Verify: flutter analyze: 11 issues (infos); flutter test --no-pub: +193 All tests passed.
