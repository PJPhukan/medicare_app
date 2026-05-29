import 'package:dio/dio.dart';
import '../../utils/logger.dart';

const _redacted = '***';
const _sensitiveKeys = {'password', 'newPassword', 'confirmPassword', 'token', 'otp', 'secret'};

/// Logs a redacted version of the request body for debugging.
/// Always passes the ORIGINAL options forward — never mutates the data
/// that reaches the network.
class SanitizeInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    if (data is Map) {
      final sanitized = {
        for (final entry in data.entries)
          entry.key: _sensitiveKeys.contains(entry.key) ? _redacted : entry.value,
      };
      AppLogger.d(
        '${options.method} ${options.path} body: $sanitized',
        tag: 'HTTP',
      );
    }
    handler.next(options);
  }
}
