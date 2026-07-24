import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';

/// Transparent read-through cache for GET responses.
///
/// On every successful GET response the raw response body is stored in
/// SharedPreferences under a key derived from the full request URI.
/// When a subsequent GET request fails with a network error the interceptor
/// resolves it with the previously cached body so the app keeps working
/// offline.  Non-GET requests and non-network errors pass through unchanged.
class CacheInterceptor extends Interceptor {
  CacheInterceptor(this._prefs);
  final SharedPreferences _prefs;

  static const _prefix = 'api_cache:GET:';
  static const _indexKey = 'api_cache:index';
  // Keep the offline cache bounded — SharedPreferences rewrites its whole
  // backing file on every write, so unbounded growth makes every write (and
  // app startup) progressively slower.
  static const _maxEntries = 48;

  // ── Key helpers ─────────────────────────────────────────────────────────────

  String _key(RequestOptions opts) => '$_prefix${opts.uri}';

  /// Pre-compute the cache key for a given path without making a request.
  /// Used by SyncService to invalidate stale entries after a mutation syncs.
  /// Pass [queryParameters] to match a specific paginated/filtered response.
  static String keyFor(
    String baseUrl,
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final full = queryParameters != null
        ? uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, '$v')))
        : uri;
    return '$_prefix$full';
  }

  // ── Response: save to cache ──────────────────────────────────────────────────

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // Deliver the response first — the cache write must never delay the UI.
    handler.next(response);
    if (_isGet(response.requestOptions) && response.statusCode == 200) {
      _write(_key(response.requestOptions), response.data);
    }
  }

  Future<void> _write(String key, dynamic data) async {
    try {
      // Encoding large bodies is the expensive part — do it off the UI isolate.
      final body = await compute(jsonEncode, data);
      await _prefs.setString(key, body);
      _touch(key);
    } catch (e, s) {
      AppLogger.w('Cache write failed', error: e, stack: s);
    }
  }

  /// LRU bookkeeping: move [key] to the end of the index, evict the oldest
  /// entries beyond [_maxEntries].
  void _touch(String key) {
    final index = _prefs.getStringList(_indexKey)?.toList() ?? <String>[];
    index.remove(key);
    index.add(key);
    while (index.length > _maxEntries) {
      _prefs.remove(index.removeAt(0));
    }
    _prefs.setStringList(_indexKey, index);
  }

  // ── Error: serve cached response on network failure ───────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isNetworkError(err) && _isGet(err.requestOptions)) {
      final cached = _prefs.getString(_key(err.requestOptions));
      if (cached != null) {
        try {
          handler.resolve(Response(
            requestOptions: err.requestOptions,
            data: jsonDecode(cached),
            statusCode: 200,
            statusMessage: 'OK (offline cache)',
          ));
          return;
        } catch (_) {}
      }
    }
    handler.next(err);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  bool _isGet(RequestOptions opts) =>
      opts.method.toUpperCase() == 'GET';

  bool _isNetworkError(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError;
}
