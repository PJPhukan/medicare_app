import '../entities/dashboard_stats_entity.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

abstract interface class DashboardRepository {
  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<NotificationEntity> notifications,
  })> getDashboardData();
}
