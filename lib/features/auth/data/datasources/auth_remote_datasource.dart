import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({AuthTokenModel token, UserModel user})> login({
    required String identifier,
    required String password,
  }) async {
    final isEmail = identifier.contains('@');
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: isEmail
          ? {'email': identifier, 'password': password}
          : {'phone': identifier, 'password': password},
    );
    return _parseAuthResponse(res.data!);
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

  Future<({AuthTokenModel token, UserModel user})> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.otpVerify,
      data: {'identifier': identifier, 'otp': otp},
    );
    return _parseAuthResponse(res.data!);
  }

  Future<({AuthTokenModel token, UserModel user})> register({
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
    return _parseAuthResponse(res.data!);
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
    final data = res.data!['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> forgotPassword(String identifier) async {
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

  ({AuthTokenModel token, UserModel user}) _parseAuthResponse(
      Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>;
    return (
      token: AuthTokenModel(
        token: data['token'] as String,
        isNewUser: data['isNewUser'] as bool? ?? false,
      ),
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
