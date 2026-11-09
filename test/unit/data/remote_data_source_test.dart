import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore_for_file: avoid_relative_lib_imports
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/remote/remote_data_source.dart';
import 'package:j_donuts_app/data/remote/remote_dtos.dart';

import '../../../tool/mock_server/lib/mock_handler.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) {
    calls++;
    return respond(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200, Map<String, List<String>>? headers}) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {
      'content-type': ['application/json'],
      ...?headers,
    });

RemoteDataSource _ds(_Adapter a) {
  final dio = Dio(BaseOptions(baseUrl: 'http://x', validateStatus: (_) => true))..httpClientAdapter = a;
  return RemoteDataSource(dio, retryBase: Duration.zero);
}

Map<String, dynamic> _shop(String id) => {'id': id, 'name': 'n', 'address': 'a'};
Map<String, dynamic> _env(Object? data) => {'data': data, 'error': null, 'meta': {}};

void main() {
  test('valid envelope parses and returns etag', () async {
    final a = _Adapter((_) async => _json(_env([_shop('1')]), headers: {'etag': ['"e1"']}));
    final r = await _ds(a).fetch('shops', ShopDto.tryParse);
    final data = (r as Ok<FetchResult<ShopDto>>).value as FetchedData<ShopDto>;
    expect(data.items.single.id, '1');
    expect(data.etag, '"e1"');
  });

  test('304 is notModified', () async {
    final a = _Adapter((_) async => ResponseBody.fromString('', 304));
    final r = await _ds(a).fetch('shops', ShopDto.tryParse, etag: '"e"');
    expect((r as Ok<FetchResult<ShopDto>>).value, isA<NotModified<ShopDto>>());
  });

  for (final c in {
    'error envelope on 200': {'data': [], 'error': {'code': 'x'}, 'meta': {}},
    'data null': _env(null),
    'not an object': [1, 2],
  }.entries) {
    test('invalid: ${c.key}', () async {
      final a = _Adapter((_) async => _json(c.value));
      final r = await _ds(a).fetch('shops', ShopDto.tryParse);
      expect((r as Err).message, startsWith('invalid'));
    });
  }

  test('malformed JSON is invalid', () async {
    final a = _Adapter((_) async => ResponseBody.fromString('{oops', 200,
        headers: {'content-type': ['application/json']}));
    final r = await _ds(a).fetch('shops', ShopDto.tryParse);
    expect((r as Err).message, startsWith('invalid'));
  });

  test('503 retries twice then server failure', () async {
    final a = _Adapter((_) async => _json({}, status: 503));
    final r = await _ds(a).fetch('shops', ShopDto.tryParse);
    expect(a.calls, 3);
    expect((r as Err).message, 'server: 503');
  });

  test('404 does not retry', () async {
    final a = _Adapter((_) async => _json({}, status: 404));
    await _ds(a).fetch('shops', ShopDto.tryParse);
    expect(a.calls, 1);
  });

  test('network error retries then fails as network', () async {
    final a = _Adapter((o) async => throw DioException.connectionError(requestOptions: o, reason: 'x'));
    final r = await _ds(a).fetch('shops', ShopDto.tryParse);
    expect(a.calls, 3);
    expect((r as Err).message, 'network');
  });

  test('invalid records skipped; all-invalid rejected; empty list ok', () async {
    var body = _env([_shop('1'), {'name': 'no id'}]);
    final a = _Adapter((_) async => _json(body));
    final ds = _ds(a);
    final r1 = await ds.fetch('shops', ShopDto.tryParse);
    expect(((r1 as Ok<FetchResult<ShopDto>>).value as FetchedData<ShopDto>).items, hasLength(1));
    body = _env([{'name': 'bad'}]);
    expect((await ds.fetch('shops', ShopDto.tryParse) as Err).message, startsWith('invalid'));
    body = _env([]);
    final r3 = await ds.fetch('shops', ShopDto.tryParse);
    expect(((r3 as Ok<FetchResult<ShopDto>>).value as FetchedData<ShopDto>).items, isEmpty);
  });

  test('product with negative price is skipped', () {
    expect(ProductDto.tryParse({'id': 'p', 'name': 'n', 'imageUrl': 'i', 'priceMmk': -1}), isNull);
  });

  test('contract: real server output parses with the client parsers', () async {
    final seed = {
      for (final r in ['products', 'banners', 'sections', 'shops']) r: await _read('assets/seed/$r.json'),
    };
    final handler = buildHandler(seedJsonByResource: seed);
    final a = _Adapter((o) async {
      final res = await handler(Request('GET', Uri.parse('http://x${o.path}')));
      return ResponseBody.fromString(await res.readAsString(), res.statusCode,
          headers: {'content-type': ['application/json']});
    });
    final ds = _ds(a);
    Future<int> count<T>(String r, T? Function(Map<String, dynamic>) p) async =>
        (((await ds.fetch<T>(r, p)) as Ok<FetchResult<T>>).value as FetchedData<T>).items.length;
    expect(await count('products', ProductDto.tryParse), 8);
    expect(await count('banners', BannerDto.tryParse), 2);
    expect(await count('sections', SectionDto.tryParse), 3);
    expect(await count('shops', ShopDto.tryParse), 4);
  });
}

Future<String> _read(String p) => File(p).readAsString();
