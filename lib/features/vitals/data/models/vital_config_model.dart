import '../../domain/entities/vital_config_entity.dart';

class VitalInput extends VitalInputEntity {
  const VitalInput({
    required super.id,
    required super.label,
    required super.unit,
    required super.color,
    required super.normalMin,
    required super.normalMax,
    required super.warningMin,
    required super.warningMax,
    required super.sortOrder,
    super.placeholder,
  });

  factory VitalInput.fromJson(Map<String, dynamic> json) => VitalInput(
        id: json['id'] as String,
        label: json['label'] as String,
        unit: json['unit'] as String,
        color: json['color'] as String? ?? '#2D9596',
        normalMin: (json['normalMin'] as num).toDouble(),
        normalMax: (json['normalMax'] as num).toDouble(),
        warningMin: (json['warningMin'] as num).toDouble(),
        warningMax: (json['warningMax'] as num).toDouble(),
        sortOrder: json['sortOrder'] as int? ?? 0,
        placeholder: json['placeholder'] as String?,
      );
}

class VitalConfig extends VitalConfigEntity {
  const VitalConfig({
    required super.id,
    required super.name,
    required super.graphType,
    required super.isActive,
    required super.sortOrder,
    required List<VitalInput> inputs,
  }) : super(inputs: inputs);

  @override
  List<VitalInput> get inputs => super.inputs.cast<VitalInput>();

  factory VitalConfig.fromJson(Map<String, dynamic> json) => VitalConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        graphType: json['graphType'] as String? ?? 'LINE',
        isActive: json['isActive'] as bool? ?? true,
        sortOrder: json['sortOrder'] as int? ?? 0,
        inputs: (json['inputs'] as List<dynamic>? ?? [])
            .map((e) => VitalInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
