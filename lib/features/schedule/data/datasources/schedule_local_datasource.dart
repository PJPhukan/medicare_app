import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/interceptors/cache_interceptor.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/local_db/local_cache.dart';
import '../models/appointment_model.dart';

/// Typed read access to schedule data stored by [CacheInterceptor].
class ScheduleLocalDataSource {
  const ScheduleLocalDataSource(this._cache);
  final LocalCache _cache;

  static final _key =
      CacheInterceptor.keyFor(ApiConstants.baseUrl, ApiConstants.todayDoses);

  List<TodayDose> getCachedDoses() {
    final raw = _cache.getMap(_key);
    if (raw == null) return [];
    final list = raw['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>().map(TodayDose.fromJson).toList();
  }

  bool get hasCachedData => _cache.contains(_key);
}

final scheduleLocalDsProvider = Provider<ScheduleLocalDataSource>((ref) =>
    ScheduleLocalDataSource(ref.read(localCacheProvider)));
