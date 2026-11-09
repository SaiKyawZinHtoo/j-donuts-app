# Mock server and background sync — design

Date: 2026-11-09. Status: awaiting review. Path: architectural.

## Goal
Add the brief's optional mock server (`/v1/...`, `{data, error, meta}` envelope) and make the
app's "refresh in the background when the network returns, and on pull-to-refresh" real. The local
Drift database stays the single source of truth for every screen; the server only refreshes it.

## Understanding
- Said by the user: add a mock server; make it the best version; it must keep working as it does now
  without a server.
- Assumed: "best" means the brief's offline-first quality (graded 20%), not extra features. Public
  data only (products, banners, sections, shops), as the brief states. Member, auth and rewards stay
  local.
- Success: Home refreshes from the server without showing a skeleton; a failed or invalid response
  leaves the old data on screen; no `API_BASE_URL` means today's local-only behaviour, unchanged.

## Non-goals
Pagination, auth on the server, push/websockets, background-fetch services, delta sync, write APIs
(cart), syncing member/auth/rewards.

## Server (`tool/mock_server/`)
- Dart `shelf`, `dev_dependencies` only. Entry `bin/server.dart`; reads `assets/seed/*.json`.
- Routes: `GET /v1/products`, `/v1/banners`, `/v1/sections`, `/v1/shops`. Response
  `{"data": [...], "error": null, "meta": {"count": n}}`. Unknown path: 404
  `{"data": null, "error": {"code": "not_found", "message": ...}, "meta": {}}`.
- `ETag` on every route (hash of the body); `If-None-Match` match returns `304` with no body.
- Flags: `--port` (default 8080), `--delay <ms>`, `--fail-rate <0..1>` (returns 503 envelope),
  for latency and failure demos.
- `/v1/sections` items keep the seed shape (`id`, `title`, `productIds` ordered). Image URLs are
  returned as stored (bundled asset paths today), so they still render offline.

## Client (data layer only)
- `dio` added to `dependencies`. `RemoteDataSource` (new, `lib/data/remote/`): base URL from
  `String.fromEnvironment('API_BASE_URL')`; empty means no remote source is registered. Timeouts 5s;
  retry max 2 with backoff and jitter on network/5xx only; talker logging interceptor
  (`talker_dio_logger` already a dependency). Parses the envelope into typed DTOs and returns
  `Result` with typed failures (network, timeout, server, invalid). No exception is swallowed.
- DTO validation at the trust boundary: id, name, price (>= 0), imageUrl required. An invalid
  record is skipped and logged; if every record of a resource is invalid the sync is rejected.
- `SyncRepository` (new, domain interface + data impl): `refresh()` fetches the four resources with
  stored ETags, then writes in **one Drift transaction**: replace products, banners, sections,
  sections_products and shops with the response (this also removes records the server dropped).
  `304` for a resource means keep its table untouched. Any failure rolls back and returns a typed
  failure. Single-flight: concurrent calls share one in-flight future.
- Metadata in the existing `Meta` table: `sync.etag.<resource>` and `sync.lastSyncedAt`.
  No schema change, so no migration.
- `HomeBloc` triggers `refresh()` on launch (after the first DB read renders), on pull-to-refresh,
  and on offline to online. On success it re-reads the DB and emits `HomeLoaded` in place (no
  `HomeLoading`). On failure it keeps the current data and shows no error. Pull-to-refresh keeps the
  current content visible while refreshing (this also fixes the known gap where it blanked).
- `HomeRepositoryImpl.getHome()` and `ProductRepositoryImpl` are unchanged: still DB-only.
- Offline banner shows "Updated N min ago" from `sync.lastSyncedAt` when known (existing banner, no
  new widget).

## Testing
- `RemoteDataSource`: envelope parse, error envelope, timeout, 304, retry only on 5xx.
- DTO validation: invalid record skipped, all-invalid rejected.
- `SyncRepository`: transaction replaces and removes records; failure leaves the DB unchanged;
  `304` keeps tables; single-flight.
- `HomeBloc`: refresh emits no `HomeLoading`; failure keeps old data; offline to online triggers it.
- Server handlers: envelope, 404, ETag/304, flags.
- Contract test: server response and client DTO parser share one fixture.
- `flutter analyze` clean; full suite green; CI runs the server tests too.

## Delivery
README: how to run the server, `--dart-define=API_BASE_URL` per target (Android emulator
`http://10.0.2.2:8080`, iOS Simulator `http://localhost:8080`, device `http://<LAN-IP>:8080`),
the new offline strategy, flags. Known limit: the real app-to-server link on a device is verified
by the user; here it is covered by tests against a local server.

## Risks
`dio` and `shelf` are new dependencies (one app, one dev-only). A replace-all write on every
successful refresh is acceptable at this data size; it would need delta sync at scale (a non-goal).
