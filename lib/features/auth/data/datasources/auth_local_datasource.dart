import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/token_store.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

const _kToken           = 'auth_token';
const _kRefreshToken    = 'refresh_token';
const _kUser            = 'auth_user';
const _kOnboardingStep  = 'onboarding_step';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kToken, value: token);
    TokenStore.set(token);
  }

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (e, s) {
      AppLogger.e('User cache corrupted — clearing', error: e, stack: s);
      await _storage.delete(key: _kUser);
      return null;
    }
  }

  Future<void> saveUser(UserModel user) =>
      _storage.write(key: _kUser, value: json.encode(user.toJson()));

  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required UserModel user,
  }) async {
    await Future.wait([
      _storage.write(key: _kToken, value: token),
      if (refreshToken != null)
        _storage.write(key: _kRefreshToken, value: refreshToken),
      saveUser(user),
    ]);
    TokenStore.set(token);
  }

  Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _kToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kUser),
      _storage.delete(key: _kOnboardingStep),
    ]);
    TokenStore.set(null);
  }

  Future<String?> readOnboardingStep() => _storage.read(key: _kOnboardingStep);

  Future<void> saveOnboardingStep(String step) =>
      _storage.write(key: _kOnboardingStep, value: step);

  Future<void> clearOnboardingStep() => _storage.delete(key: _kOnboardingStep);
}
