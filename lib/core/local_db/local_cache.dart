import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── SharedPreferences bootstrap provider ─────────────────────────────────────
// Overridden in main.dart before runApp with a real instance.

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in main.dart'),
);

// ─── Typed JSON cache over SharedPreferences ──────────────────────────────────

class LocalCache {
  const LocalCache(this._prefs);
  final SharedPreferences _prefs;

  Future<void> put(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic get(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s);
  }

  Map<String, dynamic>? getMap(String key) {
    final val = get(key);
    if (val is Map<String, dynamic>) return val;
    return null;
  }

  List<Map<String, dynamic>> getList(String key) {
    final val = get(key);
    if (val is! List) return [];
    return val.cast<Map<String, dynamic>>();
  }

  Future<void> remove(String key) async => _prefs.remove(key);

  bool contains(String key) => _prefs.containsKey(key);
}

final localCacheProvider = Provider<LocalCache>((ref) {
  return LocalCache(ref.read(sharedPreferencesProvider));
});
