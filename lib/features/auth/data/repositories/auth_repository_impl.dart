import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._local, this._remote);

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;

  @override
  Future<({String token, UserEntity user, bool isNewUser})> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _remote.login(
      identifier: identifier,
      password: password,
    );
    await Future.wait([
      _local.saveToken(result.token.token),
      if (result.token.refreshToken != null)
        _local.saveRefreshToken(result.token.refreshToken!),
      _local.saveUser(result.user),
    ]);
    final UserEntity user = result.user;
    return (token: result.token.token, user: user, isNewUser: result.token.isNewUser);
  }

  @override
  Future<void> sendOtp({
    required String identifier,
    required String purpose,
  }) =>
      _remote.sendOtp(identifier: identifier, purpose: purpose);

  @override
  Future<({String token, UserEntity user, bool isNewUser})> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final result = await _remote.verifyOtp(
      identifier: identifier,
      otp: otp,
    );
    await Future.wait([
      _local.saveToken(result.token.token),
      if (result.token.refreshToken != null)
        _local.saveRefreshToken(result.token.refreshToken!),
      _local.saveUser(result.user),
    ]);
    final UserEntity user = result.user;
    return (token: result.token.token, user: user, isNewUser: result.token.isNewUser);
  }

  @override
  Future<({String token, UserEntity user, bool isNewUser})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final result = await _remote.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    await Future.wait([
      _local.saveToken(result.token.token),
      if (result.token.refreshToken != null)
        _local.saveRefreshToken(result.token.refreshToken!),
      _local.saveUser(result.user),
    ]);
    final UserEntity user = result.user;
    return (token: result.token.token, user: user, isNewUser: result.token.isNewUser);
  }

  @override
  Future<void> forgotPassword(String identifier) =>
      _remote.forgotPassword(identifier);

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
    } catch (_) {}
    await _local.clear();
  }
}
