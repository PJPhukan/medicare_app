import '../entities/dashboard_stats_entity.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../../data/models/banner_config.dart';

abstract interface class DashboardRepository {
  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<DashboardBanner> banners,
  })> getDashboardData();
}
