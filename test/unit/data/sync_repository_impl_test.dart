import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/seed/seed_loader.dart';
import 'package:j_donuts_app/data/remote/remote_data_source.dart';
import 'package:j_donuts_app/data/remote/remote_dtos.dart';
import 'package:j_donuts_app/features/home/data/repositories/sync_repository_impl.dart';
import 'package:j_donuts_app/features/home/home_import.dart' show SyncOutcome;

class _FakeRemote implements RemoteDataSource {
  Map<String, Object?> responses = {};
  int calls = 0;
  Completer<void>? gate;
  final seenEtags = <String, String?>{};

  @override
  Future<Result<FetchResult<T>>> fetch<T>(
    String resource,
    T? Function(Map<String, dynamic>) parse, {
    String? etag,
  }) async {
    calls++;
    seenEtags[resource] = etag;
    await gate?.future;
    final r = responses[resource];
    if (r is String) return Result.err(r);
    if (r == null) return Result.ok(NotModified<T>());
    final items = (r as List<Map<String, dynamic>>).map(parse).whereType<T>().toList();
    return Result.ok(FetchedData<T>(items, '"$resource-v"'));
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Map<String, dynamic> _p(String id, {int price = 100}) =>
    {'id': id, 'name': id, 'imageUrl': 'i', 'priceMmk': price};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late _FakeRemote remote;
  late SyncRepositoryImpl repo;
  final t0 = DateTime(2026, 1, 1);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedLoader(db).seedIfNeeded();
    remote = _FakeRemote();
    repo = SyncRepositoryImpl(remote: remote, db: db, now: () => t0);
  });
  tearDown(() => db.close());

  test('updated: replaces tables and drops records the server dropped', () async {
    remote.responses = {
      'products': [_p('a'), _p('b', price: 5)],
      'banners': <Map<String, dynamic>>[],
      'sections': [
        {'id': 's', 'title': 'S', 'productIds': ['b', 'a', 'ghost', 'b']},
      ],
      'shops': [{'id': 'h', 'name': 'n', 'address': 'a'}],
    };
    expect((await repo.refresh() as Ok).value, SyncOutcome.updated);
    expect((await db.select(db.products).get()).map((p) => p.id).toSet(), {'a', 'b'});
    expect(await db.select(db.banners).get(), isEmpty);
    expect(await db.select(db.shops).get(), hasLength(1));
    final links = await (db.select(db.sectionsProducts)..orderBy([(l) => OrderingTerm(expression: l.sortOrder)])).get();
    expect(links.map((l) => l.productId), ['b', 'a']);
    expect(await db.select(db.sections).get(), hasLength(1));
  });

  test('all 304 -> notModified and tables untouched', () async {
    final before = (await db.select(db.products).get()).length;
    expect((await repo.refresh() as Ok).value, SyncOutcome.notModified);
    expect(await db.select(db.products).get(), hasLength(before));
    expect(await repo.lastSyncedAt(), t0);
  });

  test('duplicate ids: last wins', () async {
    remote.responses = {'products': [_p('a', price: 1), _p('a', price: 2)]};
    await repo.refresh();
    final rows = await db.select(db.products).get();
    expect(rows, hasLength(1));
    expect(rows.single.priceMmk, 2);
  });

  test('failure keeps db, no lastSyncedAt', () async {
    remote.responses = {'products': [_p('a')], 'shops': 'server: 503'};
    final r = await repo.refresh();
    expect((r as Err).message, 'server: 503');
    expect(await db.select(db.products).get(), hasLength(8));
    expect(await repo.lastSyncedAt(), isNull);
  });

  test('write failure rolls back and etag does not advance', () async {
    await db.customStatement(
        "CREATE TRIGGER boom BEFORE INSERT ON shops BEGIN SELECT RAISE(ABORT,'boom'); END");
    remote.responses = {
      'products': [_p('a')],
      'shops': [{'id': 'h', 'name': 'n', 'address': 'a'}],
    };
    expect(await repo.refresh(), isA<Err>());
    expect(await db.select(db.products).get(), hasLength(8));
    await db.customStatement('DROP TRIGGER boom');
    await repo.refresh();
    expect(remote.seenEtags['products'], isNull);
  });

  test('etag is sent on the next refresh after success', () async {
    remote.responses = {'products': [_p('a')]};
    await repo.refresh();
    await repo.refresh();
    expect(remote.seenEtags['products'], '"products-v"');
  });

  test('concurrent refreshes share one run', () async {
    remote.gate = Completer<void>();
    final a = repo.refresh();
    final b = repo.refresh();
    remote.gate!.complete();
    await Future.wait([a, b]);
    expect(remote.calls, 4);
  });
}
