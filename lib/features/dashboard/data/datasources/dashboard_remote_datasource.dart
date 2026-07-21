import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../schedule/data/models/appointment_model.dart';
import '../../../vitals/data/models/vital_reading_model.dart';
import '../models/banner_config.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({
    DashboardStats stats,
    List<TodayDose> doses,
    List<VitalReading> recentVitals,
    List<DashboardBanner> banners,
  })> getDashboardData() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.dashboard);
    final data = res.data!['data'] as Map<String, dynamic>;

    final user = data['user'] as Map<String, dynamic>? ?? {};
    final unreadCount = user['notificationCount'] as int? ?? 0;

    final rawDoses = data['todayMedicines'] as List<dynamic>? ?? [];
    final doses = rawDoses
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return TodayDose.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<TodayDose>()
        .toList();

    final rawVitals = data['recentVitals'] as List<dynamic>? ?? [];
    final vitals = rawVitals
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return VitalReading.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<VitalReading>()
        .toList();

    final rawBanners = data['banners'] as List<dynamic>? ?? [];
    final banners = rawBanners
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return DashboardBanner.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<DashboardBanner>()
        .toList();

    if (kDebugMode) {
      AppLogger.d('banners from API: ${banners.length} '
          '(raw: ${rawBanners.length}) — '
          '${banners.map((b) => b.imageUrl).join(', ')}', tag: 'Dashboard');
    }

    final takenCount = doses.where((d) => d.isTaken).length;
    final stats = DashboardStats(
      totalMedicines: doses.length,
      todayDoseCount: doses.length,
      takenCount: takenCount,
      pendingCount: doses.where((d) => d.isPending).length,
      lowStockCount: data['lowStockCount'] as int? ?? 0,
      adherencePercent: (data['adherenceRate'] as num?)?.toDouble() ?? 0.0,
      unreadNotifications: unreadCount,
    );

    return (stats: stats, doses: doses, recentVitals: vitals, banners: banners);
  }
}
