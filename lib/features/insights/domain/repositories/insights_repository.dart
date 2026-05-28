import '../entities/adherence_entity.dart';
import '../entities/insight_entity.dart';

abstract interface class InsightsRepository {
  Future<List<InsightEntity>> getInsights();
  Future<AdherenceEntity> getAdherence({int periodDays});
}
