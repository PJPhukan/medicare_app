import '../entities/user_entity.dart';

typedef AuthSession = ({String token, UserEntity user, bool isNewUser});

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String identifier,
    required String password,
  });
  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  });
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String otp,
  });
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> forgotPassword({required String identifier});
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  });
  Future<UserEntity?> getCachedUser();
  Future<String?> getCachedToken();
  Future<void> logout();

  Future<String?> getOnboardingStep();
  Future<void> saveOnboardingStep(String step);
  Future<void> clearOnboardingStep();
}
