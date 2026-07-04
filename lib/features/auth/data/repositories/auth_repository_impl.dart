import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._local, this._remote);

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _remote.login(identifier: identifier, password: password);
    await _persistSession(result);
    return (token: result.token.token, user: result.user, isNewUser: result.token.isNewUser);
  }

  @override
  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  }) =>
      _remote.sendOtp(identifier: identifier, purpose: purpose);

  @override
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final result = await _remote.verifyOtp(identifier: identifier, otp: otp);
    await _persistSession(result);
    return (token: result.token.token, user: result.user, isNewUser: result.token.isNewUser);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final result = await _remote.register(name: name, email: email, phone: phone, password: password);
    await _persistSession(result);
    return (token: result.token.token, user: result.user, isNewUser: result.token.isNewUser);
  }

  Future<void> _persistSession(({AuthTokenModel token, UserModel user}) result) =>
      _local.saveSession(
        token: result.token.token,
        refreshToken: result.token.refreshToken,
        user: result.user,
      );

  @override
  Future<void> forgotPassword({required String identifier}) =>
      _remote.forgotPassword(identifier: identifier);

  @override
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) =>
      _remote.resetPassword(identifier: identifier, otp: otp, newPassword: newPassword);

  @override
  Future<UserEntity?> getCachedUser() async {
    final UserModel? model = await _local.readUser();
    return model;
  }

  @override
  Future<String?> getCachedToken() => _local.readToken();

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (e, s) {
      AppLogger.w('Remote logout failed', error: e, stack: s);
    }
    await _local.clearAuth();
  }

  @override
  Future<String?> getOnboardingStep() => _local.readOnboardingStep();

  @override
  Future<void> saveOnboardingStep(String step) => _local.saveOnboardingStep(step);

  @override
  Future<void> clearOnboardingStep() => _local.clearOnboardingStep();
}
