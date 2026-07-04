import '../../domain/entities/medicine_entity.dart';

class CatalogMedicine extends CatalogMedicineEntity {
  const CatalogMedicine({
    required super.id,
    required super.name,
    super.genericName,
    super.dosageForm,
    super.strength,
    super.manufacturer,
    super.description,
  });

  factory CatalogMedicine.fromJson(Map<String, dynamic> json) =>
      CatalogMedicine(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        genericName: json['genericName'] as String?,
        dosageForm: json['dosageForm'] as String?,
        strength: json['strength'] as String?,
        manufacturer: json['manufacturer'] as String?,
        description: json['description'] as String?,
      );
}

class MedicineDoseTime extends MedicineDoseTimeEntity {
  const MedicineDoseTime({
    required super.id,
    required super.scheduledTime,
    super.unit,
    super.foodTiming,
  });

  factory MedicineDoseTime.fromJson(Map<String, dynamic> json) =>
      MedicineDoseTime(
        id: json['id']?.toString() ?? '',
        scheduledTime: json['scheduledTime'] as String? ?? '',
        unit: json['unit'] as String?,
        foodTiming: json['foodTiming'] as String?,
      );
}

class MedicineDoseSchedule extends MedicineDoseScheduleEntity {
  const MedicineDoseSchedule({
    required super.id,
    required super.scheduleType,
    required super.isPrn,
    required super.doseTimes,
  });

  factory MedicineDoseSchedule.fromJson(Map<String, dynamic> json) =>
      MedicineDoseSchedule(
        id: json['id']?.toString() ?? '',
        scheduleType: json['scheduleType'] as String? ?? '',
        isPrn: json['isPrn'] as bool? ?? false,
        doseTimes: (json['doseTimes'] as List<dynamic>? ?? [])
            .map((e) => MedicineDoseTime.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MedicineStock extends MedicineStockEntity {
  const MedicineStock({
    required super.id,
    required super.quantity,
    super.expiryDate,
  });

  factory MedicineStock.fromJson(Map<String, dynamic> json) => MedicineStock(
        id: json['id']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        expiryDate: json['expiryDate'] as String?,
      );
}

class UserMedicine extends UserMedicineEntity {
  const UserMedicine({
    required super.id,
    required super.scope,
    required super.active,
    required super.createdAt,
    required super.medicine,
    required super.doseSchedules,
    super.customName,
    super.stock,
    super.effectiveStock,
  });

  factory UserMedicine.fromJson(Map<String, dynamic> json) => UserMedicine(
        id: json['id']?.toString() ?? '',
        scope: json['scope'] as String? ?? '',
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt'] as String? ?? '',
        customName: json['customName'] as String?,
        medicine: json['medicine'] is Map<String, dynamic>
            ? CatalogMedicine.fromJson(json['medicine'] as Map<String, dynamic>)
            : const CatalogMedicine(id: '', name: 'Unknown'),
        doseSchedules: (json['doseSchedules'] as List<dynamic>? ?? [])
            .map((e) => MedicineDoseSchedule.fromJson(e as Map<String, dynamic>))
            .toList(),
        stock: json['stock'] != null
            ? MedicineStock.fromJson(json['stock'] as Map<String, dynamic>)
            : null,
        effectiveStock: json['effectiveStock'] != null
            ? MedicineStock.fromJson(
                json['effectiveStock'] as Map<String, dynamic>)
            : null,
      );
}
