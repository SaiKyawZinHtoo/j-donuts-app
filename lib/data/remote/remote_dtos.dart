import 'package:j_donuts_app/data/local/seed/seed_keys.dart';

enum SyncFailureKind { network, timeout, server, invalid }

/// Why a sync attempt failed. Surfaced to callers as `Result.err(toString())`.
class SyncFailure {
  const SyncFailure(this.kind, [this.detail = '']);
  final SyncFailureKind kind;
  final String detail;

  @override
  String toString() => detail.isEmpty ? kind.name : '${kind.name}: $detail';
}

/// Outcome of fetching one resource.
sealed class FetchResult<T> {
  const FetchResult();
}

final class NotModified<T> extends FetchResult<T> {
  const NotModified();
}

final class FetchedData<T> extends FetchResult<T> {
  const FetchedData(this.items, this.etag);
  final List<T> items;
  final String? etag;
}

String? _str(Map<String, dynamic> j, String k) {
  final v = j[k];
  return v is String && v.isNotEmpty ? v : null;
}

int? _int(Map<String, dynamic> j, String k, {int min = 0}) {
  final v = j[k];
  return v is int && v >= min ? v : null;
}

class ProductDto {
  const ProductDto({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.discountPercent,
    required this.imageUrl,
    required this.description,
  });
  final String id, code, name, imageUrl, description;
  final int priceMmk, discountPercent;
  final bool isNew;

  /// Null when a required field is missing or invalid.
  static ProductDto? tryParse(Map<String, dynamic> j) {
    final id = _str(j, SeedKeys.id);
    final name = _str(j, SeedKeys.name);
    final image = _str(j, SeedKeys.imageUrl);
    final price = _int(j, SeedKeys.priceMmk);
    if (id == null || name == null || image == null || price == null) return null;
    return ProductDto(
      id: id,
      code: _str(j, SeedKeys.code) ?? id,
      name: name,
      priceMmk: price,
      isNew: j[SeedKeys.isNew] == true,
      discountPercent: _int(j, SeedKeys.discountPercent) ?? 0,
      imageUrl: image,
      description: j[SeedKeys.description] is String ? j[SeedKeys.description] as String : '',
    );
  }
}

class BannerDto {
  const BannerDto({required this.id, required this.imageUrl, required this.title, required this.deepLinkTarget});
  final String id, imageUrl, title, deepLinkTarget;

  static BannerDto? tryParse(Map<String, dynamic> j) {
    final id = _str(j, SeedKeys.id);
    final image = _str(j, SeedKeys.imageUrl);
    final title = _str(j, SeedKeys.title);
    if (id == null || image == null || title == null) return null;
    return BannerDto(
      id: id,
      imageUrl: image,
      title: title,
      deepLinkTarget: j[SeedKeys.deepLinkTarget] is String ? j[SeedKeys.deepLinkTarget] as String : '',
    );
  }
}

class SectionDto {
  const SectionDto({required this.id, required this.title, required this.productIds});
  final String id, title;
  final List<String> productIds;

  static SectionDto? tryParse(Map<String, dynamic> j) {
    final id = _str(j, SeedKeys.id);
    final title = _str(j, SeedKeys.title);
    final ids = j[SeedKeys.productIds];
    if (id == null || title == null || ids is! List) return null;
    return SectionDto(id: id, title: title, productIds: ids.whereType<String>().toList());
  }
}

class ShopDto {
  const ShopDto({required this.id, required this.name, required this.address, required this.distanceLabel});
  final String id, name, address, distanceLabel;

  static ShopDto? tryParse(Map<String, dynamic> j) {
    final id = _str(j, SeedKeys.id);
    final name = _str(j, SeedKeys.name);
    final address = _str(j, SeedKeys.address);
    if (id == null || name == null || address == null) return null;
    return ShopDto(
      id: id,
      name: name,
      address: address,
      distanceLabel: j[SeedKeys.distanceLabel] is String ? j[SeedKeys.distanceLabel] as String : '',
    );
  }
}
