import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._ds);

  final DashboardRemoteDataSource _ds;

  @override
  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<NotificationEntity> notifications,
  })> getDashboardData() async {
    final data = await _ds.getDashboardData();
    final DashboardStatsEntity stats = data.stats;
    final List<DoseEntity> doses = data.doses;
    final List<VitalReadingEntity> recentVitals = data.recentVitals;
    final List<NotificationEntity> notifications = data.notifications;
    return (
      stats: stats,
      doses: doses,
      recentVitals: recentVitals,
      notifications: notifications,
    );
  }
}
