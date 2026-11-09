import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:j_donuts_app/main.dart' as app;

/// On-device frame timing (run with --profile on a real device):
/// flutter drive --driver=test_driver/perf_driver.dart \
///   --target=integration_test/perf_test.dart --profile -d DEVICE_ID
/// Each traced segment writes build/NAME.timeline_summary.json.
Future<void> _waitFor(WidgetTester t, Finder f) async {
  for (var i = 0; i < 40 && f.evaluate().isEmpty; i++) {
    await t.pump(const Duration(milliseconds: 500));
  }
  if (f.evaluate().isEmpty) {
    final texts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    debugPrint('PERF_WAIT_TIMEOUT for $f; visible texts: $texts');
  }
}

Future<void> _settle(WidgetTester t) async {
  await t.pump(const Duration(seconds: 2)); // fake network delay is real time
  await t.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('frame timing across the main flow', (t) async {
    await binding.traceAction(() async {
      await app.main();
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle(const Duration(seconds: 1));
    }, reportKey: '01_splash_onboarding');

    // Registered user already persisted on the device: splash goes to Home.
    await _waitFor(t, find.byKey(const Key('homeScreen')));
    await binding.traceAction(() async {
      await t.pump(const Duration(seconds: 2)); // Home entrance stagger
      await t.pumpAndSettle();
    }, reportKey: '02_home_entrance');

    await _waitFor(t, find.byType(ListView));
    await binding.traceAction(() async {
      final list = find.byType(ListView).first;
      for (var i = 0; i < 3; i++) {
        await t.fling(list, const Offset(0, -600), 3000);
        await t.pumpAndSettle();
        await t.fling(list, const Offset(0, 600), 3000);
        await t.pumpAndSettle();
      }
    }, reportKey: '04_home_scroll');

    await binding.traceAction(() async {
      await t.fling(find.byType(ListView).first, const Offset(0, 500), 1000);
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
    }, reportKey: '05_home_pull_to_refresh');

    await _waitFor(t, find.byKey(const Key('productTile_p_box_romance')));
    await binding.traceAction(() async {
      await t.tap(find.byKey(const Key('productTile_p_box_romance')).first);
      await _settle(t);
      for (var i = 0; i < 4; i++) {
        await t.tap(find.byKey(const Key('quantityIncrement')));
        await t.pump(const Duration(milliseconds: 250));
      }
      await t.tap(find.byKey(const Key('descriptionToggle')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('descriptionToggle')));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.arrow_back));
      await _settle(t);
    }, reportKey: '06_product_cold_first_visit');

    // Second visit: pipelines and images are warm, so this is steady state.
    await _waitFor(t, find.byKey(const Key('productTile_p_box_romance')));
    await binding.traceAction(() async {
      await t.tap(find.byKey(const Key('productTile_p_box_romance')).first);
      await _settle(t);
      for (var i = 0; i < 4; i++) {
        await t.tap(find.byKey(const Key('quantityIncrement')));
        await t.pump(const Duration(milliseconds: 250));
      }
      await t.tap(find.byKey(const Key('descriptionToggle')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('descriptionToggle')));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.arrow_back));
      await _settle(t);
    }, reportKey: '06b_product_warm_second_visit');

    await binding.traceAction(() async {
      for (final icon in [
        Icons.workspace_premium_outlined,
        Icons.radio_button_checked,
        Icons.account_balance_wallet_outlined,
        Icons.settings_outlined,
        Icons.home_outlined,
      ]) {
        await t.tap(find.byIcon(icon).first);
        await t.pumpAndSettle();
      }
    }, reportKey: '07_nav_tabs');
  });
}
