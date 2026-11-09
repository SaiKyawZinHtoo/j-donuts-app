part of '../core_import.dart';

/// Demo-only stand-in for the SMS a real backend would send: shows the OTP
/// as a local notification. Permission denied or any plugin failure is
/// swallowed -- the flow still works, the user just types 123456.
class FakeSmsNotifier {
  static const _channelId = 'fake_sms';
  static const _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;

  FakeSmsNotifier({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<bool> _init() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        false;
    return granted;
  }

  Future<void> showOtp(String code) async {
    try {
      if (!await (_ready ??= _init())) return;
      await _plugin.show(
        _notificationId,
        "J'Donuts",
        'Your verification code is $code',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Verification codes',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {
      // Demo helper only; never block auth on a notification failure.
    }
  }
}
