# J'Donuts UI Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the app look and move like the reference (pink gradient auth screens, transparent AppBar with progress ring, pill controls, fixed `+95` prefix, splash, onboarding tile motion) and implement the full PDF motion table, without changing business logic.

**Architecture:** One `AppTheme` built from color/spacing/motion tokens replaces the missing `ThemeData`. A shared `AuthScaffold` (gradient + back button + progress ring + footer) is used by every auth screen. Motion lives in `core/theme/motion_tokens.dart`; page transitions in `core/router`. All new files are `part of` their existing barrel.

**Tech Stack:** Flutter 3.47 / Dart 3.13, flutter_bloc, go_router 14, existing packages only (no new dependencies).

**Spec:** `docs/superpowers/specs/2026-11-08-ui-overhaul-design.md` (extends `2026-11-08-j-donuts-app-design.md`).

## Global Constraints

- Branch `feature/ui-overhaul`; commit per task; commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Every new file under `lib/core/` is `part of '../core_import.dart'` (path adjusted to depth); under a feature, `part of` that feature's `_import.dart`. New parts are registered in the barrel. No own `import` lines in part files; new package/asset imports go in the barrel.
- No hard-coded colors, font sizes, spacing, or durations in widgets; add tokens instead. Existing literals you do not touch stay.
- Palette (exact): `primary 0xFF34C4E8`, `primaryDisabled 0xFFBCB2B6`, `accent 0xFFE6197F`, `ringCyan 0xFF64CDE9`, `ringPink 0xFFF259A1`; gradient stops 0.00 `0xFFFDD6E5`, 0.30 `0xFFFEE1EB`, 0.50 `0xFFFFEAF1`, 0.70 `0xFFFEF2F6`, 1.00 `0xFFFEFEFE`.
- Every animation checks `MediaQuery.of(context).disableAnimations` (skip to end state / no transition).
- No new dependencies. `flutter analyze` must stay at the existing 11 info lints, no new issues. `flutter test --no-pub` must stay green (69 today) after every task.
- Copy already matches the reference; only add ARB keys named in a task, in both `app_en.arb` and `app_my.arb`, then run `flutter gen-l10n`.
- Do not commit `ios/Podfile*`, `ios/Flutter/*.xcconfig`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner.xcworkspace/*`, swiftpm dirs (CocoaPods artifacts, out of scope).
- The faint ghosting seen on Onboarding in this host's iOS simulators is a known Impeller simulator artifact, not a defect to fix.
- Existing widget `Key`s used by tests/integration test (`getStartedButton`, `continueButton`, `phoneNumberField`, `otpInput`, `firstNameField`, `lastNameField`, `dobMonthField`, `dobDayField`, `dobYearField`, `letsExploreButton`, `productTile_<id>`, `loginLinkButton`, etc.) must be preserved.

## Review Focus

- Phone field with fixed prefix: user types `09254135592`, `9254135592`, or pastes `+959254135592`; bloc must receive a number that normalizes to `+959254135592`, never `+95+95…` or a doubled prefix (Task 4).
- Small phone (4.7in, 375×667) with keyboard open on Phone/Name/DOB: no RenderFlex overflow; footer hides; Continue stays reachable (Task 1, 5).
- Reduce Motion on: splash must still navigate to its destination (not hang) with no animation (Task 6).
- Launch with an existing session: splash → `/home`, never flashes Onboarding (Task 6).
- Text scale 1.3 on the new auth screens and Onboarding: no overflow (Task 5, 7).
- Same product in two Home sections: no duplicate Hero tag crash (Task 8).

---

### Task 0: Tokens, AppTheme, primary→accent migration

**Files:**
- Modify: `lib/core/theme/colors.dart`, `spacing.dart`, `motion_tokens.dart`, `lib/core/core_import.dart`, `lib/main.dart`
- Create: `lib/core/theme/app_theme.dart`
- Modify (color migration, grep `AppColors.primary`): `core/widgets/app_text_field.dart:45`, `core/widgets/app_legal_footer.dart:18`, `core/widgets/app_bottom_nav.dart:32`, `features/home/presentation/widgets/product_section_list.dart:87`, `features/auth/presentation/screens/onboarding_screen.dart:50`, `features/auth/presentation/screens/otp_screen.dart:123`, `features/rewards/presentation/widgets/tab_switcher.dart:33`, `features/rewards/presentation/widgets/challenge_card.dart:132`, `features/rewards/presentation/screens/rewards_screen.dart:110`, `features/product/presentation/screens/product_detail_screen.dart:86` — all become `AppColors.accent`. `AppButton` keeps `AppColors.primary` (cyan). `onboarding_screen.dart:31` (pink dot) is replaced in Task 7; switch it to `accent` for now.
- Test: `test/unit/core/app_theme_test.dart`

**Interfaces:**
- Produces `AppColors`: `primary`, `primaryDisabled`, `accent`, `ringCyan`, `ringPink`, `gradientColors` (`List<Color>`, 5 entries) and `gradientStops` (`List<double>` `[0,0.3,0.5,0.7,1]`) in addition to existing `background`, `surface`, `error`, `success`, `textPrimary`, `textSecondary`, `border`.
- Produces `AppSpacing`: `buttonHeight = 56`, `buttonRadius = 28`, `fieldRadius = 12`, `backButtonSize = 44`, `authHorizontalPadding = 24`, `ringSize = 40`.
- Produces `MotionTokens`: `kSplashLogoDuration` 900ms, `kSplashHoldDuration` 700ms, `kSplashExitDuration` 500ms, `kTileDriftDuration` 900ms, `kStepTransitionDuration` 350ms, `kRingStepDuration` 400ms, `kButtonMorphDuration` 250ms, `kHomeSectionStagger` 80ms, `kNavPillDuration` 250ms, `kHeroDuration` 350ms.
- Produces `AppTheme.light` (`ThemeData`), used as `MaterialApp.router(theme: AppTheme.light)`.

- [ ] **Step 1: Write failing test** `app_theme_test.dart`: `AppTheme.light.elevatedButtonTheme.style!.shape` resolves to a `RoundedRectangleBorder` with radius `AppSpacing.buttonRadius`; `AppTheme.light.appBarTheme.backgroundColor == Colors.transparent`; `AppTheme.light.inputDecorationTheme.filled == true`; `AppColors.gradientColors.length == AppColors.gradientStops.length`; `AppColors.primary == const Color(0xFF34C4E8)`.
- [ ] **Step 2: Run** `flutter test test/unit/core/app_theme_test.dart` → FAIL (`AppTheme` undefined).
- [ ] **Step 3: Add the tokens** listed in Interfaces; keep existing token names.
- [ ] **Step 4: Implement `AppTheme`** (`ThemeData` from `ColorScheme.light(primary: AppColors.primary, secondary: AppColors.accent, surface: AppColors.surface, error: AppColors.error)` — do NOT use `fromSeed`): `useMaterial3: true`, `scaffoldBackgroundColor: AppColors.background`, `appBarTheme` transparent/elevation 0/`scrolledUnderElevation: 0`/no tint, `inputDecorationTheme` filled white, `fieldRadius`, 1px `AppColors.border` enabled border, `accent` focused border, `textSelectionTheme.cursorColor: AppColors.accent`, `elevatedButtonTheme` pill (`buttonRadius`, `Size.fromHeight(AppSpacing.buttonHeight)`, `primary` / `primaryDisabled` via `WidgetStateProperty`, `AppTextStyles.button`). Register `part 'theme/app_theme.dart'`; set `theme:` in `MyApp`.
- [ ] **Step 5: Migrate** the listed `AppColors.primary` pink usages to `AppColors.accent`.
- [ ] **Step 6: Run** `flutter test --no-pub` → all pass (update any test asserting old colors); `flutter analyze` → 11 infos.
- [ ] **Step 7: Commit** `feat: reference palette tokens, AppTheme, accent migration`.

---

### Task 1: AppGradientBackground, AppBackButton, AuthScaffold

**Files:**
- Create: `lib/core/widgets/app_gradient_background.dart`, `app_back_button.dart`, `auth_scaffold.dart`
- Modify: `lib/core/core_import.dart` (register three parts; `go_router` import for `context.canPop()/pop()` — add `import 'package:go_router/go_router.dart';` if absent)
- Test: `test/widget/core/auth_scaffold_test.dart`

**Interfaces:**
- Consumes: Task 0 tokens.
- Produces:
  - `AppGradientBackground({super.key, required Widget child})` — `DecoratedBox` with vertical `LinearGradient(colors: AppColors.gradientColors, stops: AppColors.gradientStops)`.
  - `AppBackButton({super.key, VoidCallback? onPressed})` — `backButtonSize` white square, radius 12, `Icons.arrow_back`; default pops only when `context.canPop()`.
  - `AuthScaffold({super.key, required Widget child, bool showBack = true, Widget? trailing, VoidCallback? onTapTerms, VoidCallback? onTapPrivacy, bool showFooter = true})` — `Scaffold(backgroundColor: Colors.transparent)` inside `AppGradientBackground`; `SafeArea`; header row (back left, `trailing` right); body in `SingleChildScrollView` with `authHorizontalPadding`; `AppLegalFooter` pinned at the bottom and **hidden when `MediaQuery.viewInsets.bottom > 0`**. Back/trailing slots keep the header height constant (`backButtonSize`) even when both absent.

- [ ] **Step 1: Write failing tests**: (a) `AuthScaffold` shows `AppLegalFooter` with no inset and `findsNothing` when pumped inside `MediaQuery(data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)))`; (b) tapping `AppBackButton` inside a `GoRouter` with two routes pops to the first; (c) at size 375×667 with a 300px inset and a 4-field `child`, `tester.takeException()` is null (no overflow).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** the three widgets per Interfaces.
- [ ] **Step 4: Run** tests → PASS; full suite green.
- [ ] **Step 5: Commit** `feat: gradient background, back button, AuthScaffold`.

---

### Task 2: AppButton (pill, press-scale, loading morph) and AppTextField (prefix, focus)

**Files:**
- Modify: `lib/core/widgets/app_button.dart`, `app_text_field.dart`
- Test: `test/widget/core/app_button_test.dart`, `test/widget/core/app_text_field_test.dart`

**Interfaces:**
- Produces `AppButton` — same constructor (`label`, `onPressed`, `loading`, `key`); visuals from the theme; press-scale 0.97 via `AnimatedScale(duration: MotionTokens.kPressScaleDuration)` driven by a `Listener` (pointer down/up/cancel) — **not** a `GestureDetector`; while `loading` the label is replaced by a spinner through `AnimatedSwitcher(duration: MotionTokens.kButtonMorphDuration)` and the button keeps full width; `onPressed == null` renders `primaryDisabled`; label remains `toUpperCase()`.
- Produces `AppTextField` — adds `final Widget? prefix;`; uses `InputDecoration(prefix: prefix)` (no floating label when `labelText` is null); decoration comes from the theme (remove hard-coded borders); `errorText` shows in `AppColors.error`.

- [ ] **Step 1: Write failing tests**: (a) `AppButton` with `onPressed: null` has background `AppColors.primaryDisabled`; (b) `tester.startGesture` down on the button → `AnimatedScale.scale == 0.97`, release → `1.0` (proves the Listener path works even though the inner `ElevatedButton` wins the tap arena); (c) `loading: true` → `find.byType(CircularProgressIndicator)` present and label text absent, button width equals parent width; (d) `AppTextField(prefix: Text('+95'))` renders `+95`, and typing `9254135592` leaves `controller.text == '9254135592'` (prefix is not in the text).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** per Interfaces. Reduce Motion: scale/morph durations become `Duration.zero` when `MediaQuery.disableAnimations`.
- [ ] **Step 4: Run** → PASS; full suite green (fix tests that depended on old button/field internals).
- [ ] **Step 5: Commit** `feat: pill AppButton with press/loading motion, AppTextField prefix`.

---

### Task 3: RegistrationProgressRing (reference ring, step animation, check morph)

**Files:**
- Modify: `lib/features/auth/presentation/widgets/registration_progress_ring.dart`
- Test: `test/widget/auth/registration_progress_ring_test.dart`

**Interfaces:**
- Consumes `AppSpacing.ringSize`, `AppColors.ringCyan`, `AppColors.ringPink`, `MotionTokens.kRingStepDuration`, `RegistrationStep` (`phone, otp, name, dob`).
- Produces `RegistrationProgressRing({super.key, required RegistrationStep step, bool completed = false})` — same signature as today. Draws a donut: full `ringCyan` circle (stroke = `ringSize * 0.3`), `ringPink` arc from 12 o'clock sweeping `progress` of the circle (phone 0.25, otp 0.5, name 0.75, dob 1.0), center hole transparent. On first build it animates from the **previous step's** progress (phone starts from 0) to the current one over `kRingStepDuration` using `TweenAnimationBuilder<double>`. When `completed` is true the ring cross-fades/scales (`AnimatedSwitcher`, `kRingStepDuration`) into a filled `ringPink` circle with a white `Icons.check`. Exposes `static double progressFor(RegistrationStep step)` for tests. Painter is private to this file.

- [ ] **Step 1: Write failing tests**: `RegistrationProgressRing.progressFor` returns 0.25/0.5/0.75/1.0; pumping `step: otp` then `pumpAndSettle` leaves a `CustomPaint` with no `Icons.check`; pumping `step: dob, completed: true` shows `Icons.check`; with `disableAnimations: true` the first frame already shows the final state (no intermediate pump needed).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement** per Interfaces.
- [ ] **Step 4: Run** → PASS; full suite green.
- [ ] **Step 5: Commit** `feat: reference progress ring with step animation and check morph`.

---

### Task 4: PhoneScreen on AuthScaffold — fixed `+95` prefix and Login variant

**Files:**
- Modify: `lib/features/auth/presentation/screens/phone_screen.dart`, `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`, generated `lib/l10n/*`
- Test: `test/widget/auth/phone_screen_test.dart` (create), update `test/widget/auth/login_screen_test.dart`, `register_flow_test.dart`

**Interfaces:**
- Consumes `AuthScaffold`, `AppTextField(prefix:)`, `RegistrationProgressRing`, existing `PhoneSubmitted(String raw, {bool isLogin})`.
- New ARB keys: `loginScreenTitle` = `"Welcome back, Login to your profile"`, `loginButton` = `"Login"`; Burmese: `"ပြန်လည်ကြိုဆိုပါတယ်၊ သင့်ပရိုဖိုင်သို့ ဝင်ရောက်ပါ"`, `"ဝင်ရောက်မည်"`.
- `PhoneScreen`: wraps content in `AuthScaffold(trailing: isLogin ? null : RegistrationProgressRing(step: RegistrationStep.phone), onTapTerms/onTapPrivacy: no-op placeholders)`. The field is `AppTextField(key: Key('phoneNumberField'), prefix: Text(l10n.phoneCountryCode), keyboardType: phone, hintText: l10n.phoneHint)` with no `labelText`. The raw string sent in `PhoneSubmitted` and fed to `validatePhone` is the typed text with any leading `+95` removed (private helper `String _national(String typed)`), so pasting `+959254135592` into the prefixed field yields `9254135592` and never a doubled prefix; `validatePhone`/`normalizePhone` are unchanged and already handle a leading `0`. Title: `l10n.phoneScreenTitle` (register) or `l10n.loginScreenTitle` (login) in `AppTextStyles.h1`. Button label: `l10n.continueButton` / `l10n.loginButton`. In login mode a bordered circular `IconButton(Icons.fingerprint, key: Key('fingerprintButton'))` sits under the button and shows `AppSnackbar.showError(context, l10n.socialSignInUnavailableMessage('Fingerprint'))`.

- [ ] **Step 1: Write failing tests**: (a) `+95` text is displayed and is not part of `controller.text`; (b) enter `09254135592` → Continue enabled and tapping sends `PhoneSubmitted` whose normalized value is `+959254135592` (use a bloc test double capturing the event, then `normalizePhone`); (c) enter `+959254135592` → same normalized result, never containing `+95+95`; (d) `PhoneScreen(isLogin: true)` shows `Welcome back, Login to your profile`, a `LOGIN` button, `fingerprintButton`, and no `RegistrationProgressRing`; (e) register mode shows the ring.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Add ARB keys (en+my), run `flutter gen-l10n`, implement the screen.**
- [ ] **Step 4: Run** → PASS; update `login_screen_test`/`register_flow_test` for the removed `AppBar`/label; full suite green.
- [ ] **Step 5: Commit** `feat: phone screen on AuthScaffold with fixed +95 prefix and login variant`.

---

### Task 5: OTP, Name, DOB, Welcome on AuthScaffold

**Files:**
- Modify: `otp_screen.dart`, `name_screen.dart`, `dob_screen.dart`, `welcome_screen.dart` (all under `lib/features/auth/presentation/screens/`)
- Test: update `test/widget/auth/register_flow_test.dart`, `test/widget/accessibility/text_scale_test.dart`; create `test/widget/auth/auth_chrome_test.dart`

**Interfaces:**
- Consumes `AuthScaffold`, `RegistrationProgressRing`.
- Each screen drops its own `Scaffold`/`AppBar`/`AppLegalFooter` and returns `AuthScaffold`. Ring: OTP `step: otp`; Name `step: name`; DOB `step: dob, completed: <field state valid>` (the same boolean that enables Continue). Welcome: `AuthScaffold(showBack: false, showFooter: false, ...)` keeping its existing tile/title animation and `letsExploreButton` key. Titles use `AppTextStyles.h1`. All existing keys and bloc wiring stay. OTP/DOB inputs keep behavior; their boxes pick up the theme's white rounded style.

- [ ] **Step 1: Write failing tests** (`auth_chrome_test.dart`): for each of OTP/Name/DOB, pump inside `BlocProvider` + localizations and assert exactly one `AuthScaffold`, one `RegistrationProgressRing` with the expected `step`, no `AppBar`; DOB with valid fields shows `Icons.check`; Welcome has no back button and no footer. Extend `text_scale_test` to pump Phone, OTP, Name, DOB at `TextScaler.linear(1.3)` on 375×667 with `viewInsets.bottom = 300` and assert `takeException() == null`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Migrate the four screens.**
- [ ] **Step 4: Run** → PASS; full suite incl. integration test green (`flutter test --no-pub`).
- [ ] **Step 5: Commit** `feat: OTP, name, DOB, welcome on AuthScaffold with progress ring`.

---

### Task 6: Splash route and shared-axis step transitions

**Files:**
- Create: `lib/features/shell/presentation/screens/splash_screen.dart`, `lib/core/router/app_page_transitions.dart`
- Modify: `lib/features/shell/shell_import.dart`, `lib/core/router/app_router.dart`, `lib/core/core_import.dart` only if the transitions file is a core part (it is a plain library file imported by `app_router.dart`; no barrel change needed)
- Assets: `assets/images/seed/brand_logo.png` (download, see below)
- Test: `test/widget/shell/splash_screen_test.dart`, `test/unit/core/router_test.dart`

**Interfaces:**
- `SplashScreen({super.key})`: white `Scaffold`; centered logo circle (`brand_logo.png`, 120px source) scaling 0.6→1.0 and fading in over `kSplashLogoDuration` with `Curves`/`kEmphasizedCurve`; after `kSplashHoldDuration` fades out over `kSplashExitDuration` then calls `context.go('/')` once (guard against double-calls and unmounted context). With `disableAnimations`: no animation, shows the logo, and still navigates after `Duration.zero` hold.
- Router: `initialLocation: '/splash'`; add `GoRoute(path: '/splash', builder: (_, __) => const SplashScreen())` outside the ShellRoute; the top-level `redirect` returns `null` for `/splash` (and still maps `/` → `/home` with session else `/onboarding`; remove the route-level `/` redirect only if it duplicates the top-level one — keep behavior identical).
- `AppPageTransitions.sharedAxisX<T>(GoRouterState state, Widget child) -> CustomTransitionPage<T>`: fade + 30px horizontal slide-in (`SlideTransition` + `FadeTransition`), `transitionDuration: MotionTokens.kStepTransitionDuration`; when `MediaQuery.disableAnimations` the `transitionsBuilder` returns `child` unchanged. Applied via `pageBuilder` to `/phone`, `/otp`, `/name`, `/dob`, `/welcome` (not `/onboarding`).
- Logo download: from the repo root, `python3 -I` with `urllib`, URL `https://jdonuts.com/_next/image?url=` + `urllib.parse.quote('/home-assets/home-01-j-donuts-new-logo-1.png', safe='')` + `&w=1080&q=90` (the site's Next.js image proxy; direct `/api/uploads/...` or raw paths return 404). Save to `assets/images/seed/brand_logo.png`; verify with `file` it is a valid PNG.

- [ ] **Step 1: Write failing tests**: (a) router test with a fake `GetSessionUseCase` returning no session: pump `MaterialApp.router`, advance past hold+exit (`pump(Duration(seconds: 3))`), expect `OnboardingScreen`-landmark `getStartedButton`; (b) with a session: expect the shell (`homeScreen` key) and `find.byKey(Key('getStartedButton'))` never appeared (record with a frame-by-frame `pump` loop); (c) `SplashScreen` under `MediaQuery(disableAnimations: true)` navigates after a single `pump()`/`pumpAndSettle` without hanging; (d) `sharedAxisX` page's transition returns the bare child under `disableAnimations`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Download logo, implement splash, transitions, router changes.** Existing tests that start the app (`widget_test.dart`, `register_to_product_test.dart`) must advance past the splash (extra `pump(Duration(seconds: 3))` before `pumpAndSettle`).
- [ ] **Step 4: Run** full suite incl. integration test → green.
- [ ] **Step 5: Commit** `feat: splash route and shared-axis step transitions`.

---

### Task 7: Onboarding rebuild with donut tiles and motion

**Files:**
- Modify: `lib/features/auth/presentation/screens/onboarding_screen.dart`
- Create: `lib/features/auth/presentation/widgets/donut_tile.dart`
- Assets: `assets/images/seed/tile_1.png`, `tile_2.png`, `tile_3.png` (real donut photos), reuse existing `donut_chocolate.png`/`donut_strawberry.png`
- Test: `test/widget/auth/onboarding_screen_test.dart`

**Interfaces:**
- `DonutTile({super.key, required String asset, required Color circleColor, required double size, required Animation<double> animation, required Offset slideFrom})` — circle filled with `circleColor` containing `Image.asset(asset)`; slides from `slideFrom` (fraction of its size) to rest and fades with `animation`. Circle colors are new tokens `AppColors.tileCyan`, `tileBeige`, `tileBlue`, `tilePurple` (values sampled from the reference: cyan ≈ `0xFF35C4E8`, beige ≈ `0xFFF9DCCB`, light blue ≈ `0xFFBFD8F2`, purple tint ≈ `0xFFCBB8EE`).
- Onboarding layout: `Stack` — top ~55%: 4 `DonutTile`s (staggered `Interval`s of one `AnimationController(duration: kTileDriftDuration + 3*kStaggerStep)`), bottom-up gradient overlay fading in (opacity animation), then column with logo circle (`brand_logo.png` in a white circle replacing the pink dot), title `l10n.onboardingTitle`, `AppButton(key: Key('getStartedButton'))`, login line (existing `loginLinkButton`), social row (existing keys), `AppLegalFooter`. Title and button enter with fade + 16px rise, staggered by `kStaggerStep`. Background is `AppGradientBackground`. `disableAnimations` → controller starts at 1.0.
- Tile photos: download 3 Donuts-category images via the same Next.js proxy method as Task 6 using upload paths from `https://jdonuts.com/api/products?country=mm` (filter `category_name == 'Donuts'`, pick e.g. `Honey Dipped`, `Mirror Glazing Pink`, `Cake Chocolate coconut`; use the exact `image` field, quote it, `w=1080`); save as `tile_1..3.png`; verify valid PNGs. Never commit design screenshots.

- [ ] **Step 1: Write failing tests**: (a) pumping the screen shows 4 `DonutTile` widgets, `getStartedButton`, `loginLinkButton`, the three social keys, `AppLegalFooter`; (b) at t=0 tiles are at their `slideFrom` offset/opacity 0, after `pumpAndSettle` at rest/opacity 1; (c) `disableAnimations: true` → final state on first frame; (d) `TextScaler.linear(1.3)` on 375×667 → `takeException() == null`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Download assets, add tile color tokens, implement.**
- [ ] **Step 4: Run** full suite green.
- [ ] **Step 5: Commit** `feat: onboarding donut tiles, logo, staggered entrance`.

---

### Task 8: Home section stagger and section-scoped Hero

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`, `widgets/product_section_list.dart`, `lib/features/product/presentation/screens/product_detail_screen.dart`, `lib/core/router/app_router.dart`
- Test: `test/widget/home/home_stagger_hero_test.dart`; update existing home/product tests if finders change

**Interfaces:**
- Home: each section in `_HomeContent` (banner, each `ProductSection`, shops) is wrapped in a fade+rise entrance with delay `index * MotionTokens.kHomeSectionStagger`, played once when `HomeLoaded` first renders (not on every rebuild/refresh); `disableAnimations` → none.
- Hero tag: `String heroTagFor(String sectionId, String productId) => 'product-$sectionId-$productId'` (top-level function in `product_import.dart` part so both features use it). `ProductSectionList` tiles wrap the image in `Hero(tag: heroTagFor(section.id, product.id), ...)` and navigate with `context.push('/product/${product.id}', extra: heroTagFor(...))`. Router `/product/:id` builder passes `heroTag: state.extra as String?` into `ProductDetailScreen({super.key, required String productId, String? heroTag})`; the detail image is wrapped in `Hero(tag: heroTag!)` only when `heroTag != null`; flight duration via `createRectTween`/default plus `MotionTokens.kHeroDuration` on the route's transition (set `transitionDuration` with a `CustomTransitionPage` if needed).

- [ ] **Step 1: Write failing tests**: (a) `heroTagFor('seasonal','p1') != heroTagFor('popular','p1')`; (b) pump `HomeScreen` with a bundle where product `p1` appears in two sections → `tester.takeException()` is null and exactly two `Hero` widgets with distinct tags exist; (c) tapping the tile in the second section opens the detail with `heroTag` equal to that section's tag (assert via the detail widget's `heroTag`); (d) section entrance: first frame sections have opacity 0, `pumpAndSettle` → 1; second `HomeRefreshRequested` rebuild does not replay (opacity stays 1); `/product/p1` opened with no `extra` renders without any Hero.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** full suite incl. integration test → green (integration taps `productTile_p_coconut`; Hero flight must not break `pumpAndSettle`).
- [ ] **Step 5: Commit** `feat: home section stagger and section-scoped Hero transition`.

---

### Task 9: Bottom nav sliding pill

**Files:**
- Modify: `lib/core/widgets/app_bottom_nav.dart`
- Test: `test/widget/core/app_bottom_nav_test.dart`; update shell tests if any

**Interfaces:**
- `AppBottomNav({super.key, required int currentIndex, required ValueChanged<int> onTap, List<BottomNavigationBarItem> items = kDefaultBottomNavItems})` — public API unchanged. Renders a rounded (`buttonRadius`) container in `AppColors.primary` (cyan) holding a `Row` of items (icon from `item.icon`, label from `item.label`); an `AnimatedPositioned`/`AnimatedAlign` pill in `AppColors.accent` slides behind the active item (`MotionTokens.kNavPillDuration`, `kEmphasizedCurve`) and the active item shows icon + label in white while others show icon only. Tap on item i calls `onTap(i)`. Length mismatch between `items` and caller tabs stays the caller's responsibility. `disableAnimations` → zero duration.

- [ ] **Step 1: Write failing tests**: tapping item 2 calls `onTap(2)`; the pill's left offset at `currentIndex: 0` differs from `currentIndex: 2` after `pumpAndSettle` and moves monotonically during the animation (sample mid-animation offset is strictly between the two); active item shows its label text, inactive items do not; `disableAnimations` → offset final on first frame.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** full suite green (shell/integration tests that tap nav items still work via icons).
- [ ] **Step 5: Commit** `feat: bottom nav with sliding pill`.

---

### Task 10: README, verification, polish pass

**Files:**
- Modify: `README.md`
- Test: full suite

- [ ] **Step 1:** Update README "Animations built" and "Known gaps": list the new motions (splash, tiles, step transitions, ring, button press/loading, Home stagger, Hero, nav pill); remove those items from "Not built"; keep honest gaps (hi-res logo needed — site/icon only 120px/64px; fingerprint is visual only; typeface not matched; Impeller simulator ghosting note).
- [ ] **Step 2:** `flutter analyze` → still 11 infos only; `flutter test --no-pub` → all green.
- [ ] **Step 3:** Build and run on a simulator (`flutter build ios --simulator --no-pub`, `xcrun simctl install/launch`), walk Splash → Onboarding → Phone (ring 25%) → OTP (50%) → Name (75%) → DOB (100%, check) → Welcome → Home → product Hero → Rewards, compare with the reference screenshots; record deviations in the README known-gaps list instead of fixing silently.
- [ ] **Step 4: Commit** `docs: README for UI overhaul`.
