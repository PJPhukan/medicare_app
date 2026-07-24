import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/token_store.dart';
import '../constants/api_constants.dart';

class EventLogService {
  EventLogService._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_TokenInterceptor());
  }

  late final Dio _dio;

  /// Fire-and-forget. Never throws. Sends events to the admin activity log.
  void track(String type, {String? page, Map<String, dynamic>? meta, String? error}) {
    _dio.post<void>(ApiConstants.events, data: {
      'type': type,
      if (page != null) 'page': page,
      if (meta != null) 'meta': meta,
      if (error != null) 'error': error,
    }).ignore();
  }
}

/// Reads the stored access token and attaches it if present.
/// Mirrors only the token-attach logic from AuthInterceptor — no retry, no redirect.
class _TokenInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStore.read(_storage);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

final eventLogServiceProvider = Provider<EventLogService>(
  (_) => EventLogService._(),
);
