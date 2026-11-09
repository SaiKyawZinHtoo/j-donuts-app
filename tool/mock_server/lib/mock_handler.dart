import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';

const _resources = ['products', 'banners', 'sections', 'shops'];
const _jsonHeaders = {'content-type': 'application/json'};

/// Serves `GET /v1/<resource>` as `{data, error, meta}` with ETag/304.
/// [seedJsonByResource] maps a resource name to its raw JSON list text.
Handler buildHandler({
  required Map<String, String> seedJsonByResource,
  int delayMs = 0,
  double failRate = 0,
  Random? random,
}) {
  final rng = random ?? Random();
  return (Request request) async {
    if (delayMs > 0) await Future<void>.delayed(Duration(milliseconds: delayMs));
    final segments = request.url.pathSegments;
    final known = request.method == 'GET' &&
        segments.length == 2 &&
        segments[0] == 'v1' &&
        _resources.contains(segments[1]) &&
        seedJsonByResource.containsKey(segments[1]);
    if (!known) {
      return _envelope(404, null, {'code': 'not_found', 'message': 'No route'});
    }
    if (failRate > 0 && rng.nextDouble() < failRate) {
      return _envelope(503, null, {'code': 'unavailable', 'message': 'Simulated failure'});
    }
    final data = jsonDecode(seedJsonByResource[segments[1]]!) as List<dynamic>;
    final body = jsonEncode({
      'data': data,
      'error': null,
      'meta': {'count': data.length},
    });
    final etag = '"${body.hashCode.toRadixString(16)}"';
    if (request.headers['if-none-match'] == etag) {
      return Response(304, headers: {'etag': etag});
    }
    return Response.ok(body, headers: {..._jsonHeaders, 'etag': etag});
  };
}

Response _envelope(int status, Object? data, Map<String, String> error) =>
    Response(
      status,
      body: jsonEncode({'data': data, 'error': error, 'meta': <String, Object>{}}),
      headers: _jsonHeaders,
    );
