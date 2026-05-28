import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../medicines/data/models/medicine_model.dart';
import '../../../schedule/data/models/appointment_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../vitals/data/models/vital_reading_model.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({
    DashboardStats stats,
    List<TodayDose> doses,
    List<VitalReading> recentVitals,
    List<AppNotification> notifications,
  })> getDashboardData() async {
    final results = await Future.wait([
      _fetchMedicines(),
      _fetchTodayDoses(),
      _fetchVitals(),
      _fetchNotifications(),
    ]);

    final medicines   = results[0] as List<UserMedicine>;
    final doses       = results[1] as List<TodayDose>;
    final vitals      = results[2] as List<VitalReading>;
    final notifResult =
        results[3] as ({List<AppNotification> notifications, int unreadCount});

    final takenCount = doses.where((d) => d.isTaken).length;
    final lowStock   = medicines.where((m) => m.isLowStock).length;
    final adherence  = doses.isEmpty
        ? 0.0
        : (takenCount / doses.length * 100).clamp(0.0, 100.0);

    final stats = DashboardStats(
      totalMedicines: medicines.length,
      todayDoseCount: doses.length,
      takenCount: takenCount,
      pendingCount: doses.where((d) => d.isPending).length,
      lowStockCount: lowStock,
      adherencePercent: adherence,
      unreadNotifications: notifResult.unreadCount,
    );

    return (
      stats: stats,
      doses: doses,
      recentVitals: vitals.take(5).toList(),
      notifications: notifResult.notifications.take(10).toList(),
    );
  }

  Future<List<UserMedicine>> _fetchMedicines() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>(ApiConstants.myMedicines);
      final list = res.data!['data'] as List<dynamic>;
      return list
          .map((e) => UserMedicine.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TodayDose>> _fetchTodayDoses() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>(ApiConstants.todayDoses);
      final list = res.data!['data'] as List<dynamic>;
      return list
          .map((e) => TodayDose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<VitalReading>> _fetchVitals() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>(ApiConstants.myVitals);
      final list = res.data!['data'] as List<dynamic>;
      return list
          .map((e) => VitalReading.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<({List<AppNotification> notifications, int unreadCount})>
      _fetchNotifications() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.notifications,
        queryParameters: {'take': 10},
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      final list = data['notifications'] as List<dynamic>;
      return (
        notifications: list
            .map((e) =>
                AppNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
        unreadCount: data['unreadCount'] as int? ?? 0,
      );
    } catch (_) {
      return (notifications: <AppNotification>[], unreadCount: 0);
    }
  }
}
