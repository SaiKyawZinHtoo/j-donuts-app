import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('typography tokens', () {
    test('headings, bold text and buttons use Mija', () {
      for (final style in [
        AppTextStyles.h1,
        AppTextStyles.h2,
        AppTextStyles.button,
        AppTextStyles.bannerTitle,
        AppTextStyles.bodyBold,
        AppTextStyles.captionBold,
      ]) {
        expect(style.fontFamily, AppFonts.heading);
      }
      expect(AppFonts.heading, 'Mija');
    });

    test(
      'body and caption use Inter Display, which is also the app default',
      () {
        expect(AppTextStyles.body.fontFamily, AppFonts.body);
        expect(AppTextStyles.caption.fontFamily, AppFonts.body);
        expect(AppFonts.body, 'InterDisplay');
        expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, AppFonts.body);
      },
    );

    test('bold styles are bold', () {
      expect(AppTextStyles.bodyBold.fontWeight, FontWeight.w700);
      expect(AppTextStyles.captionBold.fontWeight, FontWeight.w700);
    });
  });

  test('both font files exist and are declared in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    // The font entries must sit inside the top-level `flutter:` block, before
    // the next top-level key (flutter_launcher_icons), or they are not bundled.
    final start = pubspec.indexOf('\nflutter:\n');
    final end = pubspec.indexOf('\nflutter_launcher_icons:');
    final block = pubspec.substring(start, end);
    for (final (family, path) in [
      ('Mija', 'assets/fonts/Mija/Mija-Regular.otf'),
      ('InterDisplay', 'assets/fonts/InterDisplay/InterDisplay-Regular.otf'),
    ]) {
      expect(File(path).lengthSync(), greaterThan(10000), reason: path);
      expect(block, contains('family: $family'));
      expect(block, contains('asset: $path'));
    }
  });

  test('widgets never set a font family or weight themselves', () {
    final offenders = <String>[];
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final path = file.path;
      if (path.contains('lib/core/theme/') || path.contains('lib/l10n/')) {
        continue;
      }
      final text = file.readAsStringSync();
      if (text.contains('FontWeight.') || text.contains('fontFamily:')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: 'use AppTextStyles tokens instead');
  });
}
