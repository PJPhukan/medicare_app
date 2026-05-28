import 'dart:developer' as dev;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// App-wide structured logger. Silent in release builds.
///
/// Initialise once before runApp():
///   await AppLogger.init();
///
/// Set / clear the authenticated user:
///   AppLogger.setUser(userId);   // after login
///   AppLogger.setUser(null);     // after logout
///
/// Log anywhere:
///   AppLogger.i('Tab switched', tag: 'Nav');
///   AppLogger.e('Request failed', tag: 'API', error: e, stack: s);
abstract final class AppLogger {
  static String _device = 'Unknown Device';
  static String? _userId;
  static void Function(String type, {String? page, Map<String, dynamic>? meta, String? error})? _remoteTracker;

  // ── Initialisation ────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (kReleaseMode) return;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        _device = '${a.manufacturer} ${a.model}';
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        _device = i.name;
      } else {
        _device = Platform.operatingSystem;
      }
    } catch (_) {
      _device = Platform.operatingSystem;
    }
  }

  /// Wire up once at startup so events reach the admin activity log.
  static void setRemoteTracker(
    void Function(String type, {String? page, Map<String, dynamic>? meta, String? error}) fn,
  ) {
    _remoteTracker = fn;
  }

  /// Post a structured event to the backend (admin activity log).
  /// Fire-and-forget — never throws, never blocks UI.
  static void track(String type, {String? page, Map<String, dynamic>? meta, String? error}) {
    _remoteTracker?.call(type, page: page, meta: meta, error: error);
  }

  /// Call after login with the authenticated user's ID (UUID — not email/name).
  /// Call with null on logout.
  static void setUser(String? id) {
    if (kReleaseMode) return;
    _userId = id;
    final action = id != null ? 'User context set → uid:$id' : 'User context cleared';
    _emit(action, _Level.info, 'Logger', null, null);
  }

  // ── Log levels ────────────────────────────────────────────────────────────

  static void v(String msg, {String? tag, Object? error, StackTrace? stack}) =>
      _emit(msg, _Level.verbose, tag, error, stack);

  static void d(String msg, {String? tag, Object? error, StackTrace? stack}) =>
      _emit(msg, _Level.debug, tag, error, stack);

  static void i(String msg, {String? tag, Object? error, StackTrace? stack}) =>
      _emit(msg, _Level.info, tag, error, stack);

  static void w(String msg, {String? tag, Object? error, StackTrace? stack}) =>
      _emit(msg, _Level.warning, tag, error, stack);

  static void e(String msg, {String? tag, Object? error, StackTrace? stack}) =>
      _emit(msg, _Level.error, tag, error, stack);

  // ── Internal emit ─────────────────────────────────────────────────────────

  static void _emit(
    String msg,
    _Level level,
    String? tag,
    Object? error,
    StackTrace? stack,
  ) {
    if (kReleaseMode) return;
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';

    final uid = _userId != null ? ' [uid:${_userId!}]' : '';

    dev.log(
      '${level.emoji} [$time] [$_device]$uid $msg',
      name: tag ?? 'App',
      level: level.value,
      error: error,
      stackTrace: stack,
      time: now,
    );
  }
}

enum _Level {
  verbose(300, '🔍'),
  debug(500, '🐛'),
  info(800, 'ℹ️ '),
  warning(900, '⚠️ '),
  error(1000, '❌');

  const _Level(this.value, this.emoji);
  final int value;
  final String emoji;
}
