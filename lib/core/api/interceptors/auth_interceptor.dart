import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['requiresAuth'] == false) {
      handler.next(options);
      return;
    }

    if (!options.headers.containsKey('Authorization')) {
      try {
        final token = await TokenStore.read(_storage);
        if (token?.isNotEmpty ?? false) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
    }

    handler.next(options);
  }
}
