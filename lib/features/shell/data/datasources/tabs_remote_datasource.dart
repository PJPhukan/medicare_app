import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/tab_config_model.dart';

class TabsRemoteDataSource {
  const TabsRemoteDataSource(this._dio);

  final Dio _dio;

  static const _cacheKey = 'tab_config_app_v1';

  Future<List<TabConfigModel>> getMyTabs() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.myTabs,
        queryParameters: {'platform': 'APP'},
      );
      final list = (res.data?['data'] as List<dynamic>?) ?? [];

      // Cache the last-known tab config so it still renders offline, the same
      // way banners are cached — instead of dropping to the hardcoded defaults.
      if (list.isNotEmpty) {
        unawaited(prefs.setString(_cacheKey, jsonEncode(list)));
      }

      return list
          .map((e) => TabConfigModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Offline / request failed → fall back to the cached config if we have it.
      final cached = _fromPrefs(prefs);
      if (cached != null) return cached;
      rethrow; // no cache yet → let the shell use its hardcoded defaults
    }
  }

  List<TabConfigModel>? _fromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
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
