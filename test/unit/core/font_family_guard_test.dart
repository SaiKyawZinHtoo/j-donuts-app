import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no raw TextStyle( outside text_styles.dart', () {
    final bad = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.contains('lib/l10n') || f.path.endsWith('text_styles.dart')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'(?<![A-Za-z])TextStyle\(').hasMatch(lines[i])) {
          bad.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(bad, isEmpty, reason: 'use AppTextStyles.*.copyWith');
  });
}
