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

/// Server-computed alert raised when a reading value falls outside the
/// configured normal/warning band. Mirrors the backend `VitalAlert` model.
class VitalAlertEntity {
  const VitalAlertEntity({
    required this.id,
    required this.inputId,
    required this.severity,
    required this.acknowledged,
  });

  final String id;
  final String inputId;

  /// One of `LOW`, `NORMAL`, `HIGH`, `CRITICAL`.
  final String severity;
  final bool acknowledged;

  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isLow => severity == 'LOW';
  bool get isAbnormal => severity != 'NORMAL';
}

class VitalReadingEntity {
  const VitalReadingEntity({
    required this.id,
    required this.vitalConfigId,
    required this.measuredAt,
    required this.vitalConfig,
    required this.values,
    this.alerts = const [],
    this.notes,
  });

  final String id;
  final String vitalConfigId;
  final String measuredAt;
  final VitalConfigEntity vitalConfig;
  final List<VitalReadingValueEntity> values;
  final List<VitalAlertEntity> alerts;
  final String? notes;

  DateTime get measuredAtDate => DateTime.parse(measuredAt);

  /// Unacknowledged, abnormal alerts the backend raised for this reading.
  List<VitalAlertEntity> get activeAlerts =>
      alerts.where((a) => a.isAbnormal && !a.acknowledged).toList();
}
