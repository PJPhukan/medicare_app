import 'package:dio/dio.dart';
import '../../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    String message = err.message ?? 'An unexpected error occurred';

    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // For validation errors (422), prefer the first field-level message
        // over the generic "Validation failed" top-level message.
        if (response.statusCode == 422) {
          final errors = data['error'];
          if (errors is Map<String, dynamic>) {
            for (final fieldErrors in errors.values) {
              if (fieldErrors is List && fieldErrors.isNotEmpty) {
                message = fieldErrors.first.toString();
                break;
              }
            }
          }
        }
        // Fall back to top-level message if no field error was found.
        if (message == (err.message ?? 'An unexpected error occurred') &&
            data['message'] is String) {
          message = data['message'] as String;
        }
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
