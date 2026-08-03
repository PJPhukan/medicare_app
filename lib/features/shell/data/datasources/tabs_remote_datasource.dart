import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/tab_config_model.dart';

class TabsRemoteDataSource {
  const TabsRemoteDataSource(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _cacheKey = 'tab_config_app_v1';

  /// Synchronous read of the last-known tab config, if any. Used so a
  /// returning user's tabs render instantly instead of waiting on the network.
  List<TabConfigModel>? getCachedTabs() => _fromPrefs();

  Future<List<TabConfigModel>> getMyTabs() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.myTabs,
        queryParameters: {'platform': 'APP'},
      );
      final list = (res.data?['data'] as List<dynamic>?) ?? [];

      // Cache the last-known tab config so it still renders offline, the same
      // way banners are cached — instead of dropping to the hardcoded defaults.
      if (list.isNotEmpty) {
        unawaited(_prefs.setString(_cacheKey, jsonEncode(list)));
      }

      return list
          .map((e) => TabConfigModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Offline / request failed → fall back to the cached config if we have it.
      final cached = _fromPrefs();
      if (cached != null) return cached;
      rethrow; // no cache yet → shell handles empty/loading state
    }
  }

  List<TabConfigModel>? _fromPrefs() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final tabs = list
          .whereType<Map<String, dynamic>>()
          .map(TabConfigModel.fromJson)
          .toList();
      return tabs.isEmpty ? null : tabs;
    } catch (_) {
      return null;
    }
  }
}
