# J Donuts

A Flutter app implementing the J Donuts PDF design spec: 6 auth screens, Home, Product detail,
Rewards, and 3 placeholder bottom-nav tabs, backed by a local Drift database seeded from bundled
JSON. See `docs/superpowers/specs/2026-11-08-j-donuts-app-design.md` for the full design spec and
`.superpowers/sdd/2026-11-08-j-donuts-app/` for the task-by-task implementation plan and progress log.

## Running it

```bash
flutter pub get
dart run build_runner build   # generates lib/data/local/database.g.dart (Drift) and l10n
flutter run
```

Built and verified with:

```
Flutter 3.47.7 • channel stable
Framework revision abaf9c5237 (2026-10-08)
Engine revision d8a2d6c768
Tools • Dart 3.13.5 • DevTools 2.60.0
```

The fake OTP code for registration/login is **`123456`** (`kFakeOtpCode` in
`lib/core/constants/app_constants.dart`).

## Architecture

Clean 3-layer split, presentation → domain → data, per feature (`auth`, `home`, `product`,
`rewards`), plus a `shell` feature for the bottom-nav scaffold:

```
lib/
  core/            theme, shared widgets (AppButton/AppTextField/AppOtpBox/...), constants,
                   Result<T> type, go_router config + auth redirect guard, get_it DI
  features/
    auth/          onboarding, phone, OTP, name, DOB, welcome screens + AuthBloc
    home/          member header, banner carousel, product section lists, nearby shops
    product/       product detail screen + bloc
    rewards/       points ring, tier ladder, challenge cards, Earn/Gift tabs
    shell/         5-tab bottom nav (Home/Rewards real; Explore/Wallet/Settings placeholders)
  data/local/      Drift database, tables, DAOs, SeedLoader (reads assets/seed/*.json once)
assets/
  seed/            products/banners/sections/shops/member JSON, loaded into Drift on first launch
  images/seed/     bundled product/banner/avatar images (offline fallback)
  l10n/            app_en.arb, app_my.arb (English + Burmese)
test/
  unit/, widget/   per-feature validator/usecase/bloc/widget tests
  integration/     register_to_product_test.dart (full app flow, see below)
```

Each feature is a `part`-based barrel (`<feature>_import.dart` holds every import; every other file
in the feature is `part of` it), so there are no relative-import chains and no feature reaches into
another feature's internals.

**State management: BLoC** (`flutter_bloc`). Chosen for explicit, testable state transitions per
screen (`AuthBloc`, `HomeBloc`, `ProductDetailBloc`, `RewardsBloc`) with sealed event/state classes —
a good fit for a spec with many named states (loading/loaded/error, OTP locked/invalid, registration
steps) that unit tests can drive directly without touching widgets.

**Offline strategy** (spec §5.1): the UI only ever reads the local Drift database. On first launch,
`SeedLoader` copies `assets/seed/*.json` into Drift tables once (a `seeded` flag guards re-runs,
verified idempotent under a cold/airplane-mode launch). Every subsequent read — Home, Product
detail, Rewards — goes through a DAO, never JSON or network directly. `connectivity_plus` reports
online/offline for the Home offline banner; "refresh from network when back online" is a documented
no-op hook since no mock server is in scope (see Known gaps).

**Animations** (spec §6.2), all durations/curves as named constants in
`core/theme/motion_tokens.dart`: the Rewards points ring sweep + synced number counter, tier-ladder
highlight with a staggered connecting-line fill, staggered challenge-card entrance with per-card
CustomPainter progress art, an animated pill under the active Earn/Gift tab, OTP shake-on-error,
button press/loading morphs, Welcome screen's staggered donut-tile slide-in, Home's skeleton shimmer,
and the shared bottom-nav pill slide. Every `AnimationController` checks
`MediaQuery.of(context).disableAnimations` and jumps to its end state instead of faking a reduced
animation.

## Testing

```bash
flutter analyze
flutter test                                              # full suite: unit + widget + integration
flutter test test/integration/register_to_product_test.dart   # just the end-to-end flow
```

The integration test (`integration_test` package, run via the normal `flutter test` runner — no
simulator/emulator needed) drives the real app widget tree through: onboarding → phone entry → OTP
(`123456`) → name → DOB → welcome → Home (asserts `MemberHeader`) → tap a product tile → Product
detail → back → Rewards tab. It stubs the three platform channels that have no implementation under
`flutter test` (`path_provider`, `flutter_secure_storage`, `connectivity_plus`) with minimal in-memory
fakes so the real `AppDatabase`/`SessionDataSource`/`ConnectivityService` code runs unmodified; the
fake auth layer's `kFakeNetworkDelay` (1s) means each step after a tap waits on real wall-clock time
rather than just pumping frames.

As part of this task, the bundled seed PNGs (`assets/images/seed/*.png`) were replaced — they were
66-byte stub files with invalid PNG data that failed to decode (confirmed with Pillow, not just a
test-environment artifact); they're now valid, decodable 1×1 placeholder PNGs. This would have failed
to render on a real device too, not only under `flutter test`.

Full suite: 68 tests, all passing; `flutter analyze` reports 11 pre-existing `info`-level style lints
(`prefer_initializing_formals`, `unnecessary_library_name`) from earlier tasks, no errors or warnings.

## Known gaps

From spec §11 plus items accumulated in the SDD progress log (`.superpowers/sdd/.../progress.md`),
none of which block the flows above:

- No real backend — local JSON seed into Drift is the full data source; "refresh from network when
  back online" is a documented no-op hook, not a real call.
- No persistent cart; Add to cart is visual-only feedback (spec marks this a bonus).
- No real OAuth/social login or Terms/Privacy content — placeholders per spec.
- A handful of deferred minors from earlier tasks: weak id generation in the fake auth datasource
  (acceptable for local-only/no-backend scope), rewards tier names are English-only (no l10n mapping
  yet), pull-to-refresh blanks content via `HomeLoading` instead of staying visible during refetch,
  no accessibility semantics on the product quantity stepper, and 11 `prefer_initializing_formals` /
  `unnecessary_library_name` style lints. None are required by the brief's test lists.
- `AppBottomNav`'s item list and `AppShellScreen`'s tab list aren't structurally linked (a length
  mismatch wouldn't be caught at compile time) — no current caller hits this.

## Manual deliverables not done here

This was implemented by a background coding agent without access to a real iOS Simulator, Android
emulator, or screen-recording tooling. The project owner still needs to:

- Run the app on a real iOS Simulator and Android emulator (`flutter run -d <device>`), including an
  airplane-mode cold launch, and visually confirm all 10 PDF screens.
- Build the release artifacts: an Android `.apk` and a zipped iOS Simulator `.app`.
- Record the 2–4 minute walkthrough video (register → logout → login → Home → Product detail →
  Rewards).

Everything else in Task 12 — the integration test, this README, `flutter analyze`, and the full
`flutter test` suite — has been done and verified above.

## Time and scope

This was the final task (12 of 12) of a 12-task incremental plan (scaffolding → auth → Home/Product →
Rewards/motion → localization/a11y → this task). Scope held to the brief: the integration test covers
one representative full path (register → Home → Product detail → Rewards) rather than every branch,
matching the per-task test lists already written in Tasks 3–11.
