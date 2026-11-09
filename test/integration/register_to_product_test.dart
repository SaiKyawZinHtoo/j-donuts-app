import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';
import 'package:j_donuts_app/main.dart' as app;

/// Types into the [TextField] that lives under the widget with [key] (our
/// custom AppTextField/AppOtpBox wrap a real TextField, and
/// WidgetTester.enterText needs the TextField itself, not its wrapper).
Future<void> _typeInto(WidgetTester tester, String key, String text) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );
  await tester.enterText(field.first, text);
}

/// The fake auth layer sleeps `kFakeNetworkDelay` (1s of real time, since
/// this live test binding doesn't fake the clock) before every bloc
/// response, so settling needs real wall-clock time to pass, not just
/// extra frames.
Future<void> _settleAfterFakeNetwork(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // No real device/plugin host is running under `flutter test`, so two of
  // the app's platform channels need a stand-in for this test run only:
  // path_provider (Drift db location, database.dart's _openConnection) and
  // flutter_secure_storage (session persistence) — both resolve to a
  // fresh, unauthenticated state.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        pathProviderChannel,
        (call) async =>
            Directory.systemTemp.createTempSync('j_donuts_test').path,
      );

  // A minimal in-memory fake: real enough for SessionDataSource's
  // read/write/delete round trip across the registration flow.
  final secureStore = <String, String>{};
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
        final args = (call.arguments as Map?) ?? {};
        final key = args['key'] as String?;
        switch (call.method) {
          case 'read':
            return secureStore[key];
          case 'write':
            secureStore[key!] = args['value'] as String;
            return null;
          case 'delete':
            secureStore.remove(key);
            return null;
          case 'readAll':
            return secureStore;
          case 'deleteAll':
            secureStore.clear();
            return null;
          case 'containsKey':
            return secureStore.containsKey(key);
          default:
            return null;
        }
      });

  // connectivity_plus: report "online" so Home/Rewards don't show the
  // offline banner path.
  const connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        connectivityChannel,
        (call) async => <String>['wifi'],
      );
  const connectivityEventChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity_status',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(connectivityEventChannel, (call) async => null);

  testWidgets('Register -> Home -> Product detail -> Rewards flow', (
    tester,
  ) async {
    await app.main();
    await tester.pump(const Duration(seconds: 3)); // past splash
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Onboarding -> Phone.
    await tester.tap(find.byKey(const Key('getStartedButton')));
    await _settleAfterFakeNetwork(tester);

    // Phone entry -> OTP.
    await _typeInto(tester, 'phoneNumberField', '92541355');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continueButton')));
    await _settleAfterFakeNetwork(tester);

    // OTP (fake code auto-submits once the 6th digit lands).
    await _typeInto(tester, 'otpInput', '123456');
    await _settleAfterFakeNetwork(tester);

    // Name -> DOB.
    await _typeInto(tester, 'firstNameField', 'Ye');
    await _typeInto(tester, 'lastNameField', 'Win');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continueButton')));
    await _settleAfterFakeNetwork(tester);

    // DOB (well over the 13-year minimum) -> Welcome.
    await tester.tap(find.byKey(const Key('dobMonthField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // default initial date is 18 years ago
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continueButton')));
    await _settleAfterFakeNetwork(tester);

    // Welcome -> Home.
    await tester.tap(find.byKey(const Key('letsExploreButton')));
    await _settleAfterFakeNetwork(tester);
    await _settleAfterFakeNetwork(tester);

    expect(find.byType(MemberHeader), findsOneWidget);

    // Home -> Product detail.
    await tester.tap(find.byKey(const Key('productTile_p_box_romance')).first);
    await _settleAfterFakeNetwork(tester);

    expect(find.byType(ProductDetailScreen), findsOneWidget);

    // Back to Home, then over to the Rewards tab.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await _settleAfterFakeNetwork(tester);
    await tester.tap(find.byIcon(Icons.workspace_premium_outlined));
    await _settleAfterFakeNetwork(tester);

    expect(find.byType(RewardsScreen), findsOneWidget);
  });
}
