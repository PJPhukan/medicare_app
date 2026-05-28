import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/interceptors/cache_interceptor.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/local_db/local_cache.dart';
import '../models/medicine_model.dart';

/// Typed read access to medicines data stored by [CacheInterceptor].
class MedicinesLocalDataSource {
  const MedicinesLocalDataSource(this._cache);
  final LocalCache _cache;

  static final _key =
      CacheInterceptor.keyFor(ApiConstants.baseUrl, ApiConstants.myMedicines);

  List<UserMedicine> getCachedMedicines() {
    final raw = _cache.getMap(_key);
    if (raw == null) return [];
    final list = raw['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>().map(UserMedicine.fromJson).toList();
  }

  bool get hasCachedData => _cache.contains(_key);
}

final medicinesLocalDsProvider = Provider<MedicinesLocalDataSource>((ref) =>
    MedicinesLocalDataSource(ref.read(localCacheProvider)));
