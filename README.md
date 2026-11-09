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

To try the optional mock server and background sync, see [Trying the mock server](#trying-the-mock-server).

Built and verified with:

```
Flutter 3.47.5 • channel stable (framework 6a19cca564, 2026-09-17)
Dart 3.13.4 (stable) (Tue Sep 15 01:01:15 2026 -0700) on "macos_x64"
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
    home/          peach member header, banner carousel, product section lists (shared ProductCard), nearby shops
    product/       product detail screen + bloc
    rewards/       points ring, tier ladder, challenge cards, Earn/Gift tabs
    shell/         5-tab floating bottom nav (Home/Rewards real; Explore/Wallet/Settings placeholders)
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
`SeedLoader` copies `assets/seed/*.json` into Drift tables once (a seed version marker guards
re-runs, verified idempotent under a cold/airplane-mode launch). The marker is now `'2'`
(`SeedKeys.seedVersion`): an existing install with an older marker has its seed tables wiped and
reseeded, while auth users are kept. Every subsequent read — Home, Product
detail, Rewards — goes through a DAO, never JSON or network directly. `connectivity_plus` reports
online/offline for the Home offline banner. When `API_BASE_URL` is set, `HomeBloc` also refreshes the
database in the background (see **Mock server and sync**); without it the app is local-only.

**Mock server and sync**: an optional `shelf` server (`tool/mock_server/`) serves the public data
(`/v1/products|banners|sections|shops`). The app refreshes its local database from it in the
background; see [Trying the mock server](#trying-the-mock-server).

**Animations**: every duration/curve is a named constant in `lib/core/theme/motion_tokens.dart`, and
every animation honors Reduce Motion (`MediaQuery.disableAnimationsOf`) by jumping to its end state.
Exception: the `/product/:id` push/pop and its Hero flight use the platform-default `CupertinoPage`
timing, to keep iOS edge-swipe back.
Built:

- Splash: logo pops in, eight donuts scatter around it, then four settle into the Onboarding layout while the rest drift off; hands off to Onboarding (which skips its tile entrance) or Home.
- Onboarding: donut tiles drift in, title and button stagger in.
- Shared-axis step transitions (fade + 30px slide) on `/phone`, `/otp`, `/name`, `/dob`, `/welcome`.
- Registration progress ring animating 25 -> 50 -> 75 -> 100% and morphing to a check.
- `AppButton`: press-scale (`Listener`-driven) and Continue -> spinner loading morph.
- OTP shake on error, with each box's border easing to the error colour and the error text fading/sizing in (`kFieldStateDuration`); text fields use the theme's animated focus/error borders; Welcome tile stagger.
- Home: staggered section entrance (once, on first load); skeleton shimmer.
- Product detail: entrance (`kDetailEntrance`), quantity change (`kQtyChange`) and description
  expand/collapse with fade (`kDescriptionExpand`).
- Section-scoped Hero (tag `product-<sectionId>-<productId>`) from product tile to detail.
- Bottom-nav sliding pill (single-driver animation, icon + label inside the pill) and a fade between tab contents; Earn/Gift tab pill.
- Rewards entrance (replayed each time the tab is shown): points ring sweep + counter (starts when the tab becomes active), tier-ladder
  highlight, staggered challenge cards with per-card progress art, badge.
- Home banner autoplay.

## Trying the mock server

The app works fully **without** the server (offline-first, data from the bundled seed). The server is
the brief's optional mock API: when the app is started with `API_BASE_URL`, it refreshes the local
database from it on launch, on pull-to-refresh and when the network comes back. Pick the path that
fits your machine.

### A. Nothing to install (1 minute): run the tests

```bash
flutter test test/unit/data/sync_repository_impl_test.dart test/unit/data/remote_data_source_test.dart test/mock_server
```

These prove the sync rules without a device: a refresh replaces the local data in one transaction
and rolls back on failure, an unchanged server answers `304` and writes nothing, concurrent refreshes
share one request set, invalid records are skipped, and the client parses exactly what the server
returns.

### B. Emulator or Simulator (5 minutes)

Terminal 1, start the server (keep it open; stop it with `Ctrl-C`, not `Ctrl-Z`):

```bash
dart run tool/mock_server/bin/server.dart --port 8080
```

Terminal 2, run the app with the server address:

| Target | Command |
| --- | --- |
| Android emulator | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080` |
| iOS Simulator | `flutter run --dart-define=API_BASE_URL=http://localhost:8080` |

### C. A real phone (10 minutes)

The phone and the computer must be on the same Wi-Fi. `localhost` does not work on a phone.

1. Start the server as in B.
2. Find the computer's address: `ipconfig getifaddr en0` (macOS; on Windows/Linux use `ipconfig` /
   `ip addr`). Below it is written as `<IP>`.
3. On the phone's browser open `http://<IP>:8080/v1/shops`. JSON means the phone can reach the server.
   If it does not load, fix the network or firewall first.
4. Run the app: `flutter run --dart-define=API_BASE_URL=http://<IP>:8080`

### What to check

Register or log in (OTP `123456`) and open Home. In the `flutter run` console the requests appear as
`[http-request] [GET] .../v1/products` and `[http-response] ... Status: 200`.

1. **Sync works**: all four resources (`products`, `banners`, `sections`, `shops`) return
   `Status: 200` with `"error": null`, and Home shows the products.
2. **Changed data arrives**: edit a product `name` in `assets/seed/products.json`, restart the
   server (it reads the file at start), then pull Home down to refresh. The new name appears and the
   skeleton does not come back. Undo with `git checkout assets/seed/products.json`.
3. **A dead server loses nothing**: stop the server and pull to refresh. After the ~5 s timeout and
   2 retries the old data is still on screen and no error is shown.
4. **Offline banner**: turn the network off. The red banner reads "You're offline. Updated N min ago."
   Turn it on (with the server running) and the data refreshes in the background.
5. **Failure and slowness**: start the server with `--fail-rate 1` (every call answers 503) or
   `--delay 800` (slow answers). The app stays usable and keeps its data.

### Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `Address already in use (errno = 48)` | An old server still holds port 8080 (often one stopped with `Ctrl-Z`). Find it with `lsof -nP -iTCP:8080 -sTCP:LISTEN`, `kill` that PID, or start with another `--port` and use the same port in `API_BASE_URL`. |
| `[http-error] ... receiveTimeout` | The server does not answer: it is not running, suspended, the IP is wrong, or the phone is on another network. Re-check step 3 of C. |
| Works in the phone browser but not in the app | The app was started without `--dart-define=API_BASE_URL=...`; restart it with the flag (a hot reload does not change it). |
| Nothing is requested at all | `API_BASE_URL` is empty, so the app runs local-only by design. |

### How it behaves

Reads always come from the local Drift database; the server only refreshes it. A refresh validates
each record (invalid ones are skipped and logged; a resource whose records are all invalid is
rejected), writes everything in one transaction, and stores each resource's ETag and the last sync
time in the `Meta` table, so a failed or partial refresh never leaves half-updated data. Requests use
a 5 s timeout and retry network errors and 5xx responses twice. Server flags:
`--port`, `--delay <ms>`, `--fail-rate <0..1>`.

## UI / theme

- `AppTheme` plus token files in `lib/core/theme/`: `colors.dart`, `spacing.dart`, `motion_tokens.dart`,
  `text_styles.dart`.
- `AppGradientBackground` paints the pink-to-white gradient (`AppColors.gradientColors` /
  `gradientStops`, stops `0, .3, .5, .7, 1`); used by `AuthScaffold`, Welcome and Onboarding.
- `AuthScaffold` (`lib/core/widgets/auth_scaffold.dart`): pinned header (back button + trailing),
  scrolling body, optional pinned `bottom` action that rises with the keyboard, legal footer hidden
  while the keyboard is open; `onBack`, `showFooter`, `titleGap` params.
- Phone field: fixed `+95` prefix (rendered as `prefixIcon` so it shows when unfocused); the user types
  the national number, and a leading `0` or pasted `+95` is accepted and normalized.
- `AppButton` is a pill; `AppProgressRing` / `RegistrationProgressRing` draw the rings.
- Splash is route `/splash` (the router's `initialLocation`).
- New tokens: `AppColors.badge` / `pageGrey` / `headerPeach`; card, section, header and welcome-layout
  tokens in `AppSpacing`; `MotionTokens.kQtyChange` / `kDescriptionExpand` / `kDetailEntrance`.
- Shared widgets in `lib/core/widgets`: `ProductCard` (`ProductCardImageMode.photo` / `cutout`) and
  `SectionHeader`.
- Home: peach `MemberHeader` (bell with count, points chip), banner cards overlapping the header,
  `SectionHeader` sections, a nearby-shops block over a backdrop image, and bottom padding that
  clears the floating nav. The bell count `2` is a constant, not real notifications.
- Bottom nav: floating, with border, shadow and a new icon set (`Icons.workspace_premium_outlined`
  crown for Explore, `Icons.radio_button_checked` for the centre Rewards tab). The shell uses
  `extendBody: true`.
- Product detail: grey page with a white card, an overlapping quantity pill, a "What's this?" row
  that fades/expands the description, and an `ADD TO CART | total` button (`AppButton.trailingLabel`).
  The loading and loaded states share one widget tree so the Hero stays stable; the back arrow uses
  `Navigator.maybePop`.
- Welcome: staggered rounded tile grid that bleeds off the screen edges with a bottom fade.
- Seed data: member is Hania (Bronze); seasonal box products added.
- Assets: `seasonal_1.png` / `seasonal_2.png` are real jdonuts.com photos. `shop_1.png`, `shop_2.png`,
  `banner_new_shop.png`, `banner_hot.png`, `shops_backdrop.png` and `member_avatar.png` are
  locally generated **placeholders** (the site has no such images); replace them by file name in
  `assets/images/seed/`.
- New Home/Product/Nav strings were written by the implementers in `app_my.arb` and need native
  Burmese review.

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
test-environment artifact); they're now valid, decodable 500×500 PNGs. This would have failed
to render on a real device too, not only under `flutter test`.

Full suite: 205 tests, all passing; `flutter analyze` reports no issues.

## Known gaps

From spec §11 plus items accumulated in the SDD progress log (`.superpowers/sdd/.../progress.md`),
none of which block the flows above:

- The backend is the local mock server only; member, auth and rewards data are never synced.
  Replace-all writes are fine at this data size but would need delta sync at scale.
- No persistent cart; Add to cart is visual-only feedback (spec marks this a bonus).
- No real OAuth/social login or Terms/Privacy content — placeholders per spec.
- A handful of deferred minors from earlier tasks: weak id generation in the fake auth datasource
  (acceptable for local-only/no-backend scope), rewards tier names are English-only (no l10n mapping
  yet), no accessibility semantics on the product quantity stepper,. None are required by the brief's test lists.
- The five auth routes use a custom shared-axis transition, so the iOS edge-swipe-back gesture does
  not work there (intentional: it would skip the bloc's `BackRequested` on OTP/Name/DOB). Android
  system back on OTP/Name/DOB also skips `BackRequested` (pre-existing, no `PopScope`).
- `AppBottomNav`'s item list and `AppShellScreen`'s tab list aren't structurally linked (a length
  mismatch wouldn't be caught at compile time) — no current caller hits this.
- Brand logo is only 120px (`assets/images/seed/brand_logo.png`) / 64px (`assets/icon/app_icon.png`),
  so the splash/onboarding logo looks soft; a 512px+ file is needed.
- Fingerprint button on login is visual only (shows a "not implemented" snackbar).
- Typeface is not matched to the reference font; the reference's 5th orange onboarding tile circle is
  not built; onboarding tiles under-overlap on small phones (375x667).
- Low contrast: phone hint text (~2:1) and inactive bottom-nav labels (70% white).
- `ChallengeCard`'s outer press-scale stacks with `AppButton`'s (0.9 x 0.97).
- `AuthScaffold.onBack` was added during implementation and is not in the original spec §6 list
  (spec updated).
- Impeller ghosting seen on Onboarding in some iOS simulators is a simulator artifact, not seen as an
  app bug.
- Translation is incomplete beyond tier names and the strings added in this pass — most user-facing
  copy only has an English/Myanmar pair for what earlier tasks and this review explicitly touched,
  not a full audit of every string in the app.
- The Home offline banner's `connectivity_plus` check is a coarse "any connection" reachability
  signal (no actual ping/HTTP check that the backend, if one existed, is reachable).
- `talker`/`talker_dio_logger` are dependencies but unused — no logging call sites exist yet.
- `BlocProvider` placement is inconsistent across features: `AuthBloc` is provided once for the whole
  auth `ShellRoute`, while `HomeBloc`/`RewardsBloc` are each created per-route in `app_router.dart`.
  Both work for the app's current navigation shape, but it's not a single consistent convention.
- Domain purity (no Flutter/Drift imports in `domain/`) is convention-only, not enforced by linting
  or a layer-boundary tool.
- Test coverage: the OTP lockout/resend and phone-normalization bloc paths added in this pass have
  unit tests; broader coverage (e.g. every `RegistrationStepInvalid` branch, `AppOtpBox`'s paste-fill
  edge cases) is not exhaustive.

- Home, Product detail, bottom nav and Welcome were verified by widget tests only, not compared
  visually against the reference on a device or simulator.
- Welcome tile shapes and photos only approximate the reference.
- The placeholder images listed under UI / theme are not final art.

## Deliverables status

- Mock server (optional bonus): included in `tool/mock_server/` with step-by-step checks in [Trying the mock server](#trying-the-mock-server); verified end to end on a physical Android device.
- Release Android build: `flutter build apk --release` (output `build/app/outputs/flutter-apk/app-release.apk`).
- iOS Simulator `.app` (`flutter build ios --simulator`, then zip `build/ios/iphonesimulator/Runner.app`)
  and the 2-4 minute screen recording (register, log out, log in, Home, Product detail, Rewards, then
  the same flow in airplane mode) are produced on a Mac with a device attached.
- CI: `.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on every push.
- Time spent: built incrementally in 12 planned tasks, followed by UI-fidelity passes (nav, Home,
  Welcome, Rewards, splash) and a requirements audit against the brief.
