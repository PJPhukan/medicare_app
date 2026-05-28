class DashboardStatsEntity {
  const DashboardStatsEntity({
    required this.totalMedicines,
    required this.todayDoseCount,
    required this.takenCount,
    required this.pendingCount,
    required this.lowStockCount,
    required this.adherencePercent,
    required this.unreadNotifications,
  });

  final int totalMedicines;
  final int todayDoseCount;
  final int takenCount;
  final int pendingCount;
  final int lowStockCount;
  final double adherencePercent;
  final int unreadNotifications;

  factory DashboardStatsEntity.empty() => const DashboardStatsEntity(
        totalMedicines: 0,
        todayDoseCount: 0,
        takenCount: 0,
        pendingCount: 0,
        lowStockCount: 0,
        adherencePercent: 0,
        unreadNotifications: 0,
      );
}
