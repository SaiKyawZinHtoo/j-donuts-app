import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;

import '../lib/mock_handler.dart';

/// `dart run tool/mock_server/bin/server.dart [--port 8080] [--delay ms] [--fail-rate 0..1]`
Future<void> main(List<String> args) async {
  String opt(String name, String fallback) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : fallback;
  }

  final seed = {
    for (final r in ['products', 'banners', 'sections', 'shops'])
      r: File('assets/seed/$r.json').readAsStringSync(),
  };
  final handler = buildHandler(
    seedJsonByResource: seed,
    delayMs: int.parse(opt('delay', '0')),
    failRate: double.parse(opt('fail-rate', '0')),
  );
  final server = await io.serve(handler, InternetAddress.anyIPv4, int.parse(opt('port', '8080')));
  stdout.writeln('J\'Donuts mock server on http://${server.address.host}:${server.port}');
}
