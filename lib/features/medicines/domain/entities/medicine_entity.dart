// Pure domain entities for the medicines feature.
// No Flutter, no JSON, no Dio.

/// One row of the merged catalog search. The backend serves Medicine and
/// Product rows from the same endpoint and tags each with [type] — adding an
/// entry to "my medicines" must send `medicineId` for one and `productId` for
/// the other, so the tag has to survive into the UI.
class CatalogMedicineEntity {
  const CatalogMedicineEntity({
    required this.id,
    required this.name,
    this.type = typeMedicine,
    this.genericName,
    this.dosageForm,
    this.strength,
    this.manufacturer,
    this.description,
    this.primarilyUsedFor,
    this.productPacking,
    this.productUnit,
    this.storageConditions,
    this.compositions = const [],
    this.sideEffects = const [],
    this.contraindications = const [],
    this.drugInteractions = const [],
  });

  static const String typeMedicine = 'medicine';
  static const String typeProduct = 'product';

  final String id;
  final String name;

  /// [typeMedicine] or [typeProduct] — which catalog this row came from.
  final String type;

  final String? genericName;
  final String? dosageForm;
  final String? strength;
  final String? manufacturer;
  final String? description;
  final String? primarilyUsedFor;
  final String? productPacking;
  final String? productUnit;
  final String? storageConditions;

  /// Free-form clinical lists. Stored as JSON on the catalog row and empty on
  /// every row today — nothing populates them yet.
  final List<String> compositions;
  final List<String> sideEffects;
  final List<String> contraindications;
  final List<String> drugInteractions;

  bool get isProduct => type == typeProduct;

  /// "Paracetamol · 500mg · Tablet" — skips whatever the catalog didn't supply
  /// instead of rendering the empty separators a blind join would leave.
  String get subtitle => [genericName, strength, dosageForm]
      .where((s) => s != null && s.isNotEmpty)
      .join(' · ');
}

/// One page of catalog results.
class CatalogPageEntity {
  const CatalogPageEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  final List<CatalogMedicineEntity> items;
  final int total;
  final int page;
  final int pages;

  bool get hasMore => page < pages;
}

class MedicineDoseTimeEntity {
  const MedicineDoseTimeEntity({
    required this.id,
    required this.scheduledTime,
    this.quantity,
    this.unit,
    this.foodTiming,
  });

  final String id;

  /// HH:mm, 24-hour.
  final String scheduledTime;
  final num? quantity;
  final String? unit;
  final String? foodTiming;

  /// "1 tablet" — what the add wizard's dose-amount field round-trips to.
  String get doseLabel {
    final qty = quantity == null
        ? ''
        : (quantity! % 1 == 0 ? quantity!.toInt().toString() : '$quantity');
    return [qty, unit].where((s) => s != null && s.isNotEmpty).join(' ');
  }
}

class MedicineDoseScheduleEntity {
  const MedicineDoseScheduleEntity({
    required this.id,
    required this.scheduleType,
    required this.isPrn,
    required this.doseTimes,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String scheduleType;
  final bool isPrn;
  final bool isActive;
  final List<MedicineDoseTimeEntity> doseTimes;

  /// Course bounds. Both null means the schedule runs indefinitely — which is
  /// every schedule created before duration was supported.
  final String? startDate;
  final String? endDate;

  DateTime? get endsOn => endDate == null ? null : DateTime.tryParse(endDate!);

  bool get isCourse => endDate != null;

  /// Whole days left, counting today. Null when open-ended; 0 once the last
  /// day has passed.
  int? get daysRemaining {
    final end = endsOn;
    if (end == null) return null;
    final now = DateTime.now();
    final diff = DateTime(end.year, end.month, end.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return diff < 0 ? 0 : diff + 1;
  }
}

/// One movement of a medicine's stock — a top-up, or a unit deducted when a
/// dose was marked taken.
class StockHistoryEntryEntity {
  const StockHistoryEntryEntity({
    required this.id,
    required this.action,
    required this.quantityChange,
    required this.quantityAfter,
    this.createdAt,
  });

  final String id;
  final String action;
  final int quantityChange;
  final int quantityAfter;
  final String? createdAt;
}

class MedicineStockEntity {
  const MedicineStockEntity({
    required this.id,
    required this.quantity,
    this.minThreshold = 0,
    this.expiryDate,
    this.history = const [],
  });

  final String id;
  final int quantity;
  final int minThreshold;
  final String? expiryDate;

  /// Most recent movements first, as the API returns them.
  final List<StockHistoryEntryEntity> history;

  /// Running totals oldest → newest, for a trend line.
  List<double> get trend =>
      history.reversed.map((h) => h.quantityAfter.toDouble()).toList();

  /// Level right after the most recent top-up. Falls back to the current
  /// quantity when the window of history the API returns holds no top-up.
  int get lastRefillLevel {
    for (final h in history) {
      if (h.action == 'CREATED' || h.action == 'INCREMENTED') {
        return h.quantityAfter;
      }
    }
    return quantity;
  }

  /// Units consumed since that top-up.
  int get usedSinceRefill =>
      (lastRefillLevel - quantity).clamp(0, lastRefillLevel);
}

class UserMedicineEntity {
  const UserMedicineEntity({
    required this.id,
    required this.scope,
    required this.active,
    required this.addedAt,
    required this.doseSchedules,
    this.medicine,
    this.product,
    this.customName,
    this.stock,
    this.effectiveStock,
    this.patientProfileId,
    this.patientName,
  });

  /// Below this many units the cabinet flags the entry as low stock.
  static const int lowStockThreshold = 5;

  final String id;
  final String scope;
  final bool active;
  final String addedAt;

  /// Exactly one of [medicine] / [product] is set — or neither, for entries
  /// the reminder quick-add created from a bare name (customName only).
  final CatalogMedicineEntity? medicine;
  final CatalogMedicineEntity? product;

  final List<MedicineDoseScheduleEntity> doseSchedules;
  final String? customName;
  final MedicineStockEntity? stock;
  final MedicineStockEntity? effectiveStock;

  /// The patient profile this entry was added for, when a caretaker added it
  /// on someone else's behalf. Null means it is the owner's own medicine.
  final String? patientProfileId;
  final String? patientName;

  /// Who the medicine is for, in words.
  String get forWhom => patientName ?? 'You';

  /// Whichever catalog this entry points at, if any.
  CatalogMedicineEntity? get catalog => medicine ?? product;

  String get displayName => customName ?? catalog?.name ?? 'Unnamed medicine';
  String get genericName => catalog?.genericName ?? '';
  String get strength => catalog?.strength ?? '';
  String get form => catalog?.dosageForm ?? '';
  String get description => catalog?.description ?? '';
  String get primarilyUsedFor => catalog?.primarilyUsedFor ?? '';
  String get manufacturer => catalog?.manufacturer ?? '';
  String get packing => catalog?.productPacking ?? '';
  String get unit => catalog?.productUnit ?? '';
  String get storageConditions => catalog?.storageConditions ?? '';
  List<String> get compositions => catalog?.compositions ?? const [];
  List<String> get sideEffects => catalog?.sideEffects ?? const [];
  List<String> get contraindications => catalog?.contraindications ?? const [];
  List<String> get drugInteractions => catalog?.drugInteractions ?? const [];

  /// "500mg · Tablet", or a single value when only one is known.
  String get subtitle =>
      [strength, form].where((s) => s.isNotEmpty).join(' · ');

  bool get isShared => scope == 'SHARED_MASTER' || scope == 'SHARED_MEMBER';
  bool get isSharedMaster => scope == 'SHARED_MASTER';
  bool get isSharedMember => scope == 'SHARED_MEMBER';

  /// PRN ("as needed") only when there is a schedule and every one of them is
  /// PRN — a medicine with one timed schedule is not as-needed just because a
  /// PRN schedule sits alongside it.
  bool get isPrn =>
      doseSchedules.isNotEmpty && doseSchedules.every((s) => s.isPrn);

  /// SHARED_MEMBER entries hold no stock of their own; the master's is served
  /// as effectiveStock.
  MedicineStockEntity? get activeStock => effectiveStock ?? stock;
  int get stockQuantity => activeStock?.quantity ?? 0;
  String? get expiryDate => activeStock?.expiryDate;

  bool get hasStock => activeStock != null;
  bool get isLowStock => hasStock && stockQuantity < lowStockThreshold;

  /// Every scheduled HH:mm across all active, non-PRN schedules, sorted.
  List<String> get doseTimes {
    final times = <String>[
      for (final s in doseSchedules)
        if (s.isActive && !s.isPrn)
          for (final d in s.doseTimes) d.scheduledTime,
    ]..sort();
    return times;
  }

  /// Food instruction of the first dose time that carries one.
  String? get foodTiming {
    for (final s in doseSchedules) {
      for (final d in s.doseTimes) {
        if (d.foodTiming != null && d.foodTiming!.isNotEmpty) {
          return d.foodTiming;
        }
      }
    }
    return null;
  }

  /// The soonest-ending fixed course among the active schedules, if any.
  /// Open-ended schedules are ignored — a medicine is only "a course" when
  /// every reminder for it stops on a date.
  MedicineDoseScheduleEntity? get course {
    MedicineDoseScheduleEntity? soonest;
    for (final s in doseSchedules) {
      if (!s.isActive || !s.isCourse) continue;
      if (soonest == null || s.endsOn!.isBefore(soonest.endsOn!)) soonest = s;
    }
    return soonest;
  }

  /// Days left in that course, counting today. Null when nothing is bounded.
  int? get courseDaysRemaining => course?.daysRemaining;

  /// Dose amount of the first dose time that carries one (e.g. "1 tablet").
  String? get doseLabel {
    for (final s in doseSchedules) {
      for (final d in s.doseTimes) {
        if (d.doseLabel.isNotEmpty) return d.doseLabel;
      }
    }
    return null;
  }
}
