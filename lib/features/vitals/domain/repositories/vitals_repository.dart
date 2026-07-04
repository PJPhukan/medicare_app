import '../entities/vital_config_entity.dart';
import '../entities/vital_reading_entity.dart';

abstract interface class VitalsRepository {
  Future<List<VitalConfigEntity>> getConfigs();

  Future<List<VitalReadingEntity>> getMyVitals();

  Future<VitalReadingEntity> addReading({
    required String vitalConfigId,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  });

  Future<VitalReadingEntity> updateReading({
    required String id,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  });

  Future<({List<VitalReadingEntity> readings, String? nextCursor})> getVitalHistory({
    required String configId,
    required String filter,
    String? cursor,
    int limit = 20,
  });
}
