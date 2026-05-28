import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

const _kToken   = 'auth_token';
const _kUser    = 'auth_user';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<void> saveToken(String token) =>
      _storage.write(key: _kToken, value: token);

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) =>
      _storage.write(key: _kUser, value: json.encode(user.toJson()));

  Future<void> clear() => _storage.deleteAll();
}
