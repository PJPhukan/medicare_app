import '../../domain/entities/vital_reading_entity.dart';
import 'vital_config_model.dart';

class VitalReadingValue extends VitalReadingValueEntity {
  const VitalReadingValue({
    required super.id,
    required super.inputId,
    required super.value,
    required super.input,
  });

  factory VitalReadingValue.fromJson(Map<String, dynamic> json) =>
      VitalReadingValue(
        id: json['id'] as String,
        inputId: json['inputId'] as String,
        value: (json['value'] as num).toDouble(),
        input: VitalInput.fromJson(json['input'] as Map<String, dynamic>),
      );
}

class VitalAlert extends VitalAlertEntity {
  const VitalAlert({
    required super.id,
    required super.inputId,
    required super.severity,
    required super.acknowledged,
  });

  factory VitalAlert.fromJson(Map<String, dynamic> json) => VitalAlert(
        id: json['id'] as String,
        inputId: json['inputId'] as String,
        severity: json['severity'] as String? ?? 'NORMAL',
        acknowledged: json['acknowledged'] as bool? ?? false,
      );
}

class VitalReading extends VitalReadingEntity {
  const VitalReading({
    required super.id,
    required super.vitalConfigId,
    required super.measuredAt,
    required super.vitalConfig,
    required super.values,
    super.alerts,
    super.notes,
  });

  factory VitalReading.fromJson(Map<String, dynamic> json) => VitalReading(
        id: json['id'] as String,
        vitalConfigId: json['vitalConfigId'] as String,
        measuredAt: json['measuredAt'] as String,
        notes: json['notes'] as String?,
        vitalConfig: VitalConfig.fromJson(
          json['vitalConfig'] as Map<String, dynamic>,
        ),
        values: (json['values'] as List<dynamic>? ?? [])
            .map((e) => VitalReadingValue.fromJson(e as Map<String, dynamic>))
            .toList(),
        alerts: (json['alerts'] as List<dynamic>? ?? [])
            .map((e) => VitalAlert.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
