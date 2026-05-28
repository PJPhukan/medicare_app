// Pure domain entities for vital configuration.
// No Flutter, no JSON, no Dio.

class VitalInputEntity {
  const VitalInputEntity({
    required this.id,
    required this.label,
    required this.unit,
    required this.color,
    required this.normalMin,
    required this.normalMax,
    required this.warningMin,
    required this.warningMax,
    required this.sortOrder,
    this.placeholder,
  });

  final String id;
  final String label;
  final String unit;
  final String color;
  final double normalMin;
  final double normalMax;
  final double warningMin;
  final double warningMax;
  final int sortOrder;
  final String? placeholder;

  bool isNormal(double value) => value >= normalMin && value <= normalMax;
  bool isWarning(double value) =>
      (value >= warningMin && value < normalMin) ||
      (value > normalMax && value <= warningMax);
}

class VitalConfigEntity {
  const VitalConfigEntity({
    required this.id,
    required this.name,
    required this.graphType,
    required this.isActive,
    required this.sortOrder,
    required this.inputs,
  });

  final String id;
  final String name;
  final String graphType;
  final bool isActive;
  final int sortOrder;
  final List<VitalInputEntity> inputs;
}
