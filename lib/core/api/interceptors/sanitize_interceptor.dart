import 'package:dio/dio.dart';

const _redacted = '***';
const _sensitiveKeys = {'password', 'newPassword', 'confirmPassword', 'token', 'otp', 'secret'};

/// Redacts sensitive fields in request bodies before they reach PrettyDioLogger.
class SanitizeInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    if (data is Map) {
      options.data = {
        for (final entry in data.entries)
          entry.key: _sensitiveKeys.contains(entry.key) ? _redacted : entry.value,
      };
    }
    handler.next(options);
  }
}
