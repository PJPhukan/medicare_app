import '../../domain/entities/medicine_entity.dart';

/// The clinical catalog fields are `Json` columns and nothing populates them
/// yet, so their shape isn't pinned down. Accept the forms an importer or an
/// admin form would plausibly write — a list of strings, a list of objects
/// keyed by name/value/text, a single string, or a map — rather than throwing
/// on whatever arrives first.
List<String> _stringList(dynamic raw) {
  String? one(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.trim();
    if (v is Map) {
      final picked = v['name'] ?? v['value'] ?? v['text'] ?? v['title'];
      return picked?.toString().trim();
    }
    return v.toString().trim();
  }

  final values = switch (raw) {
    null => const <dynamic>[],
    final List<dynamic> l => l,
    final Map<String, dynamic> m => m.values.toList(),
    final String s => s.contains(',') ? s.split(',') : [s],
    _ => [raw],
  };
  return values
      .map(one)
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .toList();
}

class CatalogMedicine extends CatalogMedicineEntity {
  const CatalogMedicine({
    required super.id,
    required super.name,
    super.type,
    super.genericName,
    super.dosageForm,
    super.strength,
    super.manufacturer,
    super.description,
    super.primarilyUsedFor,
    super.productPacking,
    super.productUnit,
    super.storageConditions,
    super.compositions,
    super.sideEffects,
    super.contraindications,
    super.drugInteractions,
  });

  /// Medicine rows and Product rows arrive from the same endpoint with
  /// different field names. Products are mapped onto the medicine-shaped
  /// fields the UI already renders (brand → manufacturer/generic,
  /// variantSize → strength, sub/mainCategory → form) so one card layout
  /// serves both catalogs.
  factory CatalogMedicine.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? CatalogMedicineEntity.typeMedicine;
    final isProduct = type == CatalogMedicineEntity.typeProduct;
    return CatalogMedicine(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      type: type,
      genericName: isProduct
          ? json['brand'] as String?
          : json['genericName'] as String?,
      dosageForm: isProduct
          ? (json['subCategory'] as String? ?? json['mainCategory'] as String?)
          : json['dosageForm'] as String?,
      strength: isProduct
          ? json['variantSize'] as String?
          : json['strength'] as String?,
      manufacturer: isProduct
          ? json['brand'] as String?
          : json['manufacturer'] as String?,
      description: json['description'] as String?,
      primarilyUsedFor: isProduct
          ? json['benefits'] as String?
          : json['primarilyUsedFor'] as String?,
      productPacking: json['productPacking'] as String?,
      productUnit: json['productUnit'] as String?,
      storageConditions: json['storageConditions'] as String?,
      compositions:
          _stringList(isProduct ? json['ingredients'] : json['compositions']),
      sideEffects: _stringList(json['sideEffects']),
      contraindications: _stringList(
          isProduct ? json['safetyInformation'] : json['contraindications']),
      drugInteractions: _stringList(json['drugInteractions']),
    );
  }
}

class CatalogPage extends CatalogPageEntity {
  const CatalogPage({
    required super.items,
    required super.total,
    required super.page,
    required super.pages,
  });

  factory CatalogPage.fromJson(Map<String, dynamic> json) => CatalogPage(
        items: (json['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CatalogMedicine.fromJson)
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pages: (json['pages'] as num?)?.toInt() ?? 1,
      );
}

class MedicineDoseTime extends MedicineDoseTimeEntity {
  const MedicineDoseTime({
    required super.id,
    required super.scheduledTime,
    super.quantity,
    super.unit,
    super.foodTiming,
  });

  factory MedicineDoseTime.fromJson(Map<String, dynamic> json) =>
      MedicineDoseTime(
        id: json['id']?.toString() ?? '',
        scheduledTime: json['scheduledTime'] as String? ?? '',
        quantity: json['quantity'] as num?,
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
    super.isActive,
    super.startDate,
    super.endDate,
  });

  factory MedicineDoseSchedule.fromJson(Map<String, dynamic> json) =>
      MedicineDoseSchedule(
        id: json['id']?.toString() ?? '',
        scheduleType: json['scheduleType'] as String? ?? '',
        isPrn: json['isPrn'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        doseTimes: (json['doseTimes'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MedicineDoseTime.fromJson)
            .toList(),
      );
}

class StockHistoryEntry extends StockHistoryEntryEntity {
  const StockHistoryEntry({
    required super.id,
    required super.action,
    required super.quantityChange,
    required super.quantityAfter,
    super.createdAt,
  });

  factory StockHistoryEntry.fromJson(Map<String, dynamic> json) =>
      StockHistoryEntry(
        id: json['id']?.toString() ?? '',
        action: json['action'] as String? ?? '',
        quantityChange: (json['quantityChange'] as num?)?.toInt() ?? 0,
        quantityAfter: (json['quantityAfter'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] as String?,
      );
}

class MedicineStock extends MedicineStockEntity {
  const MedicineStock({
    required super.id,
    required super.quantity,
    super.minThreshold,
    super.expiryDate,
    super.history,
  });

  factory MedicineStock.fromJson(Map<String, dynamic> json) => MedicineStock(
        id: json['id']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        minThreshold: (json['minThreshold'] as num?)?.toInt() ?? 0,
        expiryDate: json['expiryDate'] as String?,
        history: (json['stockHistory'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(StockHistoryEntry.fromJson)
            .toList(),
      );
}

class UserMedicine extends UserMedicineEntity {
  const UserMedicine({
    required super.id,
    required super.scope,
    required super.active,
    required super.addedAt,
    required super.doseSchedules,
    super.medicine,
    super.product,
    super.customName,
    super.stock,
    super.effectiveStock,
    super.patientProfileId,
    super.patientName,
  });

  static CatalogMedicine? _catalog(dynamic raw, String type) =>
      raw is Map<String, dynamic>
          ? CatalogMedicine.fromJson({...raw, 'type': type})
          : null;

  static MedicineStock? _stock(dynamic raw) => raw is Map<String, dynamic>
      ? MedicineStock.fromJson(raw)
      : null;

  factory UserMedicine.fromJson(Map<String, dynamic> json) => UserMedicine(
        id: json['id']?.toString() ?? '',
        scope: json['scope'] as String? ?? 'PERSONAL',
        active: json['active'] as bool? ?? true,
        addedAt: json['addedAt'] as String? ?? '',
        customName: json['customName'] as String?,
        medicine:
            _catalog(json['medicine'], CatalogMedicineEntity.typeMedicine),
        product: _catalog(json['product'], CatalogMedicineEntity.typeProduct),
        doseSchedules: (json['doseSchedules'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MedicineDoseSchedule.fromJson)
            .toList(),
        stock: _stock(json['stock']),
        effectiveStock: _stock(json['effectiveStock']),
        patientProfileId: json['patientProfileId']?.toString(),
        patientName: (json['patientProfile'] as Map<String, dynamic>?)?['name']
            as String?,
      );
}
