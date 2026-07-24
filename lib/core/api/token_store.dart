import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// In-memory read-through cache over the secure-storage access token.
///
/// Secure-storage reads go through a platform channel (Keystore/Keychain
/// decrypt), so reading the token on every API request adds per-request
/// latency. The first read hits storage; subsequent reads are free.
///
/// Every code path that writes or deletes the `auth_token` key must call
/// [set] so this cache never goes stale.
abstract final class TokenStore {
  static const key = 'auth_token';

  static String? _cached;
  static bool _loaded = false;

  static Future<String?> read(FlutterSecureStorage storage) async {
    if (!_loaded) {
      _cached = await storage.read(key: key);
      _loaded = true;
    }
    return _cached;
  }

  /// Sync the cache after the token is written (or deleted — pass null).
  static void set(String? token) {
    _cached = token;
    _loaded = true;
  }
}
