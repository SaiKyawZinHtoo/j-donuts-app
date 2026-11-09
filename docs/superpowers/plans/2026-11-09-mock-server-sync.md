# Mock Server and Background Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `shelf` mock server and a real background refresh so Home updates the local Drift database from `/v1/*` without ever blocking or blanking the UI.

**Architecture:** UI keeps reading only Drift. A new `RemoteDataSource` (Dio) fetches four public resources with ETags; `SyncRepositoryImpl.refresh()` validates and replaces the public tables in one Drift transaction; `HomeBloc` calls it on launch, pull-to-refresh and offline-to-online, then re-reads the DB in place. No `API_BASE_URL` means no remote source and today's behaviour.

**Tech Stack:** Flutter 3.47 / Dart 3.13, flutter_bloc, get_it, drift, `dio` (new, app), `shelf` (new, dev only), talker_dio_logger (existing).

**Spec:** `docs/superpowers/specs/2026-11-09-mock-server-sync-design.md`

## Global Constraints

- Public data only: products, banners, sections (+ ordered `productIds`), shops. Member, auth, rewards stay local.
- Envelope: `{"data": ..., "error": ..., "meta": {...}}`; routes `GET /v1/products|banners|sections|shops`; 404 envelope `{"data": null, "error": {"code": "not_found", "message": ...}, "meta": {}}`.
- Dio: timeouts 5s, retry max 2 with backoff + jitter on network/5xx only, talker logging.
- `API_BASE_URL` via `String.fromEnvironment`; empty = no remote source registered.
- Sync writes: one Drift transaction; failure rolls back; ETag persisted only after commit. Keys in `Meta`: `sync.etag.<resource>`, `sync.lastSyncedAt`. No schema change, no migration.
- Refresh never emits `HomeLoading` and never shows an error on failure; old data stays.
- Domain layer has no Flutter/Drift imports; part-of-barrel convention (imports only in `*_import.dart`).
- `flutter analyze` must report no issues; all tests pass; durations/constants as named constants; no hard-coded colours.

## Review Focus

- Server returns HTTP 200 with a non-null `error` envelope: treat as failure, keep DB.
- Sections reference a `productId` not in products: skip that link, keep the section.
- Duplicate ids in one response: last wins, no crash, no partial write.
- Empty list for a resource (`data: []`): replaces the table with nothing only when the response is valid; `data: null` is invalid.
- Two refreshes at once (pull-to-refresh during connectivity flap): one request set, both callers get the same result.
- Transaction fails after ETag fetched: stored ETag must not advance (next refresh refetches).
- Response is not JSON / truncated: typed `invalid` failure, DB untouched.

---

### Task 1: Mock server

**Files:**
- Create: `tool/mock_server/lib/mock_handler.dart`, `tool/mock_server/bin/server.dart`
- Test: `test/mock_server/mock_handler_test.dart`
- Modify: `pubspec.yaml` (`shelf` under `dev_dependencies`)

**Interfaces:**
- Produces: `Handler buildHandler({required Map<String, String> seedJsonByResource, int delayMs = 0, double failRate = 0, Random? random})` in `mock_handler.dart` (keys `products|banners|sections|shops`, values raw JSON list strings). `server.dart` parses `--port` (default 8080), `--delay`, `--fail-rate`, reads `assets/seed/<resource>.json`, serves with `shelf_io`.

- [ ] **Step 1: Write failing tests** in `mock_handler_test.dart`: `/v1/products` returns 200 with `data.length == meta.count` and `error == null`; unknown path `/v1/nope` returns 404 with `error.code == 'not_found'` and `data == null`; first response carries an `etag` header, replaying it as `if-none-match` returns 304 with empty body; `failRate: 1.0` returns 503 with a non-null `error`; `delayMs: 50` takes at least 50ms.
- [ ] **Step 2: Run** `flutter test test/mock_server/mock_handler_test.dart` — expect FAIL (handler missing).
- [ ] **Step 3: Implement** `buildHandler` (ETag = quoted hex hash of the encoded body; compare against `if-none-match`) and `bin/server.dart`.
- [ ] **Step 4: Run** the test file — expect PASS; run `dart run tool/mock_server/bin/server.dart --port 8099` and `curl -i localhost:8099/v1/shops` to see an envelope with 4 items, then stop it.
- [ ] **Step 5: Commit** `feat: add shelf mock server for /v1 public data`.

### Task 2: Remote data source and DTO validation

**Files:**
- Create: `lib/data/remote/remote_data_source.dart`, `lib/data/remote/remote_dtos.dart`, `test/fixtures/v1_responses.dart` (shared fixture strings)
- Test: `test/unit/data/remote_data_source_test.dart`, `test/unit/data/remote_dtos_test.dart`
- Modify: `pubspec.yaml` (`dio`), `lib/features/home/home_import.dart` (import remote files)

**Interfaces:**
- Produces (in `remote_dtos.dart`): `sealed class SyncFailure { network, timeout, server(int status), invalid(String reason) }`; `class RemoteSnapshot { final List<ProductDto> products; final List<BannerDto> banners; final List<SectionDto> sections; final List<ShopDto> shops; final Map<String,String> etags; }` where each `*Dto` mirrors the seed JSON fields (`SectionDto.productIds: List<String>`); `RemoteSnapshot?` is represented per-resource as `FetchResult<T> { notModified | data(List<T>, String? etag) }`.
- Produces (in `remote_data_source.dart`): `class RemoteDataSource { RemoteDataSource(Dio dio); Future<Result<FetchResult<T>>> fetch<T>(String resource, T Function(Map<String,dynamic>) fromJson, {String? etag}); }` returning `Result.err` carrying a `SyncFailure`-typed message, plus `Dio buildDio(String baseUrl)` applying timeouts, retry interceptor and talker logging.

- [ ] **Step 1: Write failing tests** with a fake `HttpClientAdapter`: valid envelope parses to DTOs and returns the `etag` header; `304` returns `notModified`; non-null `error` on a 200 returns an invalid failure; `data: null` is invalid; malformed JSON is invalid; a 503 retries exactly twice then returns `server(503)`; a 404 does not retry; DTO validation skips a record missing `id` or with negative `priceMmk` and rejects a resource where every record is invalid; the shared fixture parses identically to the server handler's output (contract: feed `buildHandler` output into the parser).
- [ ] **Step 2: Run** both test files — expect FAIL.
- [ ] **Step 3: Implement** the DTOs with per-record validation (`Result`-style, log skipped records via talker), the retry interceptor (backoff `200ms * 2^n` plus jitter, only for connection errors/timeouts/5xx), and `fetch`.
- [ ] **Step 4: Run** both test files and `flutter analyze` — expect PASS / no issues.
- [ ] **Step 5: Commit** `feat: add Dio remote data source with envelope parsing and validation`.

### Task 3: Sync repository

**Files:**
- Create: `lib/features/home/domain/repositories/sync_repository.dart`, `lib/features/home/data/repositories/sync_repository_impl.dart`
- Test: `test/unit/data/sync_repository_impl_test.dart`
- Modify: `lib/features/home/home_import.dart` (parts), `lib/core/constants/app_constants.dart` (`kApiBaseUrl`)

**Interfaces:**
- Consumes: `RemoteDataSource.fetch`, `FetchResult`, DTOs (Task 2); `AppDatabase`, tables, `Meta`.
- Produces: `abstract class SyncRepository { Future<Result<SyncOutcome>> refresh(); Future<DateTime?> lastSyncedAt(); }` with `enum SyncOutcome { updated, notModified }`; `SyncRepositoryImpl({required RemoteDataSource remote, required AppDatabase db})`; `const String kApiBaseUrl = String.fromEnvironment('API_BASE_URL');` in `app_constants.dart`.

- [ ] **Step 1: Write failing tests** using in-memory Drift (`AppDatabase.forTesting`) and a fake remote: successful refresh replaces products, banners, sections, sections_products and shops and removes records the server dropped; all four `304` returns `notModified` and leaves tables untouched; a section link to an unknown product is skipped; duplicate ids: last wins; a throwing write (force a failure) rolls everything back and leaves the stored ETag unchanged; two concurrent `refresh()` calls trigger one remote call set (assert the fake's call count) and return the same outcome; `lastSyncedAt()` is set after `updated`/`notModified`, null before.
- [ ] **Step 2: Run** the test file — expect FAIL.
- [ ] **Step 3: Implement** `refresh()`: fetch four resources with stored ETags; if any resource failed return its failure with no writes; run one `db.transaction` that replaces tables for resources that returned data; write ETags and `sync.lastSyncedAt` inside that transaction; share an in-flight `Future` for single-flight.
- [ ] **Step 4: Run** the test file and `flutter analyze` — expect PASS / no issues.
- [ ] **Step 5: Commit** `feat: add transactional single-flight sync repository`.

### Task 4: HomeBloc, DI and UI wiring

**Files:**
- Modify: `lib/features/home/presentation/bloc/home_bloc.dart`, `home_event.dart` (if a new event is needed), `home_state.dart` (`lastSyncedAt: DateTime?` on `HomeLoaded`), `lib/features/home/presentation/screens/home_screen.dart` (pull-to-refresh keeps content; banner text), `lib/core/di/service_locator.dart`, `assets/l10n/app_en.arb` + `app_my.arb` (`offlineUpdatedAgo(minutes)`), regenerate l10n
- Test: `test/unit/presentation/home_bloc_test.dart` (extend), `test/widget/home/home_screen_test.dart` (extend)

**Interfaces:**
- Consumes: `SyncRepository` (Task 3). `HomeBloc` gains optional `SyncRepository? syncRepository` (null when `kApiBaseUrl` is empty, so tests and local-only builds are unchanged).
- Produces: `HomeLoaded(data, isOffline, {sectionErrors, lastSyncedAt})`.

- [ ] **Step 1: Write failing tests**: after the first `HomeLoaded`, a background refresh that returns `updated` emits a new `HomeLoaded` with no `HomeLoading` in between; a failed refresh emits nothing and keeps the last state; `ConnectivityChanged(false)` then `(true)` triggers exactly one refresh; `HomeRefreshRequested` (pull-to-refresh) triggers a refresh and never emits `HomeLoading` once data is loaded; with `syncRepository == null` behaviour is identical to today; widget test: offline banner shows "Updated N min ago" when `lastSyncedAt` is set.
- [ ] **Step 2: Run** both files — expect FAIL.
- [ ] **Step 3: Implement** the bloc changes (initial load still DB-only and first; refresh runs after it; re-read DB via `getHomeUseCase` and emit in place), the DI registration (register `RemoteDataSource`/`SyncRepository` only when `kApiBaseUrl` is non-empty and pass it to `HomeBloc`), the l10n strings and banner text.
- [ ] **Step 4: Run** `flutter gen-l10n`, the two test files, `flutter analyze`, then the full `flutter test` — expect PASS / no issues.
- [ ] **Step 5: Commit** `feat: refresh Home from the mock server in the background`.

### Task 5: Docs and CI

**Files:**
- Modify: `README.md`, `.github/workflows/ci.yml`

- [ ] **Step 1: Update README**: how to run the server (`dart run tool/mock_server/bin/server.dart`, flags), `--dart-define=API_BASE_URL` per target (Android emulator `http://10.0.2.2:8080`, iOS Simulator `http://localhost:8080`, device `http://<LAN-IP>:8080`), the new offline/sync strategy replacing the "no-op hook" text, remove the pull-to-refresh-blanks known gap.
- [ ] **Step 2: CI**: add `dart pub get` if needed; server tests already run under `flutter test`; confirm the workflow still passes locally with `flutter analyze && flutter test`.
- [ ] **Step 3: Manual check** (documented, not automated): run the server, launch with `--dart-define=API_BASE_URL=http://localhost:8080`, edit a product price in the server's served JSON, pull to refresh, then stop the server and confirm Home keeps the data.
- [ ] **Step 4: Commit** `docs: document mock server and sync strategy`.
