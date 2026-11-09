# J'Donuts

A Flutter implementation of the **J'Donuts customer app** code test: fake login and registration with
real validation (Task 1), an offline-first Home and Product detail (Task 2) and an animated Rewards
screen (Task 3), across the 10 designed screens. Everything runs on local data (Drift/SQLite seeded
from bundled JSON); the mock server is optional.

| | |
| --- | --- |
| **Fake OTP code** | **`123456`** (also shown as a demo "SMS" local notification) |
| **Flutter / Dart** | Flutter **3.47.7** (stable) / Dart **3.13.5** (`sdk: ^3.13.4` in `pubspec.yaml`) |
| **State management** | BLoC (`flutter_bloc`) |
| **Fonts** | Mija (headings, bold text, buttons) and Inter Display (body); see `assets/fonts/NOTICE.md` |
| **Platforms** | Android and iOS (profile-mode checks on a physical Android phone; iOS Simulator) |
| **App id / name** | Android `com.example.j_donuts_app`, iOS `com.example.jDonutsApp` / **J'Donuts** |

## Contents

1. [Run it](#1-run-it)
2. [Try the app](#2-try-the-app-demo-script)
3. [What is built](#3-what-is-built)
4. [Architecture and folder map](#4-architecture-and-folder-map)
5. [State management: why BLoC](#5-state-management-why-bloc)
6. [Offline strategy](#6-offline-strategy)
7. [Validation rules](#7-validation-rules)
8. [Animations](#8-animations)
9. [Performance: 60 fps on a real Android phone](#9-performance-60-fps-on-a-real-android-phone)
10. [Tests, lints and CI](#10-tests-lints-and-ci)
11. [Trying the mock server](#11-trying-the-mock-server)
12. [Build the deliverables](#12-build-the-deliverables)
13. [Design decisions and assumptions](#13-design-decisions-and-assumptions)
14. [Known gaps](#14-known-gaps)
15. [Time spent](#15-time-spent)

## 1. Run it

Prerequisites: Flutter 3.47.x (Dart 3.13.x), plus Android Studio/an emulator and/or Xcode with an iOS
Simulator. Check with `flutter doctor`.

```bash
git clone https://github.com/SaiKyawZinHtoo/j-donuts-app.git
cd j-donuts-app
flutter pub get
flutter run            # pick an emulator, simulator or device
```

That is all you need: the Drift (`*.g.dart`) files and the generated localizations (`lib/l10n`) are
committed, and `flutter run` / `flutter build` regenerate the localizations from `assets/l10n/*.arb`
(`generate: true`). Run the code generator only if you change a Drift table or DAO:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Other commands:

```bash
flutter analyze        # no issues
flutter test           # 266 tests (unit, widget, one integration flow)
```

The app starts with **no backend** (offline-first, local data only).

### Mock server in 30 seconds (optional)

The brief's optional mock API lives in `tool/mock_server/` (`shelf`, versioned `/v1/...`, response
envelope `{data, error, meta}`, ETag/`304`). Use two terminals:

```bash
# Terminal 1: start the server (keep it open; stop with Ctrl-C)
dart run tool/mock_server/bin/server.dart --port 8080
# prints: J'Donuts mock server on http://0.0.0.0:8080
```

```bash
# Terminal 2: run the app pointed at it
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080     # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080    # iOS Simulator
flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:8080 # real phone, same Wi-Fi
```

Quick check without the app: `curl http://localhost:8080/v1/products` returns `{"data":[...],"error":null,"meta":{...}}`.
Optional server flags: `--delay <ms>` (slow answers) and `--fail-rate <0..1>` (e.g. `1` makes every call answer 503).
In the app, pull Home down to refresh; the `flutter run` console shows `[http-request] [GET] .../v1/products`.
Full walkthrough, checks and troubleshooting: [Trying the mock server](#11-trying-the-mock-server).

## 2. Try the app (demo script)

1. First launch opens the splash, then **Onboarding** -> **Let's get started**.
2. **Phone**: type e.g. `912345678` (or `09254135592`; spaces, dashes, one leading `0` or a pasted
   `+95` are normalised to `+959...`). **Continue** stays disabled until the number is valid.
3. **OTP**: type or paste **`123456`**. A wrong code shakes and clears the boxes; three wrong codes
   lock entry until **Resend** (countdown from 5:00). On a phone the code also arrives as a local
   notification (Android 13+ asks for the notification permission; denying it changes nothing).
4. **Name** (first name required, last name optional), then **Date of birth** (month/day/year) ->
   **Welcome** -> **Let's explore** -> **Home**.
5. **Home**: banners, Seasonal specials / Popular / Order again, nearby shops; pull down to refresh.
   Tap a product for **Product detail** (quantity stepper, live total, **ADD TO CART**).
6. **Rewards** (bottom nav): points ring, tier ladder, Earn / Gift tabs, challenge cards.
7. **Settings** tab -> **Log out** returns to Onboarding. On Onboarding use **Log In** with the same
   number: Phone -> OTP -> Home. A number that never registered shows an inline message with a link to
   register. Relaunching while logged in opens Home; logged out opens Onboarding.
8. **Airplane mode**: after the first launch, Home, Product detail and Rewards all render offline, images
   included, with a small offline banner on Home.

Google, Apple and Facebook use the icons in `assets/icon/` (shared `SocialSignInButton`, SVG via
`flutter_svg`); they and Terms of Use / Privacy Policy show a "not implemented" placeholder dialog (no real
integration). Explore, Wallet and the other bottom-nav icons open a simple placeholder.

## 3. What is built

| # | Screen | Task | Notes |
| --- | --- | --- | --- |
| 1 | Onboarding | 1 | donut tiles, Let's get started, Log in, Google / Apple / Facebook placeholders |
| 2 | Phone number | 1 | fixed `+95` prefix, normalisation, ring at 25% |
| 3 | Verify number | 1 | 6 boxes (auto-advance, backspace, paste, numeric keyboard, autofill hint), 5:00 resend, shake, 3-attempt lock |
| 4-5 | Name (empty / filled) | 1 | first name required, last optional, Myanmar script allowed, no digits |
| 6 | Date of birth | 1 | real calendar date, not in the future, age >= 13; the ring becomes a check |
| 7 | Welcome | 2 | staggered donut tiles, title fade-up, Let's explore |
| 8 | Home | 2 | member header (tier, points to next tier, bell with count), banner carousel, three product sections, nearby shops, bottom nav, skeletons, per-section empty and error states |
| 9 | Product detail | 2 | code, name, price in MMK with thousands separators, New badge, image, "What's this?", quantity stepper, ADD TO CART with live total |
| 10 | Rewards | 3 | points ring, tier ladder, Earn / Gift tabs, challenge cards with progress art |

Also: splash with motion, login with the "register instead" link, log out, session kept across relaunch
(`flutter_secure_storage`), Burmese locale (bonus), optional mock server with background sync (bonus),
and a demo OTP notification.

One member record feeds every screen (Home and Rewards read the same local row, so tier and points
always agree).

## 4. Architecture and folder map

Clean architecture, **feature-first**, three layers per feature (presentation -> domain -> data). The
domain layer is pure Dart (no Flutter or Drift imports; checked with `grep` over `lib/features/*/domain`).

```
lib/
  main.dart                    entry: DI setup, seed, runApp
  core/
    theme/                     colors, spacing, text styles, motion tokens, AppTheme (design tokens)
    widgets/                   shared UI: AppButton, AppTextField, AppOtpBox, ProductCard,
                               SectionHeader, AppBottomNav, AuthScaffold, AppSkeleton, ...
    router/                    go_router config, auth redirect guard, page transitions
    di/                        get_it service locator
    result/                    Result<T> (typed failures, no swallowed exceptions)
    services/                  ConnectivityService, FakeSmsNotifier
    constants/                 named constants (fake OTP, age limit, resend seconds, ...)
  data/
    local/                     Drift database, tables, DAOs, SeedLoader (reads assets/seed once)
    remote/                    Dio client (timeouts, retry, logging) + sync for the optional server
  features/
    auth/                      onboarding, phone, OTP, name, DOB, welcome + AuthBloc
      domain/                  entities, AuthRepository interface, use cases, validators (pure functions)
      data/                    fake AuthRepository impl (1 s delay), local user store, secure session
      presentation/            screens, widgets, bloc
    home/                      member header, banners, product sections, shops
    product/                   product detail screen + bloc
    rewards/                   points ring, tier ladder, tabs, challenge cards
    shell/                     splash, bottom-nav shell, Settings (Log out), placeholder tabs
  l10n/                        generated localizations (source: assets/l10n/app_en.arb, app_my.arb)
assets/
  seed/                        products, banners, sections, shops, member JSON (loaded into Drift)
  images/seed/                 bundled images (offline first launch, placeholder/error fallback)
tool/mock_server/              optional shelf server (/v1/...)
test/                          unit/, widget/, integration/, mock_server/
integration_test/              on-device frame-timing test (see section 9)
```

- **Dependency injection**: `get_it` (`lib/core/di/service_locator.dart`); no service is created inside a widget.
- **Navigation**: `go_router` with an auth **redirect guard** (session -> Home, none -> Onboarding) and a
  `/product/:id` route; the bottom-nav shell hosts Home and Rewards.
- **Part-based barrels**: each feature has one `<feature>_import.dart` holding all imports; every other
  file in the feature is `part of` it, so there are no relative-import chains.
- **Models**: immutable `const` classes and Dart 3 **sealed** event/state classes (no codegen for models).
- **Errors**: use cases return `Result<T>`; every screen has loading, error and empty states.
- **Theme**: colours, type, spacing and motion are tokens (`lib/core/theme/`); widgets read tokens, not literals.
- **Text**: all strings live in ARB files (English + Burmese) through gen-l10n.
- **Typography**: font families are tokens too (`AppFonts`); `AppTextStyles` puts **Mija** on every heading, bold
  style and button label and **Inter Display** on body text and the app default. Widgets never name a font or
  a weight (a unit test enforces it).
- **Layout**: portrait phones 4.7-6.9 in; text scale up to 1.3 is covered by a widget test.

## 5. State management: why BLoC

BLoC (`flutter_bloc`) was chosen because this spec is mostly named states and transitions: loading /
loaded / error, OTP waiting / invalid / locked, four registration steps, quantity changes. Each screen
gets a bloc (`AuthBloc`, `HomeBloc`, `ProductDetailBloc`, `RewardsBloc`) with sealed events and states,
so the rules can be unit-tested by feeding events and asserting the state sequence without building a
widget (`bloc_test`). The explicit event log also keeps double-taps and the "3 wrong codes" lockout
simple to reason about. Riverpod would also have worked; BLoC's event/state split was the better fit
for validation-heavy flows.

## 6. Offline strategy

- **The UI reads only the local Drift database.** On first launch `SeedLoader` copies
  `assets/seed/*.json` into the tables inside one transaction. A seed-version marker (`'2'`, in the `Meta`
  table) makes re-runs no-ops; an install with an older marker has its seed tables wiped and reseeded
  while registered users are kept.
- Home, Product detail and Rewards all read through DAOs, never JSON or the network directly, so they
  work in airplane mode.
- **Images**: `AppSmartImage` uses `cached_network_image` (disk cache, placeholder, error widget) for
  URLs and `Image.asset` for the bundled seed images, so the first launch without network still shows images.
- **Connectivity**: `connectivity_plus` drives the Home offline banner ("You're offline. Updated N min
  ago."). When the network returns, Home refreshes in the background; pull-to-refresh does the same.
- **Optional server**: with `--dart-define=API_BASE_URL=...` the app refreshes the same database from the
  mock server (one transaction, ETags, timeouts, retry). Without it the app is local-only.
- **Session**: `flutter_secure_storage`; the registered users live in the local database.

## 7. Validation rules

Pure functions in `lib/features/auth/domain/validators/`, each with unit tests in `test/unit/validators/`.

| Field | Rule | When it fails |
| --- | --- | --- |
| Phone | after `+95`: strip spaces, dashes and one leading `0`; must be `9` + 7-9 digits (`09254135592` -> `+959254135592`) | Continue disabled; inline message when the field loses focus |
| OTP | 6 digits; `123456` passes (`kFakeOtpCode`) | boxes shake and clear, message under the boxes, 3 wrong codes (`kOtpMaxAttempts`) lock entry until Resend |
| OTP input | auto-advance, backspace goes back, paste fills all 6, numeric keyboard, autofill hint | - |
| Resend | countdown from 5:00 (`kOtpResendSeconds` = 300), active at 0:00, restarts | - |
| First name | required, 1-50 characters after trimming, letters/spaces/Myanmar script, no digits | inline message |
| Last name | optional, same character rules | inline message |
| Date of birth | real calendar date (no 31 April, 29 Feb only in leap years), not future, age >= 13 (`kMinAgeYears`) | inline message, Continue disabled |
| Every step | Continue shows a loading state during the 1 s fake call (`kFakeNetworkDelay`); a double tap sends one request | - |

Auth sits behind an `AuthRepository` interface with a fake implementation, so a real API can replace it
without touching the UI.

## 8. Animations

All durations and curves are named constants in `lib/core/theme/motion_tokens.dart`. Every animation
checks `MediaQuery.disableAnimationsOf` and shortens or skips itself (Reduce Motion). The only exception
is the platform-default push/pop timing of `/product/:id` (a `CupertinoPage`, kept so iOS edge-swipe back works).

| Where | What |
| --- | --- |
| Splash | logo pops in, donuts scatter and settle into the Onboarding layout, hands off to Onboarding or Home |
| Onboarding | donut circles drift in; title and buttons enter staggered |
| Registration steps | shared-axis transition (fade + 30 px slide); progress ring animates 25 -> 50 -> 75 -> 100% and morphs into the check |
| Inputs | animated focus/error borders; OTP boxes shake on a wrong code, error text fades in |
| Buttons | scale on press; Continue morphs into a spinner while loading |
| Welcome | rounded donut tiles slide in staggered, then the title fades up |
| Home | skeleton shimmer, sections enter staggered once, banner carousel autoplays |
| Product tile -> detail | section-scoped **Hero** on the product image (`product-<sectionId>-<productId>`); quantity number animates; description expands and collapses; price in the button animates |
| Tab switch | bottom-nav pill slides with its label; fade between tab contents |
| Rewards | points ring sweeps with a counter, tier ladder highlights, challenge cards enter staggered with progress art, Earn / Gift pill slides (replays each time the tab is shown) |


## 9. Performance: 60 fps on a real Android phone

**Method.** Flutter frame timing recorded on a real device in **profile mode** (never debug): a
`flutter drive` integration test (`integration_test/perf_test.dart`) drives the app and writes per-segment
build and raster frame times through `traceAction` + `TimelineSummary`.

- Device: Samsung Galaxy A17 (SM-A176B), 1080x2340, Impeller (Vulkan), display mode **60 Hz**
  (budget **16.7 ms** per frame; the phone also supports 90 Hz = 11.1 ms, not measured).
- A "missed" frame is one over the 16.7 ms budget on the UI (build) or raster thread.

| Segment | Frames | Avg build | Worst build | Build misses | Avg raster | Worst raster | Raster misses |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Splash -> Onboarding | 6 | 6.8 ms | 11.7 | 0 | 11.1 ms | 16.2 | 1 |
| Home entrance | 8 | 6.1 ms | 9.7 | 0 | 12.2 ms | 22.0 | 2 |
| Home scroll (3x down/up) | 90 | 4.9 ms | 18.3 | 3 | 7.0 ms | 18.4 | 3 |
| Pull to refresh | 55 | 1.9 ms | 8.1 | 0 | 6.6 ms | 11.9 | 0 |
| Product detail, 1st visit (Hero, +/-, description) | 30 | 7.2 ms | 25.0 | 4 | 7.4 ms | **43.0** | 1 |
| Product detail, 2nd visit | 31 | 7.0 ms | 26.3 | 4 | 5.4 ms | 9.2 | **0** |
| Bottom-nav tabs (5 taps) | 24 | 7.8 ms | 16.6 | 1 | 8.9 ms | 17.8 | 2 |

**Reading the results (honest summary).**

- Typical frames are well inside the budget (average build 2-8 ms, average raster 5-12 ms). Misses are a
  few isolated frames per segment, not sustained jank.
- The one large spike (43 ms raster) happens **only the first time** Product detail is drawn: the
  trace shows Impeller creating a Vulkan pipeline (`PipelineVK::Create`, about 40 ms). The second visit
  has no raster misses. Removing the description's `ShaderMask` and an `IntrinsicHeight` (done) did not
  remove it, so it is a one-off first-use cost.
- Build time still has about four 20-26 ms frames per Product detail visit (opening the page, data arriving,
  returning to Home). No single widget dominates (the per-widget trace is spread over text layout,
  semantics and images), and part of it is test overhead (the test pumps long gaps and runs with semantics on).
- **Not measured**: the registration steps, Welcome and Rewards on the phone, and 90 Hz. Numbers vary a few
  percent between runs. Treat this as evidence of "smooth with occasional first-use hitches", not a
  guarantee of zero dropped frames on every mid-range device.

**Reproduce.** The test starts from Home, so register one user on the device first (OTP `123456`):

```bash
flutter run --profile -d <device-id>        # register once, then stop it
flutter drive --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_test.dart --profile --no-dds --keep-app-running -d <device-id>
```

Results land in `build/*.timeline_summary.json` (`average_frame_build_time_millis`,
`worst_frame_rasterizer_time_millis`, `missed_frame_build_budget_count`, ...). For a manual check, open
DevTools -> Performance while the app runs in profile mode, or enable "Profile HWUI rendering" in the
phone's developer options.

## 10. Tests, lints and CI

| Kind | Where | What it covers |
| --- | --- | --- |
| Unit | `test/unit/` (22 files) | validators (every rule), use cases, repositories, blocs (`bloc_test`), seed loader, `Result`, router |
| Widget | `test/widget/` (23 files) | login and registration validation, OTP box, auth chrome, Home (sections, badges, offline banner, status-bar inset, bottom padding), Product detail (quantity, total, description, Hero, back), `ProductCard`, bottom nav, Welcome, Rewards, text scale 1.3, Reduce Motion |
| Integration | `test/integration/register_to_product_test.dart` | Register -> Home -> Product detail -> Rewards through the real app tree (also `test/mock_server/` for the server) |
| On-device | `integration_test/perf_test.dart` | frame timing, see section 9 |

```bash
flutter test                           # all 266 tests
flutter test test/unit/validators      # e.g. only the validators
flutter analyze                        # flutter_lints, clean
```

**CI** (`.github/workflows/ci.yml`) runs `flutter pub get`, the code generator, `flutter analyze` and
`flutter test` on every push and pull request.

## 11. Trying the mock server

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

## 12. Build the deliverables

```bash
# Android release APK -> build/app/outputs/flutter-apk/app-release.apk
flutter build apk --release

# iOS Simulator app (macOS + Xcode), zipped for sending
flutter build ios --simulator
cd build/ios/iphonesimulator && zip -r J-Donuts-simulator.zip Runner.app
```

Install and launch on a booted simulator with `xcrun simctl install booted Runner.app` and
`xcrun simctl launch booted com.example.jDonutsApp` (the iOS bundle id). For the Android emulator or a
phone, `adb install -r app-release.apk`. Both builds were checked from a fresh clone of this repository.

### Install and test the two builds (reviewer guide)

**Android `.apk`** (phone or emulator):

```bash
adb install -r J-Donuts-release.apk      # or drag the file onto an emulator
adb shell am start -n com.example.j_donuts_app/.MainActivity
```

On a phone you can also copy the file over and open it (allow "install unknown apps"). The release build is
signed with the standard Android debug key, which is fine for testing. Android 13+ asks once for the
notification permission (it only shows the demo OTP; "Don't allow" changes nothing, just type `123456`).
**Reset to a fresh install** (logs you out, clears local data): `adb shell pm clear com.example.j_donuts_app`.

**iOS Simulator `.app`** (macOS + Xcode; the zip is a simulator build, it will not run on a real iPhone):

```bash
unzip J-Donuts-ios-simulator.zip
xcrun simctl boot "iPhone 16"             # or open any simulator in Xcode / Simulator.app
xcrun simctl install booted Runner.app
xcrun simctl launch booted com.example.jDonutsApp
```

Or drag `Runner.app` onto an open Simulator window. **The iOS bundle id is `com.example.jDonutsApp`** (the
Android id is `com.example.j_donuts_app`), so use that one with `simctl launch`.
**Reset to a fresh install on iOS:** the session is stored with `flutter_secure_storage`, which lives in the
Keychain and survives deleting the app, so a re-installed app can open already logged in. If that
happens, either use **Settings -> Log out** in the app, or reset the simulator Keychain and reinstall:

```bash
xcrun simctl uninstall booted com.example.jDonutsApp
xcrun simctl keychain booted reset
xcrun simctl install booted Runner.app
```

A first install on a simulator that never ran the app always starts at Onboarding.

**Suggested check order (about 3 minutes):** Onboarding -> Let's get started -> phone `912345678` ->
OTP `123456` -> name -> date of birth -> Welcome -> Home -> open a product -> Rewards -> Settings ->
Log out -> Log In with the same number -> Home. Then switch on **airplane mode** and repeat Home, Product detail
and Rewards (they work offline; Home shows the offline banner). Relaunch the app while logged in (opens Home)
and after logging out (opens Onboarding). More detail in [section 2](#2-try-the-app-demo-script).

| Deliverable | Status |
| --- | --- |
| Public Git repository with readable commits | this repository |
| Release `.apk` and zipped simulator `.app` | built with the commands above |
| 2-4 minute screen recording (register, log out, log in, Home, Product detail, Rewards, then the same in airplane mode) | recorded separately |
| README (run, versions, architecture, folder map, state management, offline strategy, animations, fake OTP, known gaps, time spent) | this file |
| Optional: mock server and CI | `tool/mock_server/`, `.github/workflows/ci.yml` |

The design screenshots from the brief are **not** committed to this repository.

## 13. Design decisions and assumptions

- **One member record** for Home and Rewards (the brief's mock-ups disagree: Bronze / 1,290 points vs
  Silver / 500), so both screens read the same row. The seeded member is Bronze tier; after registering, Home shows the name you entered.
- **Fake auth is local**: registered users are stored in the local database; "log in" succeeds only for a
  number that registered on this device.
- **Seed data and images are local.** The seasonal box photos come from the public jdonuts.com site;
  other images are generated placeholders (see known gaps).
- **Bell count** is the number of unfinished challenges in the local database (`HomeRepositoryImpl`, `openChallenges`),
  so it comes from data, not from a widget constant. There is no real notification feature behind it.
- **Add to cart** gives visual feedback only (a persistent cart is a bonus in the brief).
- **Product detail back arrow** uses `Navigator.maybePop`, so it never throws when there is nothing to pop.
- **Impeller** is the renderer on both platforms; the iOS Simulator can show harmless ghosting on
  Onboarding that is a simulator artifact.
- **Package ids** keep the defaults (`com.example.j_donuts_app` on Android, `com.example.jDonutsApp` on iOS);
  only the display name is J'Donuts.

## 14. Known gaps

Stated plainly so nobody has to find them:

- **Visual fidelity is not pixel-verified.** Welcome and Home were checked by eye on an Android phone
  after the last changes; Product detail, Rewards and the bottom nav were checked mainly by widget tests.
  The iOS Simulator was not re-run after the latest UI work.
- **Placeholder art**: `shops_backdrop.png`, `shop_1.png`, `shop_2.png`, `banner_new_shop.png`,
  `banner_hot.png` and `member_avatar.png` are locally generated stand-ins (the public site has no such
  images). Replace the files under the same names for final art. The brand logo is small (120 px), so it looks soft.
- **Fonts**: **Mija** is a commercial typeface (Latinotype, all rights reserved). It is included only so this test
  builds and matches the designs; get your own licence before reusing it (`assets/fonts/NOTICE.md`). Only the
  Regular weight of Mija and Inter Display is bundled (no true Mija Bold file), so bold text is **faked** with
  four 0.35px text shadows in the text colour (`FauxBold`/`embolden()` in `lib/core/theme/text_styles.dart`).
  Bundle Mija Bold and delete the shadows to get the real weight. Neither font has Myanmar glyphs, so Burmese text uses the system Myanmar font.
- **Burmese strings** added during the UI passes were written by the author/assistant and are not yet
  reviewed by a native reader.
- **Connectivity** uses `connectivity_plus` only; there is **no active reachability probe** (a connected
  Wi-Fi with no internet still counts as online). Failed refreshes are retried and leave local data untouched.
- **Database migrations**: `schemaVersion` is 1 with an `onCreate` strategy. No upgrade path has been needed
  yet; data changes are versioned through the seed marker instead.
- **Performance gaps**: see section 9 (first-use 43 ms raster hitch on Product detail, a few 20-26 ms build
  frames, registration/Welcome/Rewards and 90 Hz not measured).
- **No persistent cart**, no real Google/Apple/Facebook login, Terms and Privacy are placeholders, and the
  fingerprint button on login shows a "not implemented" snackbar.
- The five auth routes use a custom shared-axis transition, so the iOS edge-swipe-back gesture is off there
  on purpose (it would skip the bloc's `BackRequested`). Android system back on OTP/Name/DOB also skips it.
- **iOS Keychain**: the stored session survives uninstalling the app on a simulator (see the reviewer guide in
  section 12 for the reset). A first install on a clean simulator or device is not affected.
- Translations cover the strings in the screens; a full copy audit of every string was not done.
- Domain purity (no Flutter/Drift imports in `domain/`) is a convention checked by `grep`, not enforced by a tool.

## 15. Time spent

About **2 days** in total. Roughly in order: the base build (auth with validators, offline Home and
Product detail, Rewards, DI/routing/tests), a second pass to match the designs (theme, gradient, splash,
onboarding, step transitions, progress ring), a third pass on Home, Product detail, bottom nav and Welcome,
the optional mock server with sync, an Android real-device performance pass, and this documentation.

AI coding assistance (Claude Code) was used throughout; the author reviews and can explain the code.
