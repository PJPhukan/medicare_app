import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStats extends DashboardStatsEntity {
  const DashboardStats({
    required super.totalMedicines,
    required super.todayDoseCount,
    required super.takenCount,
    required super.pendingCount,
    required super.lowStockCount,
    required super.adherencePercent,
    required super.unreadNotifications,
  });
}
