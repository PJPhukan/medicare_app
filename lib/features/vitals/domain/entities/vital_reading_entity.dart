// Pure domain entities for vital readings.
// No Flutter, no JSON, no Dio.

import 'vital_config_entity.dart';

class VitalReadingValueEntity {
  const VitalReadingValueEntity({
    required this.id,
    required this.inputId,
    required this.value,
    required this.input,
  });

  final String id;
  final String inputId;
  final double value;
  final VitalInputEntity input;
}

class VitalReadingEntity {
  const VitalReadingEntity({
    required this.id,
    required this.vitalConfigId,
    required this.measuredAt,
    required this.vitalConfig,
    required this.values,
    this.notes,
  });

  final String id;
  final String vitalConfigId;
  final String measuredAt;
  final VitalConfigEntity vitalConfig;
  final List<VitalReadingValueEntity> values;
  final String? notes;

  DateTime get measuredAtDate => DateTime.parse(measuredAt);
}
