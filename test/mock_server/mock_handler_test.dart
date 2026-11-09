import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

import '../../tool/mock_server/lib/mock_handler.dart';

const _seed = {
  'products': '[{"id":"a"},{"id":"b"}]',
  'banners': '[]',
  'sections': '[]',
  'shops': '[{"id":"s"}]',
};

Request _get(String path, {Map<String, String>? headers}) =>
    Request('GET', Uri.parse('http://x$path'), headers: headers);

void main() {
  test('200 envelope with count', () async {
    final res = await buildHandler(seedJsonByResource: _seed)(_get('/v1/products'));
    final json = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
    expect(res.statusCode, 200);
    expect((json['data'] as List).length, json['meta']['count']);
    expect(json['error'], isNull);
  });

  test('404 envelope', () async {
    final res = await buildHandler(seedJsonByResource: _seed)(_get('/v1/nope'));
    final json = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
    expect(res.statusCode, 404);
    expect(json['data'], isNull);
    expect(json['error']['code'], 'not_found');
  });

  test('etag replay returns 304', () async {
    final h = buildHandler(seedJsonByResource: _seed);
    final first = await h(_get('/v1/shops'));
    final etag = first.headers['etag']!;
    final second = await h(_get('/v1/shops', headers: {'if-none-match': etag}));
    expect(second.statusCode, 304);
    expect(await second.readAsString(), isEmpty);
  });

  test('fail rate 1 returns 503 error envelope', () async {
    final res = await buildHandler(seedJsonByResource: _seed, failRate: 1, random: Random(1))(_get('/v1/shops'));
    final json = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
    expect(res.statusCode, 503);
    expect(json['error'], isNotNull);
  });

  test('delay is applied', () async {
    final sw = Stopwatch()..start();
    await buildHandler(seedJsonByResource: _seed, delayMs: 50)(_get('/v1/shops'));
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(50));
  });
}
