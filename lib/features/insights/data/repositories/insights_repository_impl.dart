import '../../domain/entities/adherence_entity.dart';
import '../../domain/entities/insight_entity.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_remote_datasource.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  const InsightsRepositoryImpl(this._ds);

  final InsightsRemoteDataSource _ds;

  @override
  Future<List<InsightEntity>> getInsights() async {
    final List<InsightEntity> list = await _ds.getInsights();
    return list;
  }

  @override
  Future<AdherenceEntity> getAdherence({int periodDays = 7}) async {
    final AdherenceEntity adherence =
        await _ds.getAdherence(periodDays: periodDays);
    return adherence;
  }
}
