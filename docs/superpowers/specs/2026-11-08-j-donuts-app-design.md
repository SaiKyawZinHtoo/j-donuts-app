# J'Donuts App — Design Spec

Date: 2026-11-08
Source: `Madivizion_Flutter_Code_Test.pdf` (15 pages, Senior Flutter Developer Code Test)

## 1. Intent

Build a working slice of the J'Donuts customer app in Flutter for a code test: 3 tasks across 10
screens (onboarding/auth, offline-first Home + Product detail, animated Rewards). Evaluated on
offline data (20%), motion/presentation (20%), architecture/code quality (20%), UI fidelity (15%),
validation/flow (10%), tests (10%), delivery (5%). Must build and run from README steps on both iOS
Simulator and Android emulator, work fully in airplane mode after first launch, and not crash the
main flow — any of these failing is an automatic fail.

## 2. Decisions locked with user

| Area | Choice | Why |
|---|---|---|
| State management | **flutter_bloc** | User's explicit pick over Riverpod |
| Local database | **Drift (SQLite)** | Spec's primary recommendation; relational seed data (products/banners/shops/member) |
| Remote/mock server | **None — local JSON seed only** | Spec marks server optional; smaller scope for 2-day window |
| Rewards art | **CustomPainter** | Spec's primary suggestion; no extra asset pipeline |
| Dependency injection | **get_it** | Keeps DI separate from BLoC state; no mixed state libraries |
| Localization | **English + Burmese (ARB)** | User wants the bonus Burmese locale included |
| Logging | **talker + talker_dio_logger ^5.2.0** | User's explicit pick for app/DB event logging |

## 3. Architecture

Clean 3-layer, presentation → domain → data, matching the PDF's own diagram:

- **Presentation** (Flutter): screens/widgets, BLoC, `go_router` with an auth redirect guard.
- **Domain** (pure Dart, zero Flutter/Drift imports): entities, use cases, repository interfaces,
  validators.
- **Data**: repository implementations reading the local Drift database (single source of truth for
  the UI), seeded from bundled JSON on first launch; fake auth repo with secure-storage session;
  image disk cache with placeholder/error states.

The UI reads only the local database. A repository implementation is the only thing allowed to
decide where data comes from; nothing above it knows whether data was seeded, cached, or (if a
server existed) fetched.

### 3.1 Folder structure

```
lib/
  main.dart
  core/
    core_import.dart        // barrel: theme + widgets + constants + result type + l10n + router + di
    theme/
      colors.dart
      text_styles.dart       // named font-size/weight constants, no inline fontSize literals
      spacing.dart
      motion_tokens.dart      // all animation durations/curves as named constants
    widgets/
      app_text_field.dart
      app_button.dart
      app_otp_box.dart
      app_progress_ring.dart   // shared CustomPainter ring shell (auth progress + rewards points)
      app_skeleton.dart
      app_empty_state.dart
      app_error_state.dart
      app_dialog.dart
      app_snackbar.dart
      app_app_bar.dart
      app_bottom_nav.dart
    constants/
      app_constants.dart       // kFakeOtpCode, kMinAgeYears, kOtpResendSeconds, etc.
    result/
      result.dart               // sealed Result<T> type for typed failures
    router/
      app_router.dart           // go_router config, auth guard, /product/:id route
    di/
      service_locator.dart      // get_it registrations
    l10n/
      (generated from assets/l10n/*.arb via gen-l10n)
  features/
    auth/
      auth_import.dart          // barrel; every file in this feature is `part of` this file
      domain/
        entities/auth_user.dart
        repositories/auth_repository.dart
        usecases/login_usecase.dart
        usecases/register_usecase.dart
        usecases/get_session_usecase.dart
        validators/phone_validator.dart
        validators/otp_validator.dart
        validators/name_validator.dart
        validators/dob_validator.dart
      data/
        repositories/auth_repository_impl.dart
        datasources/auth_local_datasource.dart   // Drift auth_users table
        datasources/session_datasource.dart       // flutter_secure_storage
      presentation/
        bloc/auth_bloc.dart
        bloc/auth_event.dart
        bloc/auth_state.dart
        screens/onboarding_screen.dart
        screens/phone_screen.dart
        screens/otp_screen.dart
        screens/name_screen.dart
        screens/dob_screen.dart
        screens/welcome_screen.dart
        widgets/registration_progress_ring.dart
    home/
      home_import.dart
      domain/ (entities: member, banner, product_section, shop; repository interface; use case)
      data/ (repository impl reading Drift DAOs)
      presentation/
        bloc/home_bloc.dart, home_event.dart, home_state.dart
        screens/home_screen.dart
        widgets/member_header.dart, banner_carousel.dart, product_section_list.dart,
                nearby_shops_row.dart
    product/
      product_import.dart
      domain/ data/ presentation/   // product entity, repository, product_detail_bloc, product_detail_screen
    rewards/
      rewards_import.dart
      domain/ data/ presentation/   // member+challenge entities, rewards_bloc, rewards_screen,
                                     // tier_ladder.dart, challenge_card.dart, tab_switcher.dart
  data/
    local/
      database.dart              // AppDatabase extends _$AppDatabase; migration strategy
      tables/
        products_table.dart
        banners_table.dart
        sections_table.dart       // + sections_products join table
        shops_table.dart
        member_table.dart          // single row, fixed id
        challenges_table.dart       // FK memberId
        auth_users_table.dart
      daos/
        product_dao.dart
        home_dao.dart
        member_dao.dart
        rewards_dao.dart
        auth_dao.dart
      seed/
        seed_loader.dart            // reads assets/seed/*.json, inserts on first launch only
        seed_keys.dart               // named constants for JSON keys, no magic strings
assets/
  seed/
    products.json
    banners.json
    sections.json
    shops.json
    member.json         // single canonical record — see 3.2
  images/seed/           // bundled donut/coffee photos, used as imageUrl fallback/offline source
  l10n/
    app_en.arb
    app_my.arb
test/
  unit/validators/ ...
  unit/usecases/ ...
  widget/auth/ ...
  integration/register_to_product_test.dart
docs/superpowers/specs/   // this file
```

### 3.2 Member data conflict

The PDF's own mock-ups disagree (Home shows Bronze/1,290 pts to Gold; Rewards shows Silver/500 pts
remaining). Per spec instruction ("both screens must read the same local data"), `member.json` uses
**Silver tier / 500 pts remaining to Gold** as the single canonical record (matches the more detailed
Rewards mock-up). Both `HomeBloc` and `RewardsBloc` read the same `member_table` row via their DAOs.

### 3.3 Import discipline

- No relative import chains. Every file imports via `package:j_donuts_app/...` paths, or — within a
  feature — via `part of`.
- **Part-based barrels**: each feature has one `<feature>_import.dart` file holding every `import`
  statement for that feature (Flutter, third-party, and `package:j_donuts_app/core/core_import.dart`)
  plus a `part '...';` directive per file in the feature. Every other file in the feature starts with
  `part of '../<feature>_import.dart';` and declares no imports of its own. `core/core_import.dart`
  follows the same pattern for shared code.
- A feature that needs another feature imports only that feature's barrel file, never its internals.
- Layer rule: domain imports nothing from data or presentation; data imports domain; presentation
  imports domain (and data only via the DI-registered interface, never the concrete impl type).
- Import order inside a barrel: `dart:` → `package:flutter` → third-party `package:` →
  `package:j_donuts_app` (other feature barrels / core) → `part` directives last.

### 3.4 Shared widgets (DRY)

Every screen draws form fields, buttons, loading/empty/error states, dialogs, and snackbars from
`core/widgets/` — never an inline one-off. All colors/text styles/spacing come from `core/theme/`
tokens; no hard-coded values in any widget. This is what keeps the 10 screens visually consistent
and keeps spec's "no hard-coded colours in widgets" requirement satisfied by construction.

## 4. Task 1 — Auth flow and validation

### 4.1 Validators (`features/auth/domain/validators/`, pure Dart, each unit-tested)

| Validator | Rule |
|---|---|
| `validatePhone` | Strip spaces/dashes and one leading 0 after the +95 prefix; valid = +95 followed by 7–9 digits |
| `validateOtp` | Exactly 6 digits, equals `kFakeOtpCode` ("123456") |
| `validateFirstName` | Required, 1–50 trimmed chars, letters + spaces (Myanmar script included), no digits |
| `validateLastName` | Optional, same character rules as first name |
| `validateDob` | Real calendar date (29 Feb only in leap years), not in the future, age ≥ `kMinAgeYears` (13) |

Each returns a sealed `ValidationResult` (`ValidationValid` / `ValidationInvalid(message)`).

### 4.2 Flow (AuthBloc, sealed events/states)

- Registration: Onboarding → Phone → OTP → Name → DOB → Welcome → Home.
- Login: Onboarding (Log in) → Phone → OTP → Home.
- `PhoneSubmitted` → validate → fake ~1s `AuthRepository` call checks if phone is registered →
  known number: `AuthSuccess` (login path) → Home; unknown number on login path: inline message +
  link to register.
- `OtpDigitEntered` × 6 with auto-advance/backspace/paste-fill/numeric keyboard/SMS-autofill hint;
  auto-validates on the 6th digit against `123456`; wrong code → shake + clear + inline message,
  3 wrong attempts → locked until resend. `OtpResendRequested` restarts the 5:00 countdown and resets
  attempts.
- `NameSubmitted` → `DobSubmitted` → `AuthSuccess(isNewUser: true)` → Welcome → Home.
- `SessionChecked` on launch reads `flutter_secure_storage` via `AuthRepository.getSession()`: logged
  in → Home; logged out → Onboarding.
- `LogoutRequested` (Settings tab) clears secure storage and bloc state → Onboarding.
- Back arrow is a plain `Navigator.pop`; entered values persist in a `RegistrationDraft` held in
  `AuthBloc` state so returning to a step shows what was typed.
- Every Continue press shows a loading state during the fake call; a double-tap sends exactly one
  request (debounced in the bloc).
- Google/Apple/Facebook/Terms/Privacy: no real integration — `AppDialog` placeholder or `AppSnackbar`.

`AuthRepository` interface: `checkPhone`, `verifyOtp`, `resendOtp`, `completeRegistration`, `login`,
`logout`, `getSession`. `FakeAuthRepositoryImpl` waits ~1s per call, persists users to the
`auth_users` Drift table, and session token via secure storage — so a real API can replace it later
without touching the UI.

## 5. Task 2 — Home and Product detail, offline-first

### 5.1 Data flow

On first launch, `SeedLoader` checks a `seeded` flag; if unset, reads `assets/seed/*.json` into Drift
tables, then sets the flag. From then on, every screen read goes through a DAO → Drift only — never
directly to JSON or network. `HomeBloc.HomeRequested` reads member + banners + sections + shops in
one DAO call and emits `HomeLoaded` with a per-section breakdown so one section's error/empty state
doesn't blank the rest of the screen. Pull-to-refresh and connectivity-regained both re-run the same
read path; an offline banner shows when `connectivity_plus` plus a reachability check reports no
network. Because no mock server is being built (see §2), the "background refresh from network" step
is a documented no-op hook, not a real network call — called out explicitly in the README as a known
gap, not left silent.

### 5.2 Home screen (screen 8)

Header (member name/photo/tier/points-to-next-tier/notification bell), banner carousel, horizontal
lists for Seasonal specials / Popular / Order again (discount badges from data), 4 nearby shop cards
(display-only, no action needed), bottom nav. Loading state is a skeleton shimmer (`AppSkeleton`),
not a spinner; each section carries its own empty/error state.

### 5.3 Product detail (screen 9)

Opened by tapping any product tile. Shows product code, name, MMK price with thousands separators,
New badge from data, image, description under "What's this?". Quantity stepper (minimum 1); Add to
cart shows the live total (quantity × price) and visual-only feedback (persistent cart is a bonus,
out of scope here).

### 5.4 Images

Every network image goes through `cached_network_image` with an `AppSkeleton` placeholder and an
error-state fallback to a bundled `assets/images/seed/` asset, so a cold offline launch still renders
images.

## 6. Task 3 — Rewards screen, motion

### 6.1 Data

`RewardsBloc.RewardsRequested` reads the same canonical member record (§3.2) plus challenges from
Drift via `rewards_dao`.

### 6.2 Animation (durations/curves from `core/theme/motion_tokens.dart`, named constants)

- **Points ring** (`AppProgressRing`, CustomPainter): sweeps 0 → current/max over
  `kPointsRingDuration`; the "680,000" counter ticks up in sync off the same `AnimationController`
  (`Tween<int>`), not a separate timer.
- **Tier ladder**: current tier highlighted (scale + color tween); connecting line to next tier fills
  via a second CustomPainter, staggered against the ring (`Interval` 0.0–0.6 ring, 0.3–1.0 line).
- **Challenge cards**: staggered entrance (`index * kStaggerStep` delay), slide + fade in. Each card's
  own progress art (donut quarters / coffee arc) is its own CustomPainter reading
  `challenge.current/target`, redrawn via `ValueListenable` without rebuilding the whole list.
- **Tabs (Earn/Gift)**: `AnimatedPositioned`/`AnimatedAlign` pill under the active label
  (`kTabSwitchDuration`); content swap via `AnimatedSwitcher`.
- **Earn button**: enabled only when `current == target`; tap gives `AnimatedScale` press feedback —
  visual only, no state change, per spec.
- **Rewards badge "3"**: one-shot scale + fade entrance when the tab is opened.
- **Bottom nav**: shared `AppBottomNav` widget instance across Home/Rewards; active pill slides via
  `AnimatedPositioned` on tab switch, avoiding a full navigation rebuild.
- **Reduce Motion**: every `AnimationController` checks `MediaQuery.of(context).disableAnimations`
  and skips to end state (`duration: Duration.zero` or `forward(from: 1.0)`) rather than faking it.
- Onboarding, registration steps (shared-axis/slide + ring morph to check), inputs (focus/error/OTP
  shake), buttons (press scale, Continue→loading morph), Welcome (staggered tile slide + title fade),
  Home (skeleton shimmer, staggered section entrance, auto-playing carousel), and the product tile→
  detail hero transition all follow the PDF's "Animations and transitions" table (page 12) using the
  same named-constant motion tokens.

## 7. Bottom navigation scope

Only Home and Rewards need real logic (shared `AppBottomNav`, `IndexedStack` or equivalent to avoid
full rebuilds on switch). The other three icons open a simple placeholder screen — no functionality
built beyond that, per spec.

## 8. Testing

- `test/unit/validators/`: one file per validator above, covering valid cases and boundaries (e.g.
  29 Feb non-leap year, age exactly 13, 51-char name).
- `test/unit/usecases/`: `login_usecase_test.dart`, `get_home_usecase_test.dart`,
  `get_rewards_usecase_test.dart`, repository interfaces mocked via `mocktail`.
- `test/widget/auth/`: `login_screen_test.dart`, `register_flow_test.dart` — invalid phone keeps
  Continue disabled, 3 wrong OTP codes lock entry, a valid full flow navigates through.
- `test/integration/register_to_product_test.dart`: Onboarding → Phone → OTP(123456) → Name → DOB →
  Welcome → Home → tap a product → Product detail, asserting each screen's key landmark.
- Test names describe behavior, e.g. `validatePhone_returnsInvalid_whenLessThan7DigitsAfterPrefix`.

## 9. Technical requirements checklist (from PDF, tracked for self-verification)

- Latest stable Flutter/Dart, versions recorded in README.
- Feature-first folders, domain layer with zero Flutter imports — enforced by the part-barrel
  structure in §3.3.
- flutter_bloc for state; get_it for DI, no service created inside a widget.
- go_router with an auth redirect guard and a `/product/:id` route.
- Drift (SQLite), versioned migrations.
- `flutter_secure_storage` for session.
- Models: Dart 3 sealed classes/records or freezed + json_serializable (decide at implementation
  time per entity complexity).
- Errors: sealed `Result<T>` return type, no swallowed exceptions; every screen has loading/error/
  empty states (built on shared `core/widgets`).
- Images: `cached_network_image` + disk cache; seed images bundled as assets.
- `connectivity_plus` plus a real reachability check.
- Theme tokens only, no hard-coded colors/sizes in widgets.
- ARB strings via `gen-l10n`, English + Burmese.
- Portrait layouts 4.7–6.9 in, text scale up to 1.3 without overflow.
- `flutter analyze` clean (`flutter_lints` or `very_good_analysis`); functions ~20 lines, files ~300
  lines; named constants, no magic numbers.
- `pubspec.yaml` dependencies to add: `flutter_bloc`, `drift` + `sqlite3_flutter_libs` (+
  `drift_dev`/`build_runner` dev deps), `get_it`, `flutter_secure_storage`, `cached_network_image`,
  `connectivity_plus`, `go_router`, `mocktail` (dev), `talker`, `talker_dio_logger: ^5.2.0`,
  `flutter_localizations` (sdk) + `intl`, `flutter_lints`.

## 10. Deliverables

1. Public Git repo, small readable commits (scaffold → core/theme → auth → home → product → rewards
   → tests → polish).
2. Release `.apk` (Android) + zipped `.app` built with `flutter build ios --simulator` (iOS
   Simulator), attached or linked.
3. Screen recording, 2–4 min: register → logout → login → Home → Product detail → Rewards, then the
   same flow repeated in airplane mode.
4. README covering: how to run, Flutter/Dart versions, architecture + folder map, state-management
   choice (BLoC) and why, offline strategy, animations built, the fake OTP code (`123456`), known
   gaps (no real mock/remote server — spec-optional, documented; no persistent cart — spec-bonus,
   skipped), time spent.
5. `.gitignore` excludes `assets/design_screenshots/` (if ever added) and the source PDF — design
   images belong to the client and must never be committed or published.

## 11. Known gaps (intentional, by scope decision)

- No real mock HTTP server / `/v1` envelope — spec marks it optional; local JSON seed into Drift is
  the full data source. The "background refresh when online" path is a documented no-op hook.
- No persistent cart — spec marks it a bonus; Add to cart is visual feedback only.
- No real OAuth/social login, Terms/Privacy content — spec requires placeholder only.
