import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/interceptors/cache_interceptor.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/local_db/local_cache.dart';
import '../../../schedule/data/models/appointment_model.dart';

/// Typed read access to dashboard data stored by [CacheInterceptor].
class DashboardLocalDataSource {
  const DashboardLocalDataSource(this._cache);
  final LocalCache _cache;

  static final _dosesKey =
      CacheInterceptor.keyFor(ApiConstants.baseUrl, ApiConstants.todayDoses);

  List<TodayDose> getCachedDoses() {
    final raw = _cache.getMap(_dosesKey);
    if (raw == null) return [];
    final list = raw['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>().map(TodayDose.fromJson).toList();
  }

  bool get hasCachedData => _cache.contains(_dosesKey);
}

final dashboardLocalDsProvider = Provider<DashboardLocalDataSource>((ref) =>
    DashboardLocalDataSource(ref.read(localCacheProvider)));
