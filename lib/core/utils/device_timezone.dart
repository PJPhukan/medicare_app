import 'package:flutter_timezone/flutter_timezone.dart';
import 'logger.dart';

/// Reads the device clock's IANA timezone (e.g. "Asia/Kolkata") from the OS —
/// no location permission involved. Cached per app session; falls back to UTC
/// if the platform channel fails so callers never have to handle errors.
class DeviceTimezone {
  DeviceTimezone._();

  static String? _cached;

  static Future<String> get() async {
    final cached = _cached;
    if (cached != null) return cached;
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      _cached = info.identifier;
    } catch (e, s) {
      AppLogger.e('Timezone lookup failed', tag: 'DeviceTimezone', error: e, stack: s);
      _cached = 'UTC';
    }
    return _cached!;
  }
}
