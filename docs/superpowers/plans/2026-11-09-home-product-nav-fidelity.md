# Home / Product detail / Nav / Welcome Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Home, Product detail, the bottom nav and Welcome match the user's reference screenshots (8 Home, 9 Product detail, circled nav, 7 Welcome), with one shared product card and PDF-style motion.

**Architecture:** A shared `ProductCard` + `SectionHeader` in `lib/core/widgets` (part of `core_import.dart`), new tokens, bundled photos from jdonuts.com. Home widgets are restyled on top of them; `AppBottomNav` floats over content; Product detail and Welcome are rebuilt to the reference layout. All motion is gated by Reduce Motion.

**Tech Stack:** Flutter 3.47 / Dart 3.13, flutter_bloc, go_router 14, gen-l10n (ARB in `assets/l10n/`, `app_en.arb` + `app_my.arb`), Drift seed JSON in `assets/seed/`.

**Spec:** `docs/superpowers/specs/2026-11-09-home-product-nav-fidelity-design.md` (read it first; it is the authority). Prior overhaul spec: `docs/superpowers/specs/2026-11-08-ui-overhaul-design.md`.

## Global Constraints

- DRY: no second card widget; every product tile on Home is `ProductCard`.
- Tokens, not literals: colors in `AppColors`, sizes in `AppSpacing`, durations/curves in `MotionTokens` (`lib/core/theme/`).
- Part-of-barrel: files under `lib/core/widgets/` start with `part of '../core_import.dart';`, home files `part of '../../home_import.dart';`, product `part of '../../product_import.dart';`, auth `part of '../../auth_import.dart';`. Part files have no imports; register new parts in the barrel (`core_import.dart` etc.).
- Icons only from `Icons.*` / `CupertinoIcons.*`. Images bundled under `assets/images/seed/` (directory already registered in `pubspec.yaml`).
- Every animation checks `MediaQuery.disableAnimationsOf(context)`; the documented exception stays: `/product/:id` is a `CupertinoPage` (platform timing).
- Hero tags come only from `heroTagFor(sectionId, productId)`.
- Do not put `Spacer`/`Expanded` inside `AuthScaffold`'s child.
- New strings go in both `assets/l10n/app_en.arb` and `assets/l10n/app_my.arb`; run `flutter gen-l10n` (or `flutter pub get`) after.
- `flutter analyze` must stay at the 11 existing infos; `flutter test --no-pub` must stay green (currently 164 passing).
- Never stage the unrelated iOS Pod files (`ios/Flutter/*.xcconfig`, `ios/Podfile*`, `ios/Runner.*`, `devtools_options.yaml`). Commit with explicit paths.
- Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Review Focus

- Floating nav hides the last Home item if bottom padding is wrong (test at end of scroll).
- Same product in two sections must not duplicate a Hero tag (section-scoped).
- Text scale 1.3 must not overflow a card or the detail layout.
- Quantity pill overlapping the card edge must stay tappable (hit test outside the card's bounds).
- Offline/empty/error section states still render (`AppErrorState`, `AppEmptyState`) inside the new section layout.

---

### Task 1: Tokens, SectionHeader, ProductCard

**Files:**
- Modify: `lib/core/theme/colors.dart`, `lib/core/theme/spacing.dart`, `lib/core/theme/motion_tokens.dart`, `lib/core/core_import.dart`
- Create: `lib/core/widgets/product_card.dart`, `lib/core/widgets/section_header.dart`
- Test: `test/widget/core/product_card_test.dart`

**Interfaces:**
- Produces:
  - `AppColors.badge = Color(0xFFF28B30)`, `AppColors.pageGrey = Color(0xFFEEF0F2)`, `AppColors.headerPeach = Color(0xFFFCE3D0)` (values sampled from references; adjust by eye against `images/10.webp` only if visibly off).
  - `AppSpacing`: `cardRadius = 20`, `sectionGap = 24`, `headerRadius = 32`, `qtyPillHeight = 56`, `cardPhotoWidth = 320`, `cardCutoutWidth = 215`, `cardPhotoAspect = 1.5` (w/h), `cardCutoutAspect = 0.67`, `chevronButtonSize = 40`.
  - `MotionTokens`: `kQtyChange = 150ms`, `kDescriptionExpand = 250ms`, `kDetailEntrance = 400ms`.
  - `enum ProductCardImageMode { photo, cutout }`
  - `class ProductCard extends StatelessWidget { const ProductCard({super.key, required String imageUrl, required String title, required ProductCardImageMode mode, String? badgeLabel, String? heroTag, VoidCallback? onTap}); static double widthFor(ProductCardImageMode m); static double heightFor(BuildContext context, ProductCardImageMode m); }` — `heightFor` = image height (`width / aspect`) + title block for 2 lines at the current text scale.
  - `class SectionHeader extends StatelessWidget { const SectionHeader({super.key, required String title, VoidCallback? onTap}); }` — title (`AppTextStyles.h2`) left, white circular chevron button (`Icons.chevron_right`, size `chevronButtonSize`) right; `onTap == null` shows the existing "not implemented" snackbar via `AppSnackbar` is NOT required: keep the button inert when null.

- [ ] **Step 1: Write the failing test** `test/widget/core/product_card_test.dart` (host: `MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: ...))`, import `core_import.dart`). Cases:
  - photo mode and cutout mode each render the title text and an `Image` (use an `assets/images/seed/product_placeholder.png` path as `imageUrl`).
  - `badgeLabel: '50% off'` shows `find.text('50% off')`; `badgeLabel: null` shows none.
  - tapping the card calls `onTap` once.
  - with `MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(1.3)))`, `tester.takeException()` is null and the card's rendered height equals `ProductCard.heightFor(context, mode)` (±1).
  - `ProductCard.widthFor(photo) == AppSpacing.cardPhotoWidth`, `widthFor(cutout) == AppSpacing.cardCutoutWidth`.
- [ ] **Step 2: Run** `flutter test --no-pub test/widget/core/product_card_test.dart` → FAIL (symbols missing).
- [ ] **Step 3: Add tokens** as listed above to the three theme files.
- [ ] **Step 4: Implement `ProductCard`** in `lib/core/widgets/product_card.dart` and register `part 'widgets/product_card.dart';` and `part 'widgets/section_header.dart';` in `core_import.dart`. Image area: `photo` = `ClipRRect(cardRadius)` of `AppSmartImage(fit: BoxFit.cover)`; `cutout` = white `DecoratedBox` (radius `cardRadius`) with the image `BoxFit.contain` centered plus a soft shadow under it (a `BoxShadow` on a blurred ellipse is acceptable; keep it simple). Wrap image area in `Hero(tag: heroTag)` when `heroTag != null`. Badge: `Positioned` bottom-right of the image area, `AppColors.badge` pill, white bold text. Title: `AppTextStyles.h3`-weight bold (use the existing bold body style from `text_styles.dart`), `maxLines: 2`, ellipsis. Press feedback: `Listener` + `AnimatedScale(0.97, MotionTokens.kPressScaleDuration)`, no scale under Reduce Motion (same pattern as `AppButton`). Placeholder = `AppSkeleton`, error = `product_placeholder.png` (as in the current `ProductSectionList`).
- [ ] **Step 5: Implement `SectionHeader`** per the interface.
- [ ] **Step 6: Run** the test → PASS; run `flutter analyze` (no new issues).
- [ ] **Step 7: Commit** `git add lib/core test/widget/core/product_card_test.dart && git commit -m "feat: shared ProductCard and SectionHeader with tokens"` (plus trailer).

---

### Task 2: Assets and seed data

**Files:**
- Create (binary): `assets/images/seed/` photos listed below
- Modify: `assets/seed/products.json`, `assets/seed/sections.json`, `assets/seed/banners.json`, `assets/seed/member.json`, `assets/seed/shops.json`
- Possibly modify: the seed loader / DB seed version (find with `grep -rn "sections.json" lib`) so a fresh seed is applied.

**Interfaces:**
- Produces (exact filenames): `seasonal_1.png`, `seasonal_2.png` (box/seasonal photos, landscape), `shop_1.png`, `shop_2.png` (shop interiors), `banner_new_shop.png`, `banner_hot.png`, `shops_backdrop.png` (sky + clouds + grass, portrait/tall, usable as a `BoxFit.cover` background ≥ 1080px wide), `member_avatar.png` (replace existing; square). Keep every existing seed image path working.
- Seed contents: member name `Hania`, tier `Bronze`, `points`/`nextTierPoints` so the chip reads "1290 points left to become Gold Member" is NOT required to be exact — keep existing fields, set `name` to `Hania`, `tier` to `Bronze`; banners `b_seasonal` → `banner_new_shop.png`, `b_rewards` → `banner_hot.png`; `seasonal_specials` products use `seasonal_1.png`/`seasonal_2.png` as `imageUrl` (create two products `p_box_romance` "Mistletoe Romance box" discount 50 and `p_box_family` "Christmas Mix Family box" discount 50); shops get `shop_1.png`/`shop_2.png` via a new `imageUrl` field only if the `Shop` entity/DAO is extended in Task 5 (otherwise reuse and defer).

- [ ] **Step 1: Discover sources.** Reuse `/private/tmp/claude-501/-Users-shanlay-Desktop-j-donuts-app/f0f3d6e2-0259-42bf-bde0-1a39786ed98b/scratchpad/dl.py` as the pattern (UA header, `/_next/image?url=<quote(path, safe='')>&w=1080&q=90`; `w` must be an allowed width). Find product/box images via `https://jdonuts.com/api/products?country=mm` (non-Donuts categories) and shop/backdrop art by fetching `https://jdonuts.com/mm` HTML and grepping `<img`/`url(` for the shops section. Verify each saved file opens as an image (`file`, non-trivial size). If a source cannot be found, keep the existing asset, note it in the report, and continue.
- [ ] **Step 2: Save files** under the names above; resize anything over ~1 MB to ≤1080px wide (`sips -Z 1080`).
- [ ] **Step 3: Update seed JSON** as listed. Find how seeds reach the DB (`grep -rn "seed" lib/data`); if seeds load only once, bump the seed/schema marker or clear-and-reseed on version change so the new data appears; add a test only if you touch loader logic.
- [ ] **Step 4: Run** `flutter test --no-pub` → all pass (update any seed-count assertions deliberately, in the same commit).
- [ ] **Step 5: Commit** `git add assets && git commit -m "feat: bundle home photos and update seed data"`.

---

### Task 3: Home sections on ProductCard

**Files:**
- Modify: `lib/features/home/presentation/widgets/product_section_list.dart`, `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`
- Test: `test/widget/home/home_screen_test.dart`, `test/widget/home/home_stagger_hero_test.dart`

**Interfaces:**
- Consumes: `ProductCard`, `SectionHeader`, `ProductCard.heightFor` (Task 1); `heroTagFor`.
- Produces: ARB key `discountOff` = `"{percent}% off"` (en) with `@discountOff` placeholder `percent: int`; Burmese value `"{percent}% လျှော့ဈေး"`. `ProductSectionList` keeps its constructor `(section, errorMessage)` and tile key `productTile_<id>`. Mode choice: `section.id == 'seasonal_specials'` → `photo`; every other section → `cutout`.

- [ ] **Step 1: Write failing tests** in `home_screen_test.dart`: (a) a section with a discounted product shows `'50% off'`; a `isNew` product shows `'New'` and no discount text (new wins); (b) tapping `productTile_p1` still pushes `/product/p1` (existing test); (c) `ProductSectionList` for `seasonal_specials` renders a card whose width is `AppSpacing.cardPhotoWidth`, others `cardCutoutWidth`. In `home_stagger_hero_test.dart` keep the unique-Hero-tag test passing with a product in two sections.
- [ ] **Step 2: Run** the two files → FAIL.
- [ ] **Step 3: Rewrite `ProductSectionList.build`** to: keep the error/empty branches, then `Column[ SectionHeader(title), SizedBox(height: ProductCard.heightFor(context, mode)) with horizontal ListView.separated of ProductCard(...) ]`, wrapping each card in a `KeyedSubtree`/`Key('productTile_<id>')` and `onTap: () => context.push('/product/${id}', extra: heroTagFor(section.id, id))`. Badge label helper (private, in this file): `isNew ? l10n.newBadge : discountPercent > 0 ? l10n.discountOff(discountPercent) : null`. Remove the old inline tile and the 140px shortcut comment. Add the ARB keys and regenerate.
- [ ] **Step 4: Run** both test files → PASS; run `flutter analyze`.
- [ ] **Step 5: Commit** explicit paths (`lib/features/home assets/l10n test/widget/home`).

---

### Task 4: Member header and banner carousel

**Files:**
- Modify: `lib/features/home/presentation/widgets/member_header.dart`, `lib/features/home/presentation/widgets/banner_carousel.dart`, `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`
- Test: `test/widget/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `Member`, `BannerItem`, `AppColors.headerPeach`, `AppSpacing.headerRadius`.
- Produces: `MemberHeader(member:, onBellTap:, notificationCount = 2)`; keys `memberHeader_bellButton` (kept) and `memberHeader_pointsChip`. ARB `memberPointsLeft` = `"{points} points left to become {tier} Member"` with `tier` = next tier name; derive next tier from current: Bronze→Gold per reference (use `Gold` when tier is `Bronze`, `Platinum` when `Silver`, `Platinum` otherwise) via a small private function in the header.

- [ ] **Step 1: Failing tests:** header shows member name, tier text, the chip text for a Bronze member with `points: 710, nextTierPoints: 2000` → `'1290 points left to become Gold Member'`, a bell with badge text `'2'`; carousel still exposes `Key('bannerCarousel')` and does not start its autoplay timer under Reduce Motion (existing behavior; keep passing).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Rebuild `MemberHeader`:** container `AppColors.headerPeach`, bottom radius `headerRadius`; row with avatar (`AppSmartImage` in `ClipOval`) wrapped in an orange arc ring (`CustomPaint` arc using `AppColors.badge`, ~270°), name `AppTextStyles.h1`, tier caption; hexagon badge top-right as a faded peach hexagon (`ClipPath` with a six-point polygon) containing `Icons.star` in `AppColors.textSecondary`; bell as an orange pill (`AppColors.badge`) at the right edge with `Icons.notifications_none` and a white circle with the count; white chip below with the points text. Replace `CachedNetworkImage` with `AppSmartImage` so local asset avatars work.
- [ ] **Step 4: Restyle `BannerCarousel`:** card radius `AppSpacing.cardRadius`, pages overlap the header bottom with `Transform.translate(offset: Offset(0, -AppSpacing.lg))` handled by the Home composition in Task 5 (leave the carousel itself at 160px height; keep page controller, autoplay, empty state, keys). Add a small pill label overlay is NOT needed (art contains it).
- [ ] **Step 5: Run** tests → PASS; analyze.
- [ ] **Step 6: Commit** explicit paths.

---

### Task 5: Shops block and Home composition

**Files:**
- Modify: `lib/features/home/presentation/widgets/nearby_shops_row.dart`, `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/shell/presentation/screens/app_shell_screen.dart`, `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`
- Test: `test/widget/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `shops_backdrop.png`, `shop_1.png`, `shop_2.png` (Task 2), `AppColors.pageGrey`, `AppSpacing.navBarHeight`.
- Produces: ARB `exploreNow` = `"Explore now"` (Burmese equivalent), `orderOnline` = `"Order Online"`; `NearbyShopsRow` keeps keys `nearbyShopsRow` and `shopCard_<id>`. `AppShellScreen` sets `extendBody: true`.

- [ ] **Step 1: Failing tests:** at the end of the Home scroll (`tester.drag` until `nearbyShopsRow` visible), the last shop card's bottom edge is above the nav top (`getBottomLeft(find.byKey(Key('shopCard_...'))).dy <= nav top`), pump a Home inside `AppShellScreen` to get the nav; Home scaffold background is `AppColors.pageGrey`; `'EXPLORE NOW'` button text and `'Order Online'` are present.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Restyle `NearbyShopsRow`:** a `Stack` with `shops_backdrop.png` (`BoxFit.cover`) behind a sky-cyan block (`AppColors.primary`-family gradient is fine if the art lacks sky), title `nearbyShopsTitle` in white bold, `EXPLORE NOW` white pill with cyan text (tap → existing `AppSnackbar` "not implemented"), a horizontal list of white shop cards (photo, name, address, pink `Order Online` using `AppColors.accent`), card width ~ 260, radius `cardRadius`. Keep empty state.
- [ ] **Step 4: Compose in `HomeScreen`:** scaffold `AppColors.pageGrey`; remove the `SafeArea` top inset for the header (header paints under the status bar; pad content with `MediaQuery.paddingOf(context).top` inside the header); banner carousel translated up into the header; replace `SizedBox`es with `AppSpacing.sectionGap`; final bottom padding `AppSpacing.navBarHeight + AppSpacing.lg + MediaQuery.paddingOf(context).bottom`. Keep the `_SectionEntrance` stagger and the offline banner. Set `extendBody: true` on the shell `Scaffold`.
- [ ] **Step 5: Run** home + shell tests → PASS; analyze.
- [ ] **Step 6: Commit** explicit paths.

---

### Task 6: Floating bottom nav

**Files:**
- Modify: `lib/core/widgets/app_bottom_nav.dart`, `lib/features/shell/presentation/screens/app_shell_screen.dart`
- Test: `test/widget/core/app_bottom_nav_test.dart`

**Interfaces:**
- Produces: `kDefaultBottomNavItems` icons = `Icons.home_outlined`, `Icons.workspace_premium_outlined` (crown-style), `Icons.local_offer_outlined` stays for Rewards slot ONLY if no better pokeball-style standard icon exists — use `Icons.radio_button_checked` for the center Rewards slot to match the reference, `Icons.account_balance_wallet_outlined`, `Icons.settings_outlined`. Keep slot order and `AppShellScreen.homeIndex/rewardsIndex`. Active pill `AppColors.accent`; bar `AppColors.primary` with a white 1px top border and a shadow; bar floats with side margin `AppSpacing.md` over content.

- [ ] **Step 1: Update tests** in `app_bottom_nav_test.dart`: tap center icon (`Icons.radio_button_checked`) → `onTap(2)`; first slot icon is `Icons.home_outlined`; slot 1 is `Icons.workspace_premium_outlined`; remaining existing tests (pill slides, only active label shown, Reduce Motion) keep passing unchanged. Update `home_screen_test`/shell tests that tap `Icons.local_offer_outlined` accordingly (`grep -rn local_offer_outlined test lib`).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** the icon change in both `kDefaultBottomNavItems` and `AppShellScreen`'s `items`; add the shadow/border; keep the pill logic.
- [ ] **Step 4: Run** all tests → PASS; analyze.
- [ ] **Step 5: Commit** explicit paths.

---

### Task 7: Product detail

**Files:**
- Modify: `lib/features/product/presentation/screens/product_detail_screen.dart`, `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`
- Test: `test/widget/product/product_detail_screen_test.dart`

**Interfaces:**
- Consumes: tokens from Task 1, `AppButton`, `AppSmartImage`, bloc events `QuantityIncremented`, `QuantityDecremented`, `AddToCartPressed`; `ProductLoaded.quantity/totalMmk/addedToCart`.
- Produces: keys kept: `productDetailScreen`, `quantityIncrement`, `quantityDecrement`, `addToCartButton`; new keys `productCard`, `quantityPill`, `descriptionToggle`. ARB `addToCartLabel` = `"Add to cart"`; button renders `ADD TO CART` and the total as separate texts with a divider (`find.text('ADD TO CART')`, `find.text('3,200 MMK')`). The `addToCartButton` ARB format key may stay for compatibility but is no longer used by this screen.

- [ ] **Step 1: Rewrite the test** (`product_detail_screen_test.dart`): after load, `find.text('ADD TO CART')` and `find.text('1,500 MMK')` (button total); tapping `quantityIncrement` → total `3,000 MMK`; quantity text changes from `1` to `2`; tapping `descriptionToggle` expands the description (finder for full text length / `AnimatedSize` height grows); the quantity pill's center lies on the card's bottom edge (`tester.getRect(find.byKey(Key('quantityPill'))).center.dy` ≈ `getRect(find.byKey(Key('productCard'))).bottom` ±2) and tapping the pill's lower half still increments (hit-test outside card bounds); Reduce Motion: wrapping in `MediaQuery(disableAnimations: true)` renders final state on the first frame.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Rebuild the screen:** `Scaffold(backgroundColor: AppColors.pageGrey, appBar: transparent AppBar with plain `Icons.arrow_back` leading (keep go_router pop), body scroll view`. White rounded card (`key: productCard`, radius `cardRadius`): code (`AppTextStyles.caption`, grey), name (`h1`), price (`h2`, bold), top-right `New` pill (`AppColors.badge`) when `isNew`; large image tagged with the Hero (keep the loading-branch Hero at the same tree position as today); `Stack` with `clipBehavior: Clip.none` so `quantityPill` (white pill, radius `qtyPillHeight/2`, cyan circular −/+ `AppColors.primary` buttons, count in `AnimatedSwitcher` with `kQtyChange`) is positioned half below the card. Description row: green `Icons.help` (`AppColors.success`) + `whatsThis` at left, a 1px vertical divider, description at right in an `AnimatedSize(kDescriptionExpand)` clipped to 4 lines with a bottom fade (`ShaderMask`/gradient overlay) until expanded; `descriptionToggle` wraps the row. Bottom: `AppButton`-style pill built from `AppButton` with a custom child if `AppButton` supports one; otherwise extend `AppButton` with an optional `trailingLabel` (label | divider | total) — one shared change, tested in `app_button_test.dart`. Total text uses `AnimatedSwitcher`. Entry: whole card fades and rises with `kDetailEntrance` unless Reduce Motion. Keep `AppSnackbar.showSuccess` on add-to-cart.
- [ ] **Step 4: Run** product tests + `app_button_test.dart` → PASS; analyze.
- [ ] **Step 5: Commit** explicit paths.

---

### Task 8: Welcome screen

**Files:**
- Modify: `lib/features/auth/presentation/screens/welcome_screen.dart`
- Test: new `test/widget/auth/welcome_screen_test.dart` (check `test/widget/auth/` first; extend an existing welcome test if one exists)

**Interfaces:**
- Consumes: `DonutTile` (`asset`, `circleColor`, `size`, `animation`, `slideFrom`), `AuthScaffold(showBack: false, showFooter: false, titleGap: false)`, `AppColors.tile*`, assets `tile_1..3.png` and `donut_*.png`; existing keys `letsExploreButton`; title `welcomeTitle`, button `letsExploreButton`.
- Produces: tiles are rounded rectangles in two staggered columns (right column offset down ~ 90px), partially cropped at the screen edges, with a bottom fade to the page gradient; the old `Icons.circle` placeholders are removed.

- [ ] **Step 1: Failing test:** pump `WelcomeScreen` inside `MaterialApp` + localization + `GoRouter`-free host (copy the host pattern from `test/widget/auth/test_helpers.dart`); assert: `welcomeTitle` text, `letsExploreButton` present, four tile `Image` widgets, no overflow at sizes 375x667 and 430x932 (`tester.view.physicalSize`), and under Reduce Motion the tiles are at final opacity on the first frame.
- [ ] **Step 2: Run** → FAIL (no tile images; old circles).
- [ ] **Step 3: Implement:** replace the icon row with a `SizedBox`-bounded two-column stack of tiles (generalize `DonutTile` to take a `borderRadius` or add a sibling shape param rather than duplicating it: add `final BoxShape shape` default `circle` and `final double? radius`; update its callers/tests). Fade overlay: `IgnorePointer` + `DecoratedBox` with a `LinearGradient` from transparent to `AppColors.gradientColors.first`. Keep the stagger controller and the `LayoutBuilder`-safe layout (no `Spacer`/`Expanded` in the child).
- [ ] **Step 4: Run** auth tests → PASS; analyze.
- [ ] **Step 5: Commit** explicit paths.

---

### Task 9: Docs and simulator verification

**Files:**
- Modify: `README.md` (Home / Product / Nav / Welcome notes, new assets and the seed bump), the spec's "Out of scope" line if anything shifted.

- [ ] **Step 1:** Run `flutter test --no-pub` (all green) and `flutter analyze` (11 infos).
- [ ] **Step 2:** Run the app on the iPhone 16 Plus simulator (`mcp__Claude_Code_iOS_Simulator__control` attach → build/launch via `flutter run -d <udid>`); walk Welcome, Home (top, mid, end of scroll), Product detail (open from Seasonal and Popular, change quantity, expand description, back), nav (all five tabs). Compare with `images/8.png`–`12.png` in the scratchpad's session `images/` folder; list any visible deviations in the report instead of silently accepting them.
- [ ] **Step 3:** Update README; commit `README.md` plus any docs by explicit path.

---

## Self-review

- **Spec coverage:** foundation (T1), assets (T2), Home sections/card (T3), header + banners (T4), shops + composition + padding (T5), nav (T6), Product detail + motion (T7), Welcome (T8), tests/docs/simulator (T9). The spec's `Section header`, tokens, ARB strings, and Reduce Motion gating each have an owning task.
- **Type consistency:** `ProductCard`, `ProductCardImageMode`, `SectionHeader`, `heightFor`/`widthFor`, token names, ARB keys (`discountOff`, `memberPointsLeft`, `exploreNow`, `orderOnline`, `addToCartLabel`) are named identically wherever used.
- **Known judgment calls:** the Rewards center icon `Icons.radio_button_checked` approximates the reference's pokeball glyph with a standard icon (user rule: standard Material/Cupertino icons only); the seed change only reaches installs that reseed (T2 Step 3 decides how).
