import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Thin Dart wrapper over the `com.curalee.sos` platform channel (Android).
///
/// Native side (MainActivity.kt + SosAlarmService.kt) owns:
/// - the looping siren on STREAM_ALARM inside a foreground service, so it keeps
///   sounding through silent mode / DND / app backgrounding / screen lock;
/// - direct (no-UI) SMS sending over raw cellular — works without data.
class SosNativeService {
  const SosNativeService();

  static const _channel = MethodChannel('com.curalee.sos');

  /// Starts the looping alarm siren via the native foreground service.
  /// Fully local — no network dependency. Loops until [stopAlarm].
  Future<bool> startAlarm() async {
    try {
      return await _channel.invokeMethod<bool>('startAlarmSound') ?? false;
    } on PlatformException catch (e) {
      AppLogger.e('startAlarmSound failed', tag: 'SOS', error: e);
      return false;
    }
  }

  Future<bool> stopAlarm() async {
    try {
      return await _channel.invokeMethod<bool>('stopAlarmSound') ?? false;
    } on PlatformException catch (e) {
      AppLogger.e('stopAlarmSound failed', tag: 'SOS', error: e);
      return false;
    }
  }

  Future<bool> isAlarmPlaying() async {
    try {
      return await _channel.invokeMethod<bool>('isAlarmPlaying') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Whether the device can send SMS at all (telephony hardware + SIM ready).
  /// False on WiFi-only tablets or when no SIM is inserted.
  Future<bool> hasSmsSupport() async {
    try {
      return await _channel.invokeMethod<bool>('hasSmsSupport') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Sends [message] to each phone number via raw cellular SMS (no internet
  /// needed). Requires SEND_SMS permission to already be granted.
  ///
  /// Returns phone → "sent" | `failed:<reason>`. "sent" means handed to the
  /// radio for delivery; with no signal the OS may still queue it.
  Future<Map<String, String>> sendSms({
    required List<String> phones,
    required String message,
  }) async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>(
        'sendSms',
        {'phones': phones, 'message': message},
      );
      return raw?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
    } on PlatformException catch (e) {
      AppLogger.e('sendSms failed', tag: 'SOS', error: e);
      return {for (final p in phones) p: 'failed:${e.message ?? e.code}'};
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system dialog asking to exempt the app from battery
  /// optimization, so OEMs are less likely to kill the alarm service.
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      return await _channel
              .invokeMethod<bool>('requestIgnoreBatteryOptimizations') ??
          false;
    } on PlatformException {
      return false;
    }
  }
}
