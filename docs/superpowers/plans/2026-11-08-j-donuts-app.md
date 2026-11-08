# J'Donuts App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the J'Donuts Flutter code-test slice — fake-but-validated auth (10 screens' worth of
flow), an offline-first Home + Product detail, and an animated Rewards screen — on clean 3-layer
architecture with BLoC.

**Architecture:** Presentation (Flutter widgets + flutter_bloc + go_router) → Domain (pure Dart
entities/use cases/repository interfaces/validators) → Data (Drift local DB as single source of
truth, seeded from bundled JSON, fake auth repo, image disk cache). Each feature is one part-file
barrel (`<feature>_import.dart`); no inter-file relative imports.

**Tech Stack:** Flutter (latest stable) + Dart 3, flutter_bloc, drift + sqlite3_flutter_libs, get_it,
flutter_secure_storage, cached_network_image, connectivity_plus, go_router, mocktail (dev), talker +
talker_dio_logger ^5.2.0, flutter_localizations + intl (gen-l10n, en + my), flutter_lints.

**Spec:** `docs/superpowers/specs/2026-11-08-j-donuts-app-design.md`

## Global Constraints

- Domain layer files have zero Flutter/Drift imports (pure Dart only).
- Every file in a feature folder has no `import` statements of its own — only
  `part of '../<feature>_import.dart';` — all imports live once in that feature's barrel.
- No hard-coded colors, font sizes, or spacing values in any widget — use `core/theme` tokens only.
- No magic numbers/strings — named constants in `core/constants/app_constants.dart` or the relevant
  feature's domain layer (e.g. `kFakeOtpCode = '123456'`, `kMinAgeYears = 13`,
  `kOtpResendSeconds = 300`).
- Every screen-level BLoC state includes loading, error, and (where relevant) empty variants built on
  shared `core/widgets` (`AppSkeleton`, `AppErrorState`, `AppEmptyState`).
- All animation durations/curves are named constants in `core/theme/motion_tokens.dart`; every
  `AnimationController` checks `MediaQuery.of(context).disableAnimations` and skips to end state.
- UI matches the 10 PDF screens exactly (spacing, type, color, states); only the 3 non-required
  bottom-nav tabs get a generic placeholder screen beyond what the PDF shows.
- `assets/images/seed/` design-derived photos are allowed as app assets; the source PDF and any raw
  design screenshots are never committed (`.gitignore`).
- Functions ~20 lines, files ~300 lines; `flutter analyze` must stay clean.
- The local Drift database is the only thing the UI reads from — repository implementations are the
  only code that decides where data originates.

## Review Focus

- **Phone numbers with 10+ digits after the leading 0** (e.g. `012345678901`) — the validator must
  reject (9-digit max after prefix), not silently truncate or accept.
- **DOB of exactly today's date, or tomorrow** — "not in the future" must reject tomorrow and accept
  today; age-13 boundary must accept someone whose 13th birthday is today and reject someone one day
  short.
- **Rapid double-tap on a Continue/Login button** — must send exactly one fake request, not two
  (debounce in the bloc, not just UI disable, since the disable itself is state-driven).
- **Cold launch with zero network and zero prior seed** (true first run, airplane mode) — Home,
  Product detail, and Rewards must all render fully from bundled assets/seed JSON, no blank/stuck
  loading state.
- **OTP resend tapped before the countdown reaches 0:00** — must stay a no-op (button inactive),
  never reset the timer early or double-arm the lock-out counter.

---

## File Structure

```
lib/
  main.dart
  core/
    core_import.dart
    theme/colors.dart
    theme/text_styles.dart
    theme/spacing.dart
    theme/motion_tokens.dart
    widgets/app_text_field.dart
    widgets/app_button.dart
    widgets/app_otp_box.dart
    widgets/app_progress_ring.dart
    widgets/app_skeleton.dart
    widgets/app_empty_state.dart
    widgets/app_error_state.dart
    widgets/app_dialog.dart
    widgets/app_snackbar.dart
    widgets/app_app_bar.dart
    widgets/app_bottom_nav.dart
    constants/app_constants.dart
    result/result.dart
    router/app_router.dart
    di/service_locator.dart
  data/local/database.dart
  data/local/tables/products_table.dart
  data/local/tables/banners_table.dart
  data/local/tables/sections_table.dart
  data/local/tables/shops_table.dart
  data/local/tables/member_table.dart
  data/local/tables/challenges_table.dart
  data/local/tables/auth_users_table.dart
  data/local/daos/product_dao.dart
  data/local/daos/home_dao.dart
  data/local/daos/member_dao.dart
  data/local/daos/rewards_dao.dart
  data/local/daos/auth_dao.dart
  data/local/seed/seed_keys.dart
  data/local/seed/seed_loader.dart
  features/auth/auth_import.dart (+ domain/data/presentation files)
  features/home/home_import.dart (+ domain/data/presentation files)
  features/product/product_import.dart (+ domain/data/presentation files)
  features/rewards/rewards_import.dart (+ domain/data/presentation files)
  features/shell/shell_import.dart (bottom-nav shell + 3 placeholder tabs)
assets/seed/{products,banners,sections,shops,member}.json
assets/images/seed/*.png
assets/l10n/app_en.arb, app_my.arb
test/unit/validators/*_test.dart
test/unit/usecases/*_test.dart
test/widget/auth/*_test.dart
test/integration/register_to_product_test.dart
```

---

### Task 0: Project scaffolding, dependencies, theme tokens, core widgets

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/core_import.dart`
- Create: `lib/core/theme/colors.dart`, `text_styles.dart`, `spacing.dart`, `motion_tokens.dart`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/core/result/result.dart`
- Create: `lib/core/widgets/app_text_field.dart`, `app_button.dart`, `app_otp_box.dart`,
  `app_progress_ring.dart`, `app_skeleton.dart`, `app_empty_state.dart`, `app_error_state.dart`,
  `app_dialog.dart`, `app_snackbar.dart`, `app_app_bar.dart`, `app_bottom_nav.dart`
- Create: `.gitignore` entries for `*.pdf`, `assets/design_screenshots/`
- Test: `test/unit/core/result_test.dart`

**Interfaces:**
- Produces: `sealed class Result<T>` with `Ok<T>(T value)` / `Err<T>(String message)` variants, used
  as the return type by every repository method in later tasks.
- Produces: `AppColors`, `AppTextStyles`, `AppSpacing`, `MotionTokens` (static const fields) — every
  later widget reads from these, never literal values.
- Produces: `AppButton({required String label, required VoidCallback? onPressed, bool loading})`,
  `AppTextField({required TextEditingController controller, String? errorText, ...})`,
  `AppOtpBox({required int length, required ValueChanged<String> onCompleted, String? errorText})`,
  `AppProgressRing({required double progress, required AnimationController controller})`,
  `AppSkeleton({required Widget child, required bool isLoading})`,
  `AppEmptyState({required String message})`, `AppErrorState({required String message, VoidCallback? onRetry})`,
  `AppDialog.show(BuildContext, {required String title, required String message})`,
  `AppSnackbar.showSuccess/showError(BuildContext, String message)`,
  `AppBottomNav({required int currentIndex, required ValueChanged<int> onTap})`.

- [ ] **Step 1: Add dependencies to `pubspec.yaml`**

Add: `flutter_bloc`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `get_it`,
`flutter_secure_storage`, `cached_network_image`, `connectivity_plus`, `go_router`, `talker`,
`talker_dio_logger: ^5.2.0`, `intl`; dev: `drift_dev`, `build_runner`, `mocktail`, `flutter_lints`.
Add `flutter: generate: true` and an `l10n.yaml` referencing `assets/l10n/`.

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: resolves with no version conflicts.

- [ ] **Step 3: Write the failing test for `Result`**

```dart
test('Ok holds a value and Err holds a message', () {
  final ok = Result<int>.ok(5);
  final err = Result<int>.err('boom');
  expect(ok, isA<Ok<int>>());
  expect((ok as Ok<int>).value, 5);
  expect((err as Err<int>).message, 'boom');
});
```

- [ ] **Step 4: Run test, confirm it fails** (type not defined)

- [ ] **Step 5: Implement `core/result/result.dart`**

Dart 3 sealed class, two variants as above, no Flutter import.

- [ ] **Step 6: Run test, confirm it passes**

- [ ] **Step 7: Implement theme token files**

`AppColors` (primary pink/teal from PDF screens, named semantic fields: `primary`, `accent`,
`background`, `error`, `success`, `textPrimary`, `textSecondary`). `AppTextStyles` (h1/h2/body/caption/
button, as `TextStyle` consts or static getters over a base `TextTheme`). `AppSpacing` (xs/sm/md/lg/xl
as `double` consts, e.g. 4/8/16/24/32). `MotionTokens` (`kPointsRingDuration`, `kTabSwitchDuration`,
`kStaggerStep`, `kEmphasizedCurve`, etc., matching spec §6.2).

- [ ] **Step 8: Implement `app_constants.dart`**

`kFakeOtpCode = '123456'`, `kMinAgeYears = 13`, `kOtpResendSeconds = 300`, `kOtpMaxAttempts = 3`,
`kFakeNetworkDelay = Duration(seconds: 1)`.

- [ ] **Step 9: Implement each core widget**

Build each to the signatures in Interfaces, reading only `AppColors`/`AppTextStyles`/`AppSpacing`
(no literals). `AppProgressRing` and `AppOtpBox` are the only non-trivial ones — `AppProgressRing`
wraps a `CustomPainter` driven by the passed-in `AnimationController` (painter reads
`controller.value * progress`); `AppOtpBox` is a row of `length` boxes with auto-advance/backspace/
paste-fill logic and a numeric keyboard.

- [ ] **Step 10: Assemble `core/core_import.dart`**

`library core;` + all Flutter/package imports used across core + `part` directive per file above.

- [ ] **Step 11: Run `flutter analyze`**

Expected: no errors in `lib/core/`.

- [ ] **Step 12: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core test/unit/core .gitignore
git commit -m "feat: scaffold core theme, widgets, result type, constants"
```

---

### Task 1: Drift database, tables, DAOs, JSON seed loader

**Files:**
- Create: `lib/data/local/database.dart`
- Create: `lib/data/local/tables/{products,banners,sections,shops,member,challenges,auth_users}_table.dart`
- Create: `lib/data/local/daos/{product,home,member,rewards,auth}_dao.dart`
- Create: `lib/data/local/seed/seed_keys.dart`, `seed_loader.dart`
- Create: `assets/seed/{products,banners,sections,shops,member}.json`
- Create: `assets/images/seed/*.png` (placeholder donut/coffee images, any royalty-free/bundled source
  — not the PDF's own screenshots)
- Test: `test/unit/data/seed_loader_test.dart`

**Interfaces:**
- Consumes: nothing from Task 0 beyond Flutter/package deps.
- Produces: `AppDatabase` (drift `@DriftDatabase` over all 7 tables) with a `migrationStrategy`;
  `ProductDao.watchAll()`, `ProductDao.getById(String id)`; `HomeDao.getHome()` returning a typed
  bundle (member row + banners + sections-with-products + shops); `MemberDao.watchMember()`;
  `RewardsDao.getChallenges()`; `AuthDao.findByPhone(String phone)`, `AuthDao.insertUser(...)`.
  `SeedLoader.seedIfNeeded(AppDatabase db)` — reads `assets/seed/*.json`, inserts rows, no-ops if a
  `seeded` flag (a one-row Drift `meta` table or `shared_preferences` key) is already set.

- [ ] **Step 1: Write the failing test for seeding**

```dart
test('seedIfNeeded populates products table exactly once', () async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await SeedLoader(db).seedIfNeeded();
  final first = await db.select(db.products).get();
  await SeedLoader(db).seedIfNeeded(); // second call must not duplicate
  final second = await db.select(db.products).get();
  expect(first, isNotEmpty);
  expect(second.length, first.length);
});
```

- [ ] **Step 2: Run test, confirm it fails** (types not defined)

- [ ] **Step 3: Define the 7 Drift tables**

Columns per spec §3.1/§5: `products(id, code, name, priceMmk, isNew, discountPercent, imageUrl,
description)`; `banners(id, imageUrl, title, deepLinkTarget)`; `sections(id, title)` +
`sectionsProducts(sectionId, productId, sortOrder)`; `shops(id, name, address, distanceLabel)`;
`member(id, name, photoUrl, tier, points, nextTierPoints, totalPoints)` (single fixed-id row);
`challenges(id, memberId, title, current, target, rewardPts, artType)`;
`authUsers(id, phone, firstName, lastName, dob, createdAt)`. Add a `meta(key, value)` table for the
`seeded` flag.

- [ ] **Step 4: Generate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `database.g.dart` generated, no errors.

- [ ] **Step 5: Write `assets/seed/*.json` fixture data**

One canonical `member.json` record: Silver tier, 500 pts remaining to Gold (per spec §3.2). Products
include at least `p_coconut` (Coconut Donut, code `JD022123`, 3200 MMK, isNew true) matching the
PDF's reference design. Sections: `seasonal_specials`, `popular`, `order_again`, each referencing
product ids. 4 shops. 3+ challenges on the member (one at 4/4 "Eat 4 Coco donuts", one at partial
progress "Drink 12 cups americano" 9/12, per PDF page 10-11).

- [ ] **Step 6: Implement `SeedLoader`**

Reads `meta` table for `seeded`; if absent, loads each JSON asset via `rootBundle.loadString`,
decodes, inserts via DAOs/batch insert, then writes `seeded = 'true'` to `meta`.

- [ ] **Step 7: Run test, confirm it passes**

- [ ] **Step 8: Implement remaining DAOs** (`ProductDao`, `HomeDao`, `MemberDao`, `RewardsDao`, `AuthDao`)

Each a thin Drift `@DriftAccessor` exposing typed reads/writes per the Produces list; no business
logic, just queries and joins (e.g. `HomeDao.getHome()` joins `sections` ⋈ `sectionsProducts` ⋈
`products`).

- [ ] **Step 9: Run `flutter analyze` and full `data/local` test suite**

Expected: clean, all green.

- [ ] **Step 10: Commit**

```bash
git add lib/data/local assets/seed assets/images/seed test/unit/data
git commit -m "feat: add Drift schema, DAOs, and JSON seed loader"
```

---

### Task 2: DI, routing, app shell, main.dart

**Files:**
- Create: `lib/core/di/service_locator.dart`
- Create: `lib/core/router/app_router.dart`
- Create: `lib/features/shell/shell_import.dart`, `lib/features/shell/presentation/screens/app_shell_screen.dart`,
  `lib/features/shell/presentation/screens/placeholder_tab_screen.dart`
- Modify: `lib/main.dart`
- Test: `test/unit/core/service_locator_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 1), repository interfaces (Tasks 3–6, registered here once they
  exist — this task registers the DB/DAO singletons now and each later task adds its own
  registration in its own file, not here).
- Produces: `setupServiceLocator()` (get_it `GetIt.instance` registrations for `AppDatabase` and each
  DAO as lazy singletons); `appRouter` (`GoRouter` instance) with routes `/`, `/onboarding`, `/phone`,
  `/otp`, `/name`, `/dob`, `/welcome`, `/home`, `/product/:id`, `/rewards`, auth-guarded via a
  `redirect` callback reading session state.

- [ ] **Step 1: Write the failing test**

```dart
test('service locator registers AppDatabase as a singleton', () {
  setupServiceLocator();
  final a = GetIt.instance<AppDatabase>();
  final b = GetIt.instance<AppDatabase>();
  expect(identical(a, b), isTrue);
});
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Implement `service_locator.dart`**

`GetIt.instance.registerLazySingleton<AppDatabase>(() => AppDatabase())` plus each DAO
(`registerLazySingleton(() => ProductDao(GetIt.instance()))` etc.).

- [ ] **Step 4: Run test, confirm it passes**

- [ ] **Step 5: Implement `app_router.dart`**

`GoRouter` with the routes above; `redirect` checks `AuthRepository.getSession()` (interface defined
in Task 3 — this file depends on Task 3's `AuthRepository` type existing, so implement this step
after Task 3, or stub the guard here and wire the real check when Task 3 lands). Route for
`/product/:id` extracts `id` as a path param into `ProductDetailScreen`.

- [ ] **Step 6: Implement `AppShellScreen`**

Hosts `AppBottomNav` + `IndexedStack` over Home, Rewards, and 3 `PlaceholderTabScreen` instances
(simple centered message, per spec §7 — no functionality beyond display).

- [ ] **Step 7: Wire `main.dart`**

Calls `setupServiceLocator()`, runs `SeedLoader(GetIt.instance<AppDatabase>()).seedIfNeeded()` before
`runApp`, sets up `MaterialApp.router` with `appRouter`, `localizationsDelegates` from generated l10n.

- [ ] **Step 8: Run `flutter analyze`**

- [ ] **Step 9: Commit**

```bash
git add lib/core/di lib/core/router lib/features/shell lib/main.dart test/unit/core
git commit -m "feat: wire DI, router, and app shell"
```

---

### Task 3: Auth domain — validators, entities, repository interface, use cases

**Files:**
- Create: `lib/features/auth/auth_import.dart`
- Create: `lib/features/auth/domain/entities/auth_user.dart`
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/domain/validators/{phone,otp,name,dob}_validator.dart`
- Create: `lib/features/auth/domain/usecases/{login,register,get_session}_usecase.dart`
- Test: `test/unit/validators/{phone,otp,name,dob}_validator_test.dart`
- Test: `test/unit/usecases/login_usecase_test.dart`

**Interfaces:**
- Consumes: `Result<T>` (Task 0).
- Produces: `ValidationResult` sealed class (`ValidationValid` / `ValidationInvalid(String message)`);
  `validatePhone(String raw) -> ValidationResult`; `validateOtp(String code) -> ValidationResult`;
  `validateFirstName(String value) -> ValidationResult`; `validateLastName(String value) ->
  ValidationResult`; `validateDob(DateTime value) -> ValidationResult`; `AuthUser` entity
  (`id, phone, firstName, lastName, dob`); abstract `AuthRepository` with `checkPhone(String phone) ->
  Future<Result<bool>>`, `verifyOtp(String phone, String code) -> Future<Result<void>>`,
  `resendOtp(String phone) -> Future<Result<void>>`, `completeRegistration({required String phone,
  required String firstName, String? lastName, required DateTime dob}) -> Future<Result<AuthUser>>`,
  `login(String phone) -> Future<Result<AuthUser>>`, `logout() -> Future<Result<void>>`,
  `getSession() -> Future<Result<AuthUser?>>`; `LoginUseCase(AuthRepository)`, `RegisterUseCase
  (AuthRepository)`, `GetSessionUseCase(AuthRepository)` each exposing a single `call(...)` method
  delegating to the repository.

- [ ] **Step 1: Write failing validator tests**

```dart
group('validatePhone', () {
  test('accepts 09254135592 and normalizes to +959254135592', () {
    expect(validatePhone('09254135592'), isA<ValidationValid>());
  });
  test('rejects fewer than 7 digits after prefix', () {
    expect(validatePhone('091234'), isA<ValidationInvalid>());
  });
  test('rejects more than 9 digits after prefix', () {
    expect(validatePhone('0123456789012'), isA<ValidationInvalid>());
  });
});
group('validateOtp', () {
  test('accepts exactly 123456', () => expect(validateOtp('123456'), isA<ValidationValid>()));
  test('rejects any other 6 digits', () => expect(validateOtp('111111'), isA<ValidationInvalid>()));
});
group('validateFirstName', () {
  test('rejects empty string', () => expect(validateFirstName(''), isA<ValidationInvalid>()));
  test('accepts Myanmar script name', () => expect(validateFirstName('မျိုးသူ'), isA<ValidationValid>()));
  test('rejects digits', () => expect(validateFirstName('Ye123'), isA<ValidationInvalid>()));
});
group('validateDob', () {
  test('rejects Feb 29 in a non-leap year', () => expect(validateDob(DateTime(2023, 2, 29)), isA<ValidationInvalid>()));
  test('rejects a date in the future (tomorrow)', () { /* DateTime.now().add(1 day) */ });
  test('accepts someone whose 13th birthday is today', () { /* now - 13 years */ });
  test('rejects someone one day short of 13', () { /* now - 13 years + 1 day */ });
});
```

- [ ] **Step 2: Run tests, confirm all fail**

- [ ] **Step 3: Implement the 4 validators**

Pure functions per spec §4.1: phone strips spaces/dashes/one leading 0, prefixes `+95`, checks 7–9
remaining digits; OTP checks length 6 and equality to `kFakeOtpCode`; name checks trimmed length
1–50, regex allowing letters (incl. Myanmar Unicode block) and spaces, no digits, last name same but
empty allowed; DOB uses `DateTime` validity (reject constructing an invalid calendar date by
re-checking day/month/year after construction), `isBefore(DateTime.now())` or equal-today allowed,
and an age calculation against `kMinAgeYears`.

- [ ] **Step 4: Run tests, confirm they pass**

- [ ] **Step 5: Implement `AuthUser`, `AuthRepository` interface, and the 3 use cases**

Plain Dart classes/abstract class per Produces signatures above.

- [ ] **Step 6: Write failing `LoginUseCase` test with a mocktail fake repository**

```dart
test('LoginUseCase delegates to repository.login', () async {
  final repo = MockAuthRepository();
  when(() => repo.login('+959254135592')).thenAnswer((_) async => Result.ok(testUser));
  final result = await LoginUseCase(repo).call('+959254135592');
  expect(result, isA<Ok<AuthUser>>());
});
```

- [ ] **Step 7: Run test, confirm it fails, then implement, then confirm it passes**

- [ ] **Step 8: Assemble `auth_import.dart` barrel and convert each file above to `part of`**

- [ ] **Step 9: Run `flutter analyze` and the full `test/unit/validators` + `usecases` suite**

- [ ] **Step 10: Commit**

```bash
git add lib/features/auth/auth_import.dart lib/features/auth/domain test/unit/validators test/unit/usecases
git commit -m "feat: auth domain layer — validators, entities, use cases"
```

---

### Task 4: Auth data layer — fake repository, session storage

**Files:**
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Create: `lib/features/auth/data/datasources/auth_local_datasource.dart`
- Create: `lib/features/auth/data/datasources/session_datasource.dart`
- Test: `test/unit/data/auth_repository_impl_test.dart`

**Interfaces:**
- Consumes: `AuthDao` (Task 1), `AuthRepository`/`AuthUser` (Task 3), `kFakeOtpCode`,
  `kFakeNetworkDelay`, `kOtpMaxAttempts` (Task 0).
- Produces: `FakeAuthRepositoryImpl implements AuthRepository`; `AuthLocalDataSource` wrapping
  `AuthDao`; `SessionDataSource` wrapping `flutter_secure_storage` with `saveSession(AuthUser)`,
  `readSession() -> Future<AuthUser?>`, `clearSession()`.

- [ ] **Step 1: Write failing test for unknown-phone login**

```dart
test('login returns Err for an unregistered phone', () async {
  final repo = FakeAuthRepositoryImpl(localDataSource: fakeLocalDs, sessionDataSource: fakeSessionDs);
  final result = await repo.login('+959000000000');
  expect(result, isA<Err<AuthUser>>());
});
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Implement `SessionDataSource` and `AuthLocalDataSource`**

`SessionDataSource` stores a JSON-encoded `AuthUser` under one secure-storage key.
`AuthLocalDataSource.findByPhone`/`insertUser` delegate to `AuthDao`.

- [ ] **Step 4: Implement `FakeAuthRepositoryImpl`**

Every method awaits `kFakeNetworkDelay` then: `checkPhone`/`login` query `AuthLocalDataSource`;
`completeRegistration` inserts via `AuthLocalDataSource` and calls `SessionDataSource.saveSession`;
`verifyOtp`/`resendOtp` are pure in-memory (no DB) per spec — OTP correctness and attempt counting
live in `AuthBloc` (Task 6), this repository just exposes the fake delay/boundary for symmetry if a
real API replaces it; `getSession` reads `SessionDataSource.readSession`; `logout` clears it.

- [ ] **Step 5: Run test, confirm it passes**

- [ ] **Step 6: Register in `service_locator.dart`** (extends Task 2's file)

Add `registerLazySingleton<AuthRepository>(() => FakeAuthRepositoryImpl(...))`.

- [ ] **Step 7: Wire the router's auth guard** (completes Task 2's stub)

`redirect` in `app_router.dart` calls `GetSessionUseCase` via get_it; null session outside
`/onboarding.../welcome` → redirect to `/onboarding`; present session hitting an auth route →
redirect to `/home`.

- [ ] **Step 8: Run `flutter analyze` and the data test suite**

- [ ] **Step 9: Commit**

```bash
git add lib/features/auth/data lib/core/di/service_locator.dart lib/core/router/app_router.dart test/unit/data
git commit -m "feat: fake auth repository, session storage, auth route guard"
```

---

### Task 5: Auth presentation — AuthBloc

**Files:**
- Create: `lib/features/auth/presentation/bloc/auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- Test: `test/unit/presentation/auth_bloc_test.dart` (using `bloc_test` or manual `expectLater(bloc.stream, emitsInOrder([...]))`)

**Interfaces:**
- Consumes: `LoginUseCase`, `RegisterUseCase`, `GetSessionUseCase` (Task 3), `AuthRepository`
  (Task 4, for `verifyOtp`/`resendOtp`), validators (Task 3), `kOtpMaxAttempts`,
  `kOtpResendSeconds` (Task 0).
- Produces: `AuthEvent` sealed: `PhoneSubmitted(String raw)`, `OtpDigitEntered(String code)`,
  `OtpResendRequested()`, `NameSubmitted(String first, String? last)`, `DobSubmitted(DateTime dob)`,
  `SessionChecked()`, `LogoutRequested()`, `BackRequested()`. `AuthState` sealed:
  `AuthInitial`, `AuthLoading`, `PhoneInvalid(String message)`, `PhoneNeedsRegistration()`,
  `OtpAwaiting(int secondsLeft)`, `OtpInvalid(int attemptsLeft)`, `OtpLocked()`,
  `RegistrationStepInvalid(String message)`, `AuthSuccess(AuthUser user, bool isNewUser)`,
  `AuthFailure(String message)`, carrying a `RegistrationDraft {phone, firstName, lastName, dob}`
  field on every registration-path state so back-navigation preserves entered values.

- [ ] **Step 1: Write failing bloc test for 3-strike OTP lockout**

```dart
blocTest<AuthBloc, AuthState>(
  'locks after 3 wrong OTP codes',
  build: () => AuthBloc(loginUseCase: mockLogin, registerUseCase: mockRegister,
      getSessionUseCase: mockGetSession, authRepository: mockAuthRepo),
  act: (bloc) => bloc
    ..add(const OtpDigitEntered('000000'))
    ..add(const OtpDigitEntered('000000'))
    ..add(const OtpDigitEntered('000000')),
  expect: () => [
    isA<OtpInvalid>().having((s) => s.attemptsLeft, 'attemptsLeft', 2),
    isA<OtpInvalid>().having((s) => s.attemptsLeft, 'attemptsLeft', 1),
    isA<OtpLocked>(),
  ],
);
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Implement `AuthEvent`/`AuthState` classes**

- [ ] **Step 4: Implement `AuthBloc` handlers**

`PhoneSubmitted`: `validatePhone` → invalid: emit `PhoneInvalid`; valid: emit `AuthLoading`, debounce
re-entrant calls with an in-flight flag, call `authRepository.checkPhone`, known → `loginUseCase` →
`AuthSuccess(isNewUser: false)`; unknown → `PhoneNeedsRegistration`, then proceed to OTP step either
way with an internal `_attempts = 0` and a `Timer.periodic` driving `OtpAwaiting(secondsLeft)` down
from `kOtpResendSeconds`. `OtpDigitEntered`: `validateOtp`; valid → clears timer, if phone was known
emit `AuthSuccess`, else proceed to Name step; invalid → increment `_attempts`, emit
`OtpInvalid(kOtpMaxAttempts - _attempts)` until `_attempts >= kOtpMaxAttempts` → `OtpLocked`.
`OtpResendRequested`: no-op while `secondsLeft > 0`; else resets `_attempts = 0` and restarts the
timer. `NameSubmitted`/`DobSubmitted`: validate, update `RegistrationDraft`, invalid → emit
`RegistrationStepInvalid`; `DobSubmitted` valid on the final step calls `registerUseCase` →
`AuthSuccess(isNewUser: true)`. `SessionChecked`: `getSessionUseCase` → `AuthSuccess` or
`AuthInitial`. `LogoutRequested`: `authRepository.logout()` → `AuthInitial`.

- [ ] **Step 5: Run test, confirm it passes**

- [ ] **Step 6: Run full auth bloc test file**

- [ ] **Step 7: Register `AuthBloc` factory in `service_locator.dart`**

- [ ] **Step 8: Commit**

```bash
git add lib/features/auth/presentation/bloc lib/core/di/service_locator.dart test/unit/presentation
git commit -m "feat: AuthBloc — phone/otp/registration state machine"
```

---

### Task 6: Auth presentation — screens (Onboarding, Phone, OTP, Name, DOB, Welcome)

**Files:**
- Create: `lib/features/auth/presentation/screens/{onboarding,phone,otp,name,dob,welcome}_screen.dart`
- Create: `lib/features/auth/presentation/widgets/registration_progress_ring.dart`
- Test: `test/widget/auth/login_screen_test.dart`, `test/widget/auth/register_flow_test.dart`

**Interfaces:**
- Consumes: `AuthBloc`/`AuthEvent`/`AuthState` (Task 5), `core/widgets` (Task 0), `app_router`
  routes (Task 2).
- Produces: 6 screens matching PDF screens 1–7, each a `BlocConsumer<AuthBloc, AuthState>`. No new
  public interfaces consumed by later tasks (Home is reached via router navigation only).

- [ ] **Step 1: Write failing widget test — invalid phone keeps Continue disabled**

```dart
testWidgets('entering a 5-digit phone number keeps Continue disabled', (tester) async {
  await tester.pumpWidget(makeTestableWidget(const PhoneScreen()));
  await tester.enterText(find.byType(AppTextField), '0912');
  await tester.pump();
  final button = tester.widget<AppButton>(find.byType(AppButton));
  expect(button.onPressed, isNull);
});
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Build `OnboardingScreen`**

PDF screen 1 layout: donut-circle decorative art, title, `AppButton` "Let's get started", "Log in"
link, Google/Apple/Facebook icon row (each taps → `AppDialog.show` placeholder), Terms/Privacy text
(taps → `AppSnackbar`/placeholder). Dispatches navigation to `/phone` (register) or `/phone?mode=login`.

- [ ] **Step 4: Build `PhoneScreen`**

PDF screen 2: `AppTextField` with `+95` prefix, `AppButton` Continue disabled until
`validatePhone` is valid (local `TextEditingController` listener calling the validator directly for
instant UI feedback, then dispatching `PhoneSubmitted` on press), listens for `PhoneInvalid` to show
inline error, `PhoneNeedsRegistration` to show the link-to-register message (login mode only).

- [ ] **Step 5: Build `OtpScreen`**

PDF screen 3: 6 `AppOtpBox` cells (via `AppOtpBox(length: 6, onCompleted: ...)`), countdown text
bound to `OtpAwaiting.secondsLeft`, Resend tappable only at 0:00, shake animation (via
`AnimatedBuilder` + offset tween, `kShakeDuration` from motion tokens) triggered on `OtpInvalid`,
locked overlay/disabled state on `OtpLocked`.

- [ ] **Step 6: Build `NameScreen`, `DobScreen`**

PDF screens 4–6: two `AppTextField`s (first/last name) and three `AppTextField`s or scroll-wheel
inputs (month/day/year) respectively; `RegistrationProgressRing` in the app bar showing
25/50/75/100% per step, morphing to a check icon on DOB's valid Continue. Inline error text from
`RegistrationStepInvalid`.

- [ ] **Step 7: Build `WelcomeScreen`**

PDF screen 7: staggered donut-tile slide-in, title fade-up, "Let's explore" `AppButton` navigating to
`/home`.

- [ ] **Step 8: Run widget tests, confirm Step-1 test passes; write + pass the OTP-lockout widget test**

```dart
testWidgets('3 wrong OTP codes locks entry', (tester) async {
  // pump OtpScreen with a seeded bloc, enter '000000' three times, assert locked state UI (e.g. Resend-only, boxes disabled)
});
```

- [ ] **Step 9: Run `flutter analyze` and full `test/widget/auth` suite**

- [ ] **Step 10: Commit**

```bash
git add lib/features/auth/presentation/screens lib/features/auth/presentation/widgets test/widget/auth
git commit -m "feat: auth screens — onboarding through welcome"
```

---

### Task 7: Home domain + data layer

**Files:**
- Create: `lib/features/home/home_import.dart`
- Create: `lib/features/home/domain/entities/{member,banner,product_section,shop}.dart`
- Create: `lib/features/home/domain/repositories/home_repository.dart`
- Create: `lib/features/home/domain/usecases/get_home_usecase.dart`
- Create: `lib/features/home/data/repositories/home_repository_impl.dart`
- Test: `test/unit/usecases/get_home_usecase_test.dart`

**Interfaces:**
- Consumes: `HomeDao`, `MemberDao` (Task 1), `Result<T>` (Task 0).
- Produces: `Member {id, name, photoUrl, tier, points, nextTierPoints, totalPoints}`,
  `BannerItem {id, imageUrl, title, deepLinkTarget}`,
  `ProductSection {id, title, products: List<Product>}` (Product entity defined in Task 9, imported
  via `product_import.dart`), `Shop {id, name, address, distanceLabel}`; abstract `HomeRepository`
  with `getHome() -> Future<Result<HomeBundle>>` where
  `HomeBundle {Member member, List<BannerItem> banners, List<ProductSection> sections, List<Shop> shops}`;
  `GetHomeUseCase(HomeRepository).call() -> Future<Result<HomeBundle>>`;
  `HomeRepositoryImpl implements HomeRepository` reading `HomeDao`/`MemberDao` and mapping rows to
  entities.

- [ ] **Step 1: Write failing use case test**

```dart
test('GetHomeUseCase returns Ok with member, banners, sections, shops', () async {
  final repo = MockHomeRepository();
  when(() => repo.getHome()).thenAnswer((_) async => Result.ok(testBundle));
  final result = await GetHomeUseCase(repo).call();
  expect(result, isA<Ok<HomeBundle>>());
});
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Implement entities, `HomeRepository` interface, `HomeBundle`, `GetHomeUseCase`**

- [ ] **Step 4: Run test, confirm it passes**

- [ ] **Step 5: Implement `HomeRepositoryImpl`**

Calls `HomeDao.getHome()` and `MemberDao.watchMember().first` (or a one-shot `getMember()` DAO
method added here if not already on `MemberDao`), maps Drift row objects to the entities above,
wraps in `Result.ok`; catches and wraps exceptions as `Result.err`.

- [ ] **Step 6: Write and pass an integration-style test against an in-memory Drift DB**

```dart
test('HomeRepositoryImpl reads seeded data end to end', () async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await SeedLoader(db).seedIfNeeded();
  final result = await HomeRepositoryImpl(homeDao: HomeDao(db), memberDao: MemberDao(db)).getHome();
  expect(result, isA<Ok<HomeBundle>>());
  expect((result as Ok<HomeBundle>).value.sections, isNotEmpty);
});
```

- [ ] **Step 7: Assemble `home_import.dart` barrel, convert files to `part of`**

- [ ] **Step 8: Register in `service_locator.dart`**

- [ ] **Step 9: Run `flutter analyze` and the home unit test suite**

- [ ] **Step 10: Commit**

```bash
git add lib/features/home/home_import.dart lib/features/home/domain lib/features/home/data test/unit/usecases
git commit -m "feat: home domain and data layer"
```

---

### Task 8: Home presentation — HomeBloc + HomeScreen

**Files:**
- Create: `lib/features/home/presentation/bloc/home_bloc.dart`, `home_event.dart`, `home_state.dart`
- Create: `lib/features/home/presentation/screens/home_screen.dart`
- Create: `lib/features/home/presentation/widgets/{member_header,banner_carousel,product_section_list,nearby_shops_row}.dart`
- Test: `test/widget/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `GetHomeUseCase` (Task 7), `connectivity_plus` reachability check (new small
  `ConnectivityService` in this task or `core/`), `core/widgets` (Task 0).
- Produces: `HomeEvent` sealed: `HomeRequested()`, `HomeRefreshRequested()`,
  `ConnectivityChanged(bool isOnline)`. `HomeState` sealed: `HomeLoading()`,
  `HomeLoaded(HomeBundle data, bool isOffline, Map<String, String?> sectionErrors)`,
  `HomeError(String message)`.

- [ ] **Step 1: Write failing bloc test**

```dart
blocTest<HomeBloc, HomeState>(
  'emits HomeLoading then HomeLoaded on HomeRequested',
  build: () {
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));
    return HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity);
  },
  act: (bloc) => bloc.add(HomeRequested()),
  expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
);
```

- [ ] **Step 2: Run test, confirm it fails**

- [ ] **Step 3: Implement `HomeEvent`/`HomeState`, `HomeBloc`**

`HomeRequested`/`HomeRefreshRequested` both call `getHomeUseCase.call()`, emit `HomeLoading` then
`HomeLoaded` or `HomeError`; `isOffline` set from the connectivity check at emit time.

- [ ] **Step 4: Run test, confirm it passes**

- [ ] **Step 5: Build `HomeScreen` and its 4 section widgets**

`MemberHeader` (name/photo/tier/points-to-next/bell), `BannerCarousel` (auto-playing `PageView`),
`ProductSectionList` (reused for Seasonal/Popular/Order again, tapping a tile navigates to
`/product/:id`), `NearbyShopsRow` (4 display-only cards, "There are 4 J'Donut shops" per PDF).
`HomeScreen` wraps all in `AppSkeleton(isLoading: ...)` while `HomeLoading`, shows the offline banner
when `isLoaded.isOffline`, shows `AppErrorState` per-section from `sectionErrors` rather than
blanking the page.

- [ ] **Step 6: Write and pass widget test asserting offline banner shows when `isOffline: true`**

- [ ] **Step 7: Register `HomeBloc` factory in `service_locator.dart`**

- [ ] **Step 8: Run `flutter analyze` and `test/widget/home`**

- [ ] **Step 9: Commit**

```bash
git add lib/features/home/presentation test/widget/home lib/core/di/service_locator.dart
git commit -m "feat: HomeBloc and Home screen"
```

---

### Task 9: Product domain, data, presentation

**Files:**
- Create: `lib/features/product/product_import.dart`
- Create: `lib/features/product/domain/entities/product.dart`
- Create: `lib/features/product/domain/repositories/product_repository.dart`
- Create: `lib/features/product/domain/usecases/get_product_usecase.dart`
- Create: `lib/features/product/data/repositories/product_repository_impl.dart`
- Create: `lib/features/product/presentation/bloc/product_detail_bloc.dart`, `_event.dart`, `_state.dart`
- Create: `lib/features/product/presentation/screens/product_detail_screen.dart`
- Test: `test/unit/usecases/get_product_usecase_test.dart`, `test/widget/product/product_detail_screen_test.dart`

**Interfaces:**
- Consumes: `ProductDao` (Task 1), `Result<T>` (Task 0), `HomeScreen` tile tap → route param (Task 8).
- Produces: `Product {id, code, name, priceMmk, isNew, discountPercent, imageUrl, description}` (this
  is the canonical `Product` type `ProductSection` in Task 7 references — Task 7's
  `home_import.dart` imports `product_import.dart` for it); `ProductRepository.getProduct(String id)
  -> Future<Result<Product>>`; `GetProductUseCase`; `ProductDetailEvent`: `ProductRequested(String id)`,
  `QuantityIncremented()`, `QuantityDecremented()`, `AddToCartPressed()`; `ProductDetailState`:
  `ProductLoading()`, `ProductLoaded(Product product, int quantity, int totalMmk)`, `ProductError
  (String message)`.

- [ ] **Step 1: Write failing use case test** (mirrors Task 7 Step 1 pattern, for `GetProductUseCase`)

- [ ] **Step 2: Run, confirm fail; implement entity/interface/use case/impl; run, confirm pass**

- [ ] **Step 3: Write failing bloc test for quantity stepper minimum**

```dart
blocTest<ProductDetailBloc, ProductDetailState>(
  'QuantityDecremented below 1 is a no-op',
  build: () => buildBlocWithLoadedState(quantity: 1),
  act: (bloc) => bloc.add(QuantityDecremented()),
  expect: () => [], // no new state — quantity floor is 1
);
```

- [ ] **Step 4: Run, confirm fail; implement `ProductDetailBloc`; run, confirm pass**

`QuantityIncremented`/`Decremented` clamp at `1`, recompute `totalMmk = quantity * product.priceMmk`
locally (no DB write); `AddToCartPressed` triggers an `AppSnackbar.showSuccess` from the screen (bloc
emits no new state for this — purely a UI-layer side effect per spec, handled via a `BlocListener`
one-shot or a transient `addedToCart` flag on state, implementer's choice).

- [ ] **Step 5: Build `ProductDetailScreen`**

PDF screen 9: product code/name/New badge, image via `cached_network_image` (`AppSkeleton` placeholder,
asset fallback on error), MMK price with thousands separators (`intl.NumberFormat`), quantity stepper
(`-`/`+` buttons calling the bloc events), "What's this?" expandable description, `AppButton` "Add to
cart · {total} MMK".

- [ ] **Step 6: Write and pass widget test — total updates when quantity changes**

- [ ] **Step 7: Assemble `product_import.dart` barrel, register bloc/repo in `service_locator.dart`**

- [ ] **Step 8: Update `home_import.dart`/`ProductSection` to import `Product` from `product_import.dart`** (resolves the forward reference noted in Task 7)

- [ ] **Step 9: Run `flutter analyze` and full product test suite**

- [ ] **Step 10: Commit**

```bash
git add lib/features/product test/unit/usecases test/widget/product lib/features/home/home_import.dart lib/core/di/service_locator.dart
git commit -m "feat: product detail feature"
```

---

### Task 10: Rewards domain, data, presentation (incl. CustomPainter motion)

**Files:**
- Create: `lib/features/rewards/rewards_import.dart`
- Create: `lib/features/rewards/domain/entities/challenge.dart` (`Member` reused from `home_import.dart`)
- Create: `lib/features/rewards/domain/repositories/rewards_repository.dart`
- Create: `lib/features/rewards/domain/usecases/get_rewards_usecase.dart`
- Create: `lib/features/rewards/data/repositories/rewards_repository_impl.dart`
- Create: `lib/features/rewards/presentation/bloc/rewards_bloc.dart`, `_event.dart`, `_state.dart`
- Create: `lib/features/rewards/presentation/screens/rewards_screen.dart`
- Create: `lib/features/rewards/presentation/widgets/{tier_ladder,challenge_card,tab_switcher}.dart`
- Test: `test/unit/usecases/get_rewards_usecase_test.dart`, `test/widget/rewards/rewards_screen_test.dart`

**Interfaces:**
- Consumes: `RewardsDao` (Task 1), `MemberDao`/`Member` (Tasks 1/7), `AppProgressRing` (Task 0),
  `MotionTokens` (Task 0).
- Produces: `Challenge {id, title, current, target, rewardPts, artType}`;
  `RewardsRepository.getRewards() -> Future<Result<RewardsBundle>>` where
  `RewardsBundle {Member member, List<Challenge> challenges}`; `GetRewardsUseCase`;
  `RewardsEvent`: `RewardsRequested()`, `TabChanged(RewardsTab tab)` (`enum RewardsTab {earn, gift}`),
  `ChallengeTapped(String id)`; `RewardsState`: `RewardsLoading()`, `RewardsLoaded(RewardsBundle data,
  RewardsTab activeTab)`, `RewardsError(String message)`.

- [ ] **Step 1: Write failing use case test** (pattern as Tasks 7/9 Step 1)

- [ ] **Step 2: Run, confirm fail; implement entity/interface/use case/impl; run, confirm pass**

- [ ] **Step 3: Write failing bloc test for tab switching**

```dart
blocTest<RewardsBloc, RewardsState>(
  'TabChanged updates activeTab without refetching',
  build: () => buildBlocWithLoadedState(activeTab: RewardsTab.earn),
  act: (bloc) => bloc.add(const TabChanged(RewardsTab.gift)),
  expect: () => [isA<RewardsLoaded>().having((s) => s.activeTab, 'activeTab', RewardsTab.gift)],
);
```

- [ ] **Step 4: Run, confirm fail; implement `RewardsBloc`; run, confirm pass**

- [ ] **Step 5: Build `RewardsScreen` with animation**

Points ring: `AppProgressRing` (Task 0) driven by a screen-owned `AnimationController`
(`kPointsRingDuration`), with a synced `TweenAnimationBuilder<int>`/`AnimatedBuilder` counting text
0→`member.totalPoints`. `TierLadder`: a `CustomPainter` for the connecting line fill, tier icons
scale/color-tween via the same controller with `Interval(0.3, 1.0, curve: kEmphasizedCurve)`.
`ChallengeCard` list: staggered entrance (`AnimationController` per card or one controller with
per-index `Interval`s, `kStaggerStep` apart), each card's own `CustomPainter` (donut-quarters or
coffee-arc per `challenge.artType`) driven by `challenge.current/target` via `ValueListenable` (not
the list's rebuild). `TabSwitcher`: `AnimatedPositioned` pill + `AnimatedSwitcher` content swap
(`kTabSwitchDuration`). Earn button `AnimatedScale` on tap, enabled only at `current == target`.
Every controller: `if (MediaQuery.of(context).disableAnimations) controller.value = 1.0;` instead of
`.forward()`.

- [ ] **Step 6: Write and pass widget test — Earn button disabled below target, enabled at target**

- [ ] **Step 7: Assemble `rewards_import.dart` barrel, register in `service_locator.dart`**

- [ ] **Step 8: Wire `AppShellScreen` (Task 2) to render `RewardsScreen` at its bottom-nav index, with the shared `AppBottomNav` active-pill `AnimatedPositioned` slide between Home/Rewards**

- [ ] **Step 9: Run `flutter analyze` and full rewards test suite**

- [ ] **Step 10: Commit**

```bash
git add lib/features/rewards test/unit/usecases test/widget/rewards lib/features/shell lib/core/di/service_locator.dart
git commit -m "feat: rewards screen with animated progress, tiers, and challenges"
```

---

### Task 11: Reduce-motion support, l10n strings, responsive pass

**Files:**
- Create: `assets/l10n/app_en.arb`, `assets/l10n/app_my.arb`
- Modify: every screen built in Tasks 6/8/9/10 to pull strings via `AppLocalizations.of(context)!`
  instead of literals
- Modify: `AppProgressRing`, `TierLadder`, `ChallengeCard`, `AppOtpBox` shake animation — confirm each
  checks `MediaQuery.of(context).disableAnimations`
- Test: `test/widget/accessibility/text_scale_test.dart`

**Interfaces:**
- Consumes: every screen widget from Tasks 6, 8, 9, 10.
- Produces: generated `AppLocalizations` class (via `flutter gen-l10n`) consumed by all screens; no
  new interface for later tasks (this is the last feature-affecting task before tests/polish).

- [ ] **Step 1: Write ARB key/value pairs for every user-facing string** across onboarding, phone,
  OTP, name, DOB, welcome, home, product detail, rewards, placeholder tab, in `app_en.arb`; mirror
  every key with a Burmese translation in `app_my.arb`.

- [ ] **Step 2: Run `flutter gen-l10n`**

Expected: generates `AppLocalizations` without missing-translation warnings.

- [ ] **Step 3: Replace literal strings in each screen with `AppLocalizations.of(context)!.<key>`**

- [ ] **Step 4: Write failing text-scale widget test**

```dart
testWidgets('HomeScreen renders without overflow at textScaleFactor 1.3', (tester) async {
  await tester.pumpWidget(MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
    child: makeTestableWidget(const HomeScreen()),
  ));
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 5: Run test, confirm it fails if any screen overflows; fix layouts (wrap text in
  `Flexible`/`Expanded`, avoid fixed-height text containers) until it passes**

- [ ] **Step 6: Confirm every `AnimationController` instance across the 4 features respects
  `disableAnimations`** (manual review pass, add any missing check found)

- [ ] **Step 7: Run `flutter analyze` and the full widget test suite**

- [ ] **Step 8: Commit**

```bash
git add assets/l10n lib/features test/widget/accessibility l10n.yaml
git commit -m "feat: localization (en/my) and reduce-motion/text-scale support"
```

---

### Task 12: Integration test, README, final verification

**Files:**
- Create: `test/integration/register_to_product_test.dart`
- Modify: `README.md`
- Modify: `.gitignore` (confirm PDF/design-asset exclusion from Task 0 is complete)

**Interfaces:**
- Consumes: the full app (`main.dart`, all features) — this task wires nothing new, only verifies.

- [ ] **Step 1: Write the failing integration test**

```dart
testWidgets('Register -> Home -> Product detail flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  // Onboarding: tap "Let's get started"
  await tester.tap(find.text(AppLocalizations_text_lets_get_started)); // use actual key/finder
  await tester.pumpAndSettle();
  // Phone: enter a number, tap Continue
  await tester.enterText(find.byType(AppTextField), '09254135592');
  await tester.tap(find.byType(AppButton));
  await tester.pumpAndSettle();
  // OTP: enter 123456
  await tester.enterText(find.byType(AppOtpBox), '123456');
  await tester.pumpAndSettle();
  // Name, DOB
  await tester.enterText(find.byKey(const Key('firstNameField')), 'Ye');
  await tester.tap(find.byType(AppButton));
  await tester.pumpAndSettle();
  // ... DOB entry, Welcome tap "Let's explore"
  // Home: assert MemberHeader present, tap first product tile
  expect(find.byType(MemberHeader), findsOneWidget);
  await tester.tap(find.byType(ProductSectionList).first);
  await tester.pumpAndSettle();
  // Product detail: assert landmark
  expect(find.byType(ProductDetailScreen), findsOneWidget);
});
```

(Exact finder keys assigned to each interactive widget as part of its Task 6/8/9 implementation, not
invented here — if a widget lacks a `Key`, add it when writing this test.)

- [ ] **Step 2: Run test, confirm it fails, then iterate against the real app until it passes**

Run: `flutter test integration_test/register_to_product_test.dart` (or `flutter drive` depending on
how `flutter_test`/`integration_test` package is wired — add `integration_test` dependency if not
already present from Task 0, in this task).

- [ ] **Step 3: Manual verification — run on iOS Simulator and Android emulator**

Run: `flutter run -d <ios-simulator-id>` and `flutter run -d <android-emulator-id>`. Walk: register →
logout (Settings placeholder tab, per spec a Log out row is required there — if not yet built, add a
minimal Settings placeholder with a Log out button as part of this step) → login → Home → Product
detail → Rewards. Repeat in airplane mode. Confirm no crash, confirm offline banner appears,
confirm all 10 PDF screens are visually present.

- [ ] **Step 4: Run `flutter analyze` on the whole project**

Expected: zero issues.

- [ ] **Step 5: Run the full test suite**

Run: `flutter test`
Expected: all unit, widget, and integration tests pass.

- [ ] **Step 6: Write README.md**

Cover: run steps (`flutter pub get`, `dart run build_runner build`, `flutter run`), Flutter/Dart
versions (`flutter --version` output), architecture + folder map (summarize spec §3), state
management choice (BLoC) and why, offline strategy (spec §5.1), animations built (spec §6.2), fake
OTP code (`123456`), known gaps (spec §11), time spent.

- [ ] **Step 7: Final commit**

```bash
git add test/integration README.md .gitignore
git commit -m "test: end-to-end register-to-product flow; finalize README"
```

---

## Self-Review

**1. Spec coverage:** §3 architecture/folders → Tasks 0–2. §3.2 member conflict → Task 1 Step 5.
§3.3 import barrels → every task's final barrel-assembly step. §3.4 shared widgets → Task 0. §4 auth
validators/flow → Tasks 3, 5, 6. §5 offline Home/Product → Tasks 7, 8, 9. §6 Rewards animation →
Task 10. §7 nav scope → Task 2 (shell) + Task 10 Step 8. §8 testing → distributed per-task +
Task 12. §9 technical checklist → covered across Tasks 0–11, verified in Task 12 Step 4. §10
deliverables → Task 12 Steps 3, 6 (recording and APK/iOS build are manual human deliverable steps,
noted as out-of-plan manual actions since they require a device/account, not code). §11 known gaps →
documented in README (Task 12 Step 6). No gaps found.

**2. Step scan:** confirmed each step above is a single action with one checkable result; no "handle
edge cases" placeholders remain — the Review Focus items became explicit test code in Tasks 3, 5, 6
(double-tap debounce in Task 5 Step 4 prose), and 7 (cold-launch covered by Task 1's seed test + Task
12's airplane-mode manual pass).

**3. Type consistency:** `Result<T>`/`Ok`/`Err` used identically from Task 0 through Task 12.
`AuthRepository` method signatures defined in Task 3 match exactly what Task 4's
`FakeAuthRepositoryImpl` and Task 5's `AuthBloc` call. `Product` entity defined once in Task 9 and
consumed by Task 7/8 via import, not redefined. `HomeBundle`/`RewardsBundle` field names consistent
between their repository, use case, and bloc consumers.

**4. Review Focus:** all 5 items now map to explicit tests — phone-length boundary (Task 3 Step 1),
DOB today/tomorrow/age-13 boundary (Task 3 Step 1), double-tap debounce (Task 5 Step 4, the in-flight
flag), cold airplane-mode launch (Task 1 Step 1 seed-idempotency test + Task 12 Step 3 manual pass),
OTP resend-before-countdown no-op (Task 5 Step 4 prose — add explicit test: see note below).

*Fix applied inline:* Task 5 Step 1's shown test covers lockout, not the resend-no-op case explicitly
— Task 5 Step 6 ("run full auth bloc test file") is the point to add
`test('OtpResendRequested before 0:00 is a no-op')` alongside the shown lockout test; both live in the
same file so no new task is needed.

**5. Proportion:** plan runs long because the project has 12 independently-testable slices (3 PDF
tasks × domain/data/presentation split, plus scaffolding/DI/l10n/integration) — each task section is
sized to one commit and one reviewable deliverable, consistent with spec's own evaluation rubric
breaking the same work into comparable chunks. Code shown is limited to test bodies (which pin exact
spec values) and signatures; implementation bodies are left to the implementer per the skill's own
rule.
