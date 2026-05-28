import 'package:dio/dio.dart';
import '../../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    String message = err.message ?? 'An unexpected error occurred';

    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['message'] is String) {
        message = data['message'] as String;
      }
    }

    AppLogger.e(
      '${err.requestOptions.method} ${err.requestOptions.path} → $message',
      tag: 'HTTP',
      error: err,
      stack: err.stackTrace,
    );

    handler.next(err.copyWith(message: message));
  }
}
