import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

typedef AuthResult = ({AuthTokenModel token, UserModel user});

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final isEmail = _emailRegex.hasMatch(identifier);
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: isEmail
          ? {'email': identifier, 'password': password}
          : {'phone': identifier, 'password': password},
    );
    return _parseAuthResponse(res.data, ApiConstants.login);
  }

  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  }) async {
    await _dio.post<void>(
      ApiConstants.otpSend,
      data: {'identifier': identifier, 'purpose': purpose},
    );
  }

  Future<AuthResult> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.otpVerify,
      data: {'identifier': identifier, 'otp': otp},
    );
    return _parseAuthResponse(res.data, ApiConstants.otpVerify);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return _parseAuthResponse(res.data, ApiConstants.register);
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
    return UserModel.fromJson(_requireData(res.data, ApiConstants.me));
  }

  Future<void> forgotPassword({required String identifier}) async {
    await _dio.post<void>(
      ApiConstants.forgotPassword,
      data: {'identifier': identifier},
    );
  }

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      ApiConstants.resetPassword,
      data: {'identifier': identifier, 'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<void> logout() async {
    await _dio.post<void>(ApiConstants.logout);
  }

  static Map<String, dynamic> _requireData(
    Map<String, dynamic>? body,
    String endpoint,
  ) {
    if (body == null) {
      throw FormatException('Empty response from $endpoint');
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response shape from $endpoint');
    }
    return data;
  }

  AuthResult _parseAuthResponse(Map<String, dynamic>? body, String endpoint) {
    final data = _requireData(body, endpoint);
    final token = data['token'];
    final user = data['user'];
    if (token is! String) throw const FormatException('Missing token');
    if (user is! Map<String, dynamic>) throw const FormatException('Missing user');
    return (
      token: AuthTokenModel(
        token: token,
        refreshToken: data['refreshToken'] is String ? data['refreshToken'] as String : null,
        isNewUser: data['isNewUser'] as bool? ?? false,
      ),
      user: UserModel.fromJson(user),
    );
  }
}
