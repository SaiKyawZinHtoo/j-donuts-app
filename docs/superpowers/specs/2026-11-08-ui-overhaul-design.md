# J'Donuts UI Overhaul — Design Spec

Date: 2026-11-08
Extends: `2026-11-08-j-donuts-app-design.md` (behavior unchanged; this spec changes look, motion, and adds a splash route).
Sources: user's reference screenshots, a screen recording of the official app, the code-test PDF's "Animations and transitions" table (page 12).

## 1. Intent

The shipped app works but does not look like the reference: white backgrounds, default Material controls, plain AppBar, a placeholder pink dot instead of the logo, no splash, and most of the PDF motion table missing. Goal: match the reference visually and implement the full PDF motion table, without changing business logic, routes' meaning, BLoCs, data layer, or tests' intent.

Success: side by side with the reference screens (Onboarding, Phone, OTP, Name, DOB, Welcome, Login variant) the layout, colors, control shapes, and motion read as the same app; all tests green; `flutter analyze` unchanged (11 pre-existing infos).

## 2. Decisions locked with user

- Gradient background everywhere on auth screens (not white); RGBA values sampled from reference.
- AppBar transparent, white rounded back button, progress ring top-right.
- `+95` is a fixed, non-editable prefix.
- App icon/logo replaces the pink dot.
- Fingerprint button on the Login variant is visual only (no biometric plugin).
- Icons stay in the Material/Cupertino set (earlier decision).
- Splash logo source: `assets/icon/app_icon.png` (64px) plus site logo (120px). Both low-res; swap-in file for a 512px+ logo is a known follow-up, not a blocker.

## 3. Design tokens (new/changed)

`core/theme/colors.dart` — replace the pink-primary scheme with the reference palette. Existing token names stay; values change; new tokens added so no widget holds literals.

| Token | Value | Use |
|---|---|---|
| `primary` | `0xFF34C4E8` | Pill buttons (cyan) |
| `primaryDisabled` | `0xFFBCB2B6` | Disabled pill button |
| `accent` | `0xFFE6197F` | Links, "Log In", footer links, active nav pill |
| `ringCyan` | `0xFF64CDE9` | Progress ring track segment |
| `ringPink` | `0xFFF259A1` | Progress ring progress segment |
| `gradientTop` … `gradientBottom` | see §4 | Background |
| `surface` | `0xFFFFFFFF` | Fields, back button |
| `textPrimary`/`textSecondary`/`error`/`success` | unchanged | |

Because `primary` changes from pink to cyan, every existing use of `AppColors.primary` that meant "pink accent" (links, Resend, nav active, challenge cards) must move to `accent`. The implementation plan lists them via grep.

`core/theme/spacing.dart` — add `buttonRadius = 28` (pill), `fieldRadius = 12`, `backButtonSize = 44`, `authHorizontalPadding = 24`, `ringSize = 40`. `buttonHeight` becomes 56 to match the pill.

`core/theme/motion_tokens.dart` — add: `kSplashLogoDuration` (900ms), `kSplashHoldDuration` (700ms), `kSplashExitDuration` (500ms), `kTileDriftDuration` (900ms), `kStepTransitionDuration` (350ms), `kRingStepDuration` (400ms), `kButtonMorphDuration` (250ms), `kHomeSectionStagger` (80ms), `kNavPillDuration` (250ms). Existing tokens unchanged.

## 4. Background gradient

`AppGradientBackground` (new, `core/widgets/app_gradient_background.dart`): a `DecoratedBox` with a vertical `LinearGradient`, stops sampled from the reference screenshots (RGB at fraction of screen height):

| Stop | Color |
|---|---|
| 0.00 | `0xFFFDD6E5` (253,214,229) |
| 0.30 | `0xFFFEE1EB` (254,225,235) |
| 0.50 | `0xFFFFEAF1` (255,234,241) |
| 0.70 | `0xFFFEF2F6` (254,242,246) |
| 1.00 | `0xFFFEFEFE` |

Stops are `static const` lists in `AppColors` (`gradientColors`, `gradientStops`). Used by `AuthScaffold`, Welcome and Onboarding; Home/Product/Rewards keep their current backgrounds (reference does not show them pink).

## 5. Theme

`core/theme/app_theme.dart` (new) builds one `ThemeData` from tokens and is passed in `MyApp`:
- `scaffoldBackgroundColor: transparent`-safe (screens that use the gradient set `backgroundColor: Colors.transparent` via `AuthScaffold`).
- `inputDecorationTheme`: filled white, `fieldRadius`, no visible border (soft 1px `border` token), focus border `accent`, cursor `accent`.
- `elevatedButtonTheme`: pill (`buttonRadius`), min height `buttonHeight`, `primary`/`primaryDisabled`, `AppTextStyles.button` uppercase.
- `appBarTheme`: transparent, zero elevation, no scrolled-under tint.
- `colorScheme.fromSeed` is NOT used (it injects the purple default); build `ColorScheme.light` with explicit tokens.

This removes the default purple cursor/underline seen on the Phone screen today.

## 6. Shared auth chrome

`AuthScaffold` (new, `core/widgets/auth_scaffold.dart`; widget has no auth imports, so it lives in core):

```
AuthScaffold({
  required Widget child,          // title + fields + button column
  bool showBack = true,           // white rounded-square back button
  Widget? trailing,               // progress ring or check, top-right
  VoidCallback? onTapTerms,
  VoidCallback? onTapPrivacy,
  bool showFooter = true,         // AppLegalFooter pinned bottom
  VoidCallback? onBack,           // overrides back-button action (added in T5)
  Widget? bottom,                 // primary action pinned above footer, rises with keyboard (T10a)
  bool titleGap = true,           // gap between header row and body (T10a; Welcome opts out)
})
```
Structure: `AppGradientBackground` → `SafeArea` → column: header row (back button left, trailing right) → expanded child → footer. Keyboard-safe: child scrolls (`SingleChildScrollView` + `resizeToAvoidBottomInset`), button stays above keyboard; footer hides when keyboard is open.

`AppBackButton` (new): 44×44 white rounded-square (radius 12) with `Icons.arrow_back`, same semantics as today (`context.canPop()` guard).

`RegistrationProgressRing` (existing, currently unused): rewritten to the reference look — donut ring drawn by `CustomPainter` (cyan base arc, pink progress arc, `ringSize`), animates between steps with `kRingStepDuration`, morphs to a pink filled circle with white check when `completed`. Used as `trailing` on Phone (25%), OTP (50%), Name (75%), DOB (100%→check on valid). Reuses `AppProgressRing` painter if its API fits, otherwise its own painter in the auth feature (decided in the plan after reading `app_progress_ring.dart`).

## 7. Controls

- `AppButton`: pill, full width, cyan; disabled `primaryDisabled`; press-scale (`AnimatedScale` 0.97, `kPressScaleDuration`) driven by `Listener` (not `GestureDetector`, fixing the known gesture-arena bug); loading state morphs label to a centered spinner with `AnimatedSwitcher` + width stays full (`kButtonMorphDuration`). Label uppercase (already central).
- `AppTextField`: gets optional `prefix` (`Widget?`) and uses theme decoration (rendered as `prefixIcon`, since `InputDecoration.prefix` is invisible when unfocused and empty). Focus and error states animate (border color + subtle shake on error via existing shake token where applicable).
- **Phone field**: `prefix` = fixed `+95` text in `textSecondary`, vertical divider optional; the editable text starts after it. The controller holds only the national number. `validatePhone`/`normalizePhone` already accept both `9…`, `09…` and `+959…`, so the bloc call is unchanged. ARB `phoneCountryCode` is reused for the prefix text; `labelText` removed (no floating label).
- OTP boxes, DOB fields: restyled to white rounded fields via theme; behavior unchanged.

## 8. Screens

All five auth screens (Phone, OTP, Name, DOB, Welcome) move onto `AuthScaffold`; none keeps its own `Scaffold`/`AppBar`. Copy is already aligned (previous commit). Differences to add:
- Titles use bold `h1` (28) per reference; Phone title wraps naturally.
- **Login variant** (`PhoneScreen(isLogin: true)`): title "Welcome back, Login to your profile" (new ARB `loginScreenTitle`), button label "Login" (`loginButton`), and a fingerprint circle (`Icons.fingerprint` in a bordered circle, border and icon `textSecondary`) above the pinned Login button; tap shows the existing `AppSnackbar` "not implemented" message. No progress ring in login mode.
- **Onboarding**: see §9.
- **Welcome**: gradient background, tiles stagger as today.

## 9. Splash and Onboarding

New route `/splash` (initial location). `SplashScreen` (new, `features/shell/...` or `core/`; plan decides; it is not auth-specific):
1. White background, logo (`assets/icon/app_icon.png`, or site logo asset if sharper) in a circle fades+scales from 0.6→1.0 over `kSplashLogoDuration`.
2. Holds `kSplashHoldDuration` while the app finishes seeding (seed already completes before `runApp`; the hold is purely visual).
3. Exits: logo fades out as the router redirects to `/onboarding` (or `/home` if a session exists) — implemented as the splash calling `context.go(...)` after the hold, with `kSplashExitDuration` fade.
Router: `initialLocation: '/splash'`; the existing `redirect` treats `/splash` as the former `/` (route-level redirect removed; the splash decides, using `GetSessionUseCase` result already evaluated by the top-level redirect which must NOT redirect away from `/splash`). Reduce Motion: no animation, shortened hold.

**Onboarding** screen rebuilt:
- Top ~55%: stack of circular "donut tiles" (3–4 circles, colors from reference: cyan, beige, light blue, purple tint) each containing a real donut photo (`assets/images/seed/`, additional images downloaded from jdonuts.com per product list). Tiles drift in from the sides with staggered `Interval`s over `kTileDriftDuration` (`kStaggerStep` apart).
- Gradient fades in bottom-up (opacity animation on a gradient overlay).
- Logo in circle (app icon) overlapping tile edge, title "Round food for every mood", cyan pill button, login line, social icons (existing), `AppLegalFooter`.
- Title and button enter staggered (fade + 16px rise).
Assets to add: ~4 donut photos from jdonuts.com `/api/products` (Donuts category), downloaded once and bundled as before. The hi-res logo follow-up applies here too.

## 10. Remaining PDF motion

Per PDF page 12, status and approach:

| PDF row | Plan |
|---|---|
| Onboarding drift/stagger | §9 |
| Registration steps shared-axis | `go_router` `CustomTransitionPage` with a shared-axis-X transition (fade + 30px horizontal slide, `kStepTransitionDuration`) for `/phone,/otp,/name,/dob,/welcome`; implemented without a new package (`SlideTransition` + `FadeTransition`). Reduce Motion → no transition. |
| Ring 25→50→75→100→check | §6 |
| Inputs focus/error, OTP shake | focus border animates via theme (`AnimatedContainer` wrapper in `AppTextField` if theme alone is insufficient); shake already exists |
| Buttons press/morph | §7 |
| Welcome tiles + title | exists; restyle only |
| Home skeleton, section stagger, carousel autoplay | skeleton/autoplay exist; add staggered section entrance in `HomeScreen` (`kHomeSectionStagger`, fade+rise) |
| Tile → detail Hero | Hero tag = `'product-${sectionId}-${productId}'` (section-scoped, so a product shown in two sections never duplicates a tag — the cause of the earlier revert); detail screen's image uses the tag for the section it was opened from via `extra` on `/product/:id` (fallback: no Hero if absent) |
| Tab switch: nav pill + Rewards entrance | `AppBottomNav` rebuilt with a sliding `AnimatedPositioned` pill behind the active item (`kNavPillDuration`); Rewards entrance already starts when active (fixed earlier) |

All controllers/animations check `MediaQuery.disableAnimations` (existing constraint).

## 11. File map

New: `core/theme/app_theme.dart`, `core/widgets/{app_gradient_background,auth_scaffold,app_back_button}.dart`, splash screen file, donut tile widget (onboarding), asset images.
Modified: `colors.dart`, `spacing.dart`, `motion_tokens.dart`, `core_import.dart`, `app_button.dart`, `app_text_field.dart`, `app_bottom_nav.dart`, `app_router.dart` (initial location, transition pages, `extra`), `main.dart` (theme), the 6 auth screens, `registration_progress_ring.dart`, `home_screen.dart` (stagger), `product_section_list.dart` + `product_detail_screen.dart` (Hero), both ARB files, affected tests.

All new files follow the part-of-barrel convention.

## 12. Testing

- Existing 69 tests stay green; update only where structure/copy changed (`AppBar` finders, button text, route landmarks).
- New: `AppTextField` prefix (phone field renders `+95`, typed text excludes it, normalization yields `+959…`); `RegistrationProgressRing` progress mapping and check morph; `AuthScaffold` shows/hides footer with keyboard inset; router starts at `/splash` and lands on `/onboarding` without a session; Hero tag uniqueness when one product appears in two sections; Reduce Motion path skips splash animation.
- Visual verification on the simulator against the reference screenshots (known Impeller ghosting on the Onboarding screen on this host's simulators is not a defect).

## 13. Out of scope / known follow-ups

- Hi-res logo asset (user to provide).
- Real biometric login.
- Pixel-exact fonts: reference uses a rounded geometric typeface; the app keeps the platform font unless the user supplies the font file.
- Rewards/Home/Product screen restyling beyond motion (not shown in the reference set).
