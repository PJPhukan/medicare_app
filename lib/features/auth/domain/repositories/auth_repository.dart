import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<({String token, UserEntity user, bool isNewUser})> login({
    required String identifier,
    required String password,
  });
  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  });
  Future<({String token, UserEntity user, bool isNewUser})> verifyOtp({
    required String identifier,
    required String otp,
  });
  Future<({String token, UserEntity user, bool isNewUser})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> forgotPassword(String identifier);
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  });
  Future<UserEntity?> getCachedUser();
  Future<String?> getCachedToken();
  Future<void> logout();
}
