import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/interceptors/cache_interceptor.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/local_db/local_cache.dart';
import '../models/vital_config_model.dart';
import '../models/vital_reading_model.dart';

/// Typed read access to vitals data stored by [CacheInterceptor].
class VitalsLocalDataSource {
  const VitalsLocalDataSource(this._cache);
  final LocalCache _cache;

  static final _configsKey =
      CacheInterceptor.keyFor(ApiConstants.baseUrl, ApiConstants.vitalConfigs);
  static final _readingsKey =
      CacheInterceptor.keyFor(ApiConstants.baseUrl, ApiConstants.myVitals);

  List<VitalConfig> getCachedConfigs() {
    final raw = _cache.getMap(_configsKey);
    if (raw == null) return [];
    final list = raw['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>().map(VitalConfig.fromJson).toList();
  }

  List<VitalReading> getCachedReadings() {
    final raw = _cache.getMap(_readingsKey);
    if (raw == null) return [];
    final list = raw['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>().map(VitalReading.fromJson).toList();
  }

  bool get hasCachedConfigs  => _cache.contains(_configsKey);
  bool get hasCachedReadings => _cache.contains(_readingsKey);
}

final vitalsLocalDsProvider = Provider<VitalsLocalDataSource>((ref) =>
    VitalsLocalDataSource(ref.read(localCacheProvider)));
