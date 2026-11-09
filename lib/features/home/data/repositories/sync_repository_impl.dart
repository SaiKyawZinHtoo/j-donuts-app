import 'package:drift/drift.dart';

import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/remote/remote_data_source.dart';
import 'package:j_donuts_app/data/remote/remote_dtos.dart';
import 'package:j_donuts_app/features/home/home_import.dart'
    show SyncOutcome, SyncRepository;

const _lastSyncedKey = 'sync.lastSyncedAt';
String _etagKey(String resource) => 'sync.etag.$resource';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this._remote,
    required this._db,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final RemoteDataSource _remote;
  final AppDatabase _db;
  final DateTime Function() _now;
  Future<Result<SyncOutcome>>? _inFlight;

  @override
  Future<Result<SyncOutcome>> refresh() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  @override
  Future<DateTime?> lastSyncedAt() async {
    final ms = int.tryParse(await _meta(_lastSyncedKey) ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<String?> _meta(String key) async => (await (_db.select(
    _db.meta,
  )..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _setMeta(String key, String value) => _db
      .into(_db.meta)
      .insertOnConflictUpdate(MetaCompanion.insert(key: key, value: value));

  Future<Result<FetchResult<T>>> _get<T>(
    String r,
    T? Function(Map<String, dynamic>) p,
  ) async => _remote.fetch<T>(r, p, etag: await _meta(_etagKey(r)));

  Future<Result<SyncOutcome>> _run() async {
    try {
      final products = await _get('products', ProductDto.tryParse);
      final banners = await _get('banners', BannerDto.tryParse);
      final sections = await _get('sections', SectionDto.tryParse);
      final shops = await _get('shops', ShopDto.tryParse);

      for (final r in [products, banners, sections, shops]) {
        if (r is Err) return Result.err((r as Err).message);
      }
      final p = (products as Ok<FetchResult<ProductDto>>).value;
      final b = (banners as Ok<FetchResult<BannerDto>>).value;
      final s = (sections as Ok<FetchResult<SectionDto>>).value;
      final h = (shops as Ok<FetchResult<ShopDto>>).value;

      final changed = [p, b, s, h].any((r) => r is FetchedData);
      await _db.transaction(() async {
        if (p is FetchedData<ProductDto>) await _replaceProducts(p);
        if (b is FetchedData<BannerDto>) await _replaceBanners(b);
        if (s is FetchedData<SectionDto>) await _replaceSections(s);
        if (h is FetchedData<ShopDto>) await _replaceShops(h);
        await _setMeta(
          _lastSyncedKey,
          _now().millisecondsSinceEpoch.toString(),
        );
      });
      return Result.ok(changed ? SyncOutcome.updated : SyncOutcome.notModified);
    } catch (e) {
      return Result.err('invalid: write failed ($e)');
    }
  }

  Future<void> _saveEtag(String resource, String? etag) =>
      etag == null ? Future.value() : _setMeta(_etagKey(resource), etag);

  Future<void> _replaceProducts(FetchedData<ProductDto> d) async {
    await _db.delete(_db.products).go();
    for (final x in d.items) {
      await _db
          .into(_db.products)
          .insertOnConflictUpdate(
            ProductsCompanion.insert(
              id: x.id,
              code: x.code,
              name: x.name,
              priceMmk: x.priceMmk,
              isNew: Value(x.isNew),
              discountPercent: Value(x.discountPercent),
              imageUrl: x.imageUrl,
              description: Value(x.description),
            ),
          );
    }
    await _saveEtag('products', d.etag);
  }

  Future<void> _replaceBanners(FetchedData<BannerDto> d) async {
    await _db.delete(_db.banners).go();
    for (final x in d.items) {
      await _db
          .into(_db.banners)
          .insertOnConflictUpdate(
            BannersCompanion.insert(
              id: x.id,
              imageUrl: x.imageUrl,
              title: x.title,
              deepLinkTarget: Value(x.deepLinkTarget),
            ),
          );
    }
    await _saveEtag('banners', d.etag);
  }

  Future<void> _replaceShops(FetchedData<ShopDto> d) async {
    await _db.delete(_db.shops).go();
    for (final x in d.items) {
      await _db
          .into(_db.shops)
          .insertOnConflictUpdate(
            ShopsCompanion.insert(
              id: x.id,
              name: x.name,
              address: x.address,
              distanceLabel: Value(x.distanceLabel),
            ),
          );
    }
    await _saveEtag('shops', d.etag);
  }

  Future<void> _replaceSections(FetchedData<SectionDto> d) async {
    final known = (await _db.select(_db.products).get())
        .map((p) => p.id)
        .toSet();
    await _db.delete(_db.sectionsProducts).go();
    await _db.delete(_db.sections).go();
    for (final x in d.items) {
      await _db
          .into(_db.sections)
          .insertOnConflictUpdate(
            SectionsCompanion.insert(id: x.id, title: x.title),
          );
      final ids = x.productIds.where(known.contains).toSet().toList();
      for (var i = 0; i < ids.length; i++) {
        await _db
            .into(_db.sectionsProducts)
            .insertOnConflictUpdate(
              SectionsProductsCompanion.insert(
                sectionId: x.id,
                productId: ids[i],
                sortOrder: Value(i),
              ),
            );
      }
    }
    await _saveEtag('sections', d.etag);
  }
}
