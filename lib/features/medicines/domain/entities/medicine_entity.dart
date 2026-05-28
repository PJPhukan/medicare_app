// Pure domain entities for the medicines feature.
// No Flutter, no JSON, no Dio.

class CatalogMedicineEntity {
  const CatalogMedicineEntity({
    required this.id,
    required this.name,
    this.genericName,
    this.dosageForm,
    this.strength,
    this.manufacturer,
    this.description,
  });

  final String id;
  final String name;
  final String? genericName;
  final String? dosageForm;
  final String? strength;
  final String? manufacturer;
  final String? description;
}

class MedicineDoseTimeEntity {
  const MedicineDoseTimeEntity({
    required this.id,
    required this.scheduledTime,
    this.unit,
    this.foodTiming,
  });

  final String id;
  final String scheduledTime;
  final String? unit;
  final String? foodTiming;
}

class MedicineDoseScheduleEntity {
  const MedicineDoseScheduleEntity({
    required this.id,
    required this.scheduleType,
    required this.isPrn,
    required this.doseTimes,
  });

  final String id;
  final String scheduleType;
  final bool isPrn;
  final List<MedicineDoseTimeEntity> doseTimes;
}

class MedicineStockEntity {
  const MedicineStockEntity({
    required this.id,
    required this.quantity,
    this.expiryDate,
  });

  final String id;
  final int quantity;
  final String? expiryDate;
}

class UserMedicineEntity {
  const UserMedicineEntity({
    required this.id,
    required this.scope,
    required this.active,
    required this.createdAt,
    required this.medicine,
    required this.doseSchedules,
    this.customName,
    this.stock,
    this.effectiveStock,
  });

  final String id;
  final String scope;
  final bool active;
  final String createdAt;
  final CatalogMedicineEntity medicine;
  final List<MedicineDoseScheduleEntity> doseSchedules;
  final String? customName;
  final MedicineStockEntity? stock;
  final MedicineStockEntity? effectiveStock;

  String get displayName => customName ?? medicine.name;
  bool get isShared => scope == 'SHARED_MASTER' || scope == 'SHARED_MEMBER';
  bool get isPrn => doseSchedules.isNotEmpty && doseSchedules.first.isPrn;
  bool get isLowStock =>
      (effectiveStock ?? stock) != null &&
      (effectiveStock ?? stock)!.quantity < 5;
}
