import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';

const _kToken = 'auth_token';
const _kRefreshToken = 'refresh_token';

const _authPaths = [
  '/api/auth/login',
  '/api/auth/register',
  '/api/auth/refresh',
  '/api/auth/logout',
  '/api/auth/otp',
  '/api/auth/forgot-password',
  '/api/auth/reset-password',
];

/// On a 401, silently refreshes the access token using the stored refresh token
/// and retries the original request. Only if refresh fails (or there's no
/// refresh token) does it sign the user out via [_onSessionExpired].
///
/// QueuedInterceptor serializes error handling so concurrent 401s don't all
/// trigger their own refresh.
class RefreshInterceptor extends QueuedInterceptor {
  RefreshInterceptor(this._storage, this._onSessionExpired);

  final FlutterSecureStorage _storage;
  final void Function() _onSessionExpired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final isAuthPath = _authPaths.any(req.path.contains);
    final alreadyRetried = req.extra['__retried__'] == true;

    if (err.response?.statusCode != 401 || isAuthPath || alreadyRetried) {
      return handler.next(err);
    }

    // If a concurrent request already refreshed the token, just retry with it.
    final usedToken = (req.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    final currentToken = await _storage.read(key: _kToken);
    if (currentToken != null && currentToken.isNotEmpty && currentToken != usedToken) {
      try {
        return handler.resolve(await _retry(req, currentToken));
      } catch (_) {
        return handler.next(err);
      }
    }

    final refreshToken = await _storage.read(key: _kRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      _onSessionExpired();
      return handler.next(err);
    }

    try {
      final newToken = await _refresh(refreshToken);
      await _storage.write(key: _kToken, value: newToken);
      return handler.resolve(await _retry(req, newToken));
    } catch (_) {
      _onSessionExpired();
      return handler.next(err);
    }
  }

  Future<String> _refresh(String refreshToken) async {
    // Bare dio (no interceptors) so refreshing can't recurse through this one.
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final res = await dio.post<Map<String, dynamic>>(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );
    final token = res.data?['data']?['token'] as String?;
    if (token == null || token.isEmpty) throw Exception('No token in refresh response');
    return token;
  }

  Future<Response<dynamic>> _retry(RequestOptions req, String token) {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final headers = Map<String, dynamic>.from(req.headers)
      ..['Authorization'] = 'Bearer $token';
    return dio.request<dynamic>(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      cancelToken: req.cancelToken,
      options: Options(
        method: req.method,
        headers: headers,
        responseType: req.responseType,
        contentType: req.contentType,
        sendTimeout: req.sendTimeout,
        receiveTimeout: req.receiveTimeout,
        extra: {...req.extra, '__retried__': true},
      ),
    );
  }
}
