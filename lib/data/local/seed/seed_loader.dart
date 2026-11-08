import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database.dart';
import 'seed_keys.dart';

/// Populates [AppDatabase] from the bundled `assets/seed/*.json` fixtures on
/// first launch only. Every later read goes through a DAO -> Drift, never
/// through this loader or raw JSON again.
class SeedLoader {
  SeedLoader(this._db);

  final AppDatabase _db;

  Future<void> seedIfNeeded() async {
    final alreadySeeded = await _isSeeded();
    if (alreadySeeded) return;

    await _db.transaction(() async {
      await _seedProducts();
      await _seedBanners();
      await _seedSections();
      await _seedShops();
      await _seedMember();
      await _markSeeded();
    });
  }

  Future<bool> _isSeeded() async {
    final row = await (_db.select(_db.meta)
          ..where((m) => m.key.equals(SeedKeys.seededFlagKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> _markSeeded() async {
    await _db.into(_db.meta).insertOnConflictUpdate(
          MetaCompanion.insert(
            key: SeedKeys.seededFlagKey,
            value: 'true',
          ),
        );
  }

  Future<List<Map<String, dynamic>>> _loadJsonList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _loadJsonMap(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _seedProducts() async {
    final items = await _loadJsonList('assets/seed/products.json');
    await _db.batch((batch) {
      batch.insertAll(
        _db.products,
        items.map(
          (json) => ProductsCompanion.insert(
            id: json[SeedKeys.id] as String,
            code: json[SeedKeys.code] as String,
            name: json[SeedKeys.name] as String,
            priceMmk: json[SeedKeys.priceMmk] as int,
            isNew: Value(json[SeedKeys.isNew] as bool? ?? false),
            discountPercent: Value(json[SeedKeys.discountPercent] as int? ?? 0),
            imageUrl: json[SeedKeys.imageUrl] as String,
            description: Value(json[SeedKeys.description] as String? ?? ''),
          ),
        ),
      );
    });
  }

  Future<void> _seedBanners() async {
    final items = await _loadJsonList('assets/seed/banners.json');
    await _db.batch((batch) {
      batch.insertAll(
        _db.banners,
        items.map(
          (json) => BannersCompanion.insert(
            id: json[SeedKeys.id] as String,
            imageUrl: json[SeedKeys.imageUrl] as String,
            title: json[SeedKeys.title] as String,
            deepLinkTarget: Value(json[SeedKeys.deepLinkTarget] as String? ?? ''),
          ),
        ),
      );
    });
  }

  Future<void> _seedSections() async {
    final items = await _loadJsonList('assets/seed/sections.json');
    await _db.batch((batch) {
      batch.insertAll(
        _db.sections,
        items.map(
          (json) => SectionsCompanion.insert(
            id: json[SeedKeys.id] as String,
            title: json[SeedKeys.title] as String,
          ),
        ),
      );

      for (final json in items) {
        final sectionId = json[SeedKeys.id] as String;
        final productIds = (json[SeedKeys.productIds] as List<dynamic>)
            .cast<String>();
        for (var i = 0; i < productIds.length; i++) {
          batch.insert(
            _db.sectionsProducts,
            SectionsProductsCompanion.insert(
              sectionId: sectionId,
              productId: productIds[i],
              sortOrder: Value(i),
            ),
          );
        }
      }
    });
  }

  Future<void> _seedShops() async {
    final items = await _loadJsonList('assets/seed/shops.json');
    await _db.batch((batch) {
      batch.insertAll(
        _db.shops,
        items.map(
          (json) => ShopsCompanion.insert(
            id: json[SeedKeys.id] as String,
            name: json[SeedKeys.name] as String,
            address: json[SeedKeys.address] as String,
            distanceLabel: Value(json[SeedKeys.distanceLabel] as String? ?? ''),
          ),
        ),
      );
    });
  }

  Future<void> _seedMember() async {
    final json = await _loadJsonMap('assets/seed/member.json');
    final memberId = json[SeedKeys.id] as String;

    await _db.into(_db.member).insert(
          MemberCompanion.insert(
            id: memberId,
            name: json[SeedKeys.name] as String,
            photoUrl: Value(json[SeedKeys.photoUrl] as String? ?? ''),
            tier: json[SeedKeys.tier] as String,
            points: json[SeedKeys.points] as int,
            nextTierPoints: json[SeedKeys.nextTierPoints] as int,
            totalPoints: json[SeedKeys.totalPoints] as int,
          ),
        );

    final challengeItems =
        (json[SeedKeys.challenges] as List<dynamic>).cast<Map<String, dynamic>>();
    await _db.batch((batch) {
      batch.insertAll(
        _db.challenges,
        challengeItems.map(
          (c) => ChallengesCompanion.insert(
            id: c[SeedKeys.id] as String,
            memberId: memberId,
            title: c[SeedKeys.title] as String,
            current: c[SeedKeys.current] as int,
            target: c[SeedKeys.target] as int,
            rewardPts: c[SeedKeys.rewardPts] as int,
            artType: Value(c[SeedKeys.artType] as String? ?? ''),
          ),
        ),
      );
    });
  }
}
