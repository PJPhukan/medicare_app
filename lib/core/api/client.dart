import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../local_db/local_cache.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/sanitize_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'session_events.dart';

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(_secureStorageProvider);
  final prefs   = ref.read(sharedPreferencesProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    CacheInterceptor(prefs),
    RefreshInterceptor(storage, () => SessionEvents.instance.onUnauthorized?.call()),
    ErrorInterceptor(),
    if (kDebugMode) SanitizeInterceptor(),
    if (kDebugMode)
      PrettyDioLogger(
        requestHeader: true,
        requestBody: false, // body logged (redacted) by SanitizeInterceptor
        // Printing full response bodies stalls the UI isolate in debug runs
        // (large payloads are serialized and pushed through the console).
        // Flip to true temporarily when you need to inspect a payload.
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: true,
      ),
  ]);

  return dio;
});
