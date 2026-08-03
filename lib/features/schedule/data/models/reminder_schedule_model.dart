/// One dose time being created. Mirrors the backend's `doseTimes[]` entry, so
/// this is what both the online create and the offline sync payload serialize.
class DoseTimeInput {
  const DoseTimeInput({
    required this.scheduledTime,
    this.quantity,
    this.unit,
    this.foodTiming = 'ANY',
  });

  final String scheduledTime; // "HH:MM"
  final double? quantity;
  final String? unit;
  final String foodTiming; // BEFORE | WITH | AFTER | WITHOUT | ANY

  Map<String, dynamic> toJson() => {
        'scheduledTime': scheduledTime,
        if (quantity != null) 'quantity': quantity,
        if (unit != null && unit!.isNotEmpty) 'unit': unit,
        'foodTiming': foodTiming.toUpperCase(),
      };
}

/// Splits a free-text dose amount into the numeric quantity and unit the
/// backend stores separately — "2 tablets" becomes (2, "tablets").
///
/// Sending the whole string as `unit` (what the app used to do) made the dose
/// row render its quantity twice, e.g. "1 1 tablet".
({double? quantity, String? unit}) parseDoseAmount(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return (quantity: null, unit: null);
  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(text);
  if (match == null) return (quantity: null, unit: text);
  final qty = double.tryParse(match.group(1)!);
  final unit = match.group(2)!.trim();
  // Unparseable leading number — keep the raw text as the unit rather than
  // silently dropping what the user typed.
  if (qty == null) return (quantity: null, unit: text);
  return (quantity: qty, unit: unit.isEmpty ? null : unit);
}

/// One dose time in a schedule edit. A null [id] creates a new row; an id
/// updates that row in place, preserving its adherence history.
class DoseTimeEdit {
  const DoseTimeEdit({
    required this.scheduledTime,
    this.id,
    this.quantity,
    this.unit,
    this.foodTiming,
  });

  factory DoseTimeEdit.from(ReminderDoseTime dose) => DoseTimeEdit(
        id: dose.id,
        scheduledTime: dose.scheduledTime,
        unit: dose.unit,
        foodTiming: dose.foodTiming,
      );

  final String? id;
  final String scheduledTime;
  final num? quantity;
  final String? unit;
  final String? foodTiming;

  DoseTimeEdit copyWith({
    String? scheduledTime,
    num? quantity,
    String? unit,
    String? foodTiming,
  }) =>
      DoseTimeEdit(
        id: id,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        foodTiming: foodTiming ?? this.foodTiming,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'scheduledTime': scheduledTime,
        if (quantity != null) 'quantity': quantity,
        if (unit != null && unit!.isNotEmpty) 'unit': unit,
        if (foodTiming != null && foodTiming!.isNotEmpty)
          'foodTiming': foodTiming!.toUpperCase(),
      };
}

class ReminderDoseTime {
  const ReminderDoseTime({
    required this.id,
    required this.scheduledTime,
    this.unit,
    this.foodTiming,
  });

  final String id;
  final String scheduledTime; // "HH:MM"
  final String? unit;
  final String? foodTiming; // "BEFORE" | "WITH" | "AFTER"

  factory ReminderDoseTime.fromJson(Map<String, dynamic> json) =>
      ReminderDoseTime(
        id: json['id'] as String,
        scheduledTime: json['scheduledTime'] as String,
        unit: json['unit'] as String?,
        foodTiming: json['foodTiming'] as String?,
      );
}

class ReminderScheduleModel {
  const ReminderScheduleModel({
    required this.id,
    required this.medicineName,
    required this.reminderType,
    required this.scheduleType,
    required this.doseTimes,
    this.userMedicineId,
    this.preNotifyMinutes = 10,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  final String id;

  /// The cabinet entry this schedule belongs to. Null only for the temporary
  /// local model an offline create builds before the backend assigns one.
  final String? userMedicineId;

  final String medicineName;

  /// 'MEDICINE' | 'VITAL' | 'APPOINTMENT' | 'OTHER'
  final String reminderType;

  /// 'DAILY' | 'WEEKDAYS' | 'WEEKENDS' | 'CUSTOM'
  final String scheduleType;

  final List<ReminderDoseTime> doseTimes;
  final int preNotifyMinutes;
  final bool isActive;

  /// Course bounds. Both null means the schedule runs indefinitely, which is
  /// what every schedule created before duration existed looks like.
  final String? startDate;
  final String? endDate;

  DateTime? get endsOn => endDate == null ? null : DateTime.tryParse(endDate!);

  /// Whole days left in the course, counting today. Null when open-ended,
  /// 0 once the last day has passed.
  int? get daysRemaining {
    final end = endsOn;
    if (end == null) return null;
    final today = DateTime.now();
    final diff = DateTime(end.year, end.month, end.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  bool get isCourse => endDate != null;

  factory ReminderScheduleModel.fromJson(Map<String, dynamic> json) {
    // Backend shape: the display name lives on the included userMedicine
    // (customName, or the linked catalog medicine/product name).
    final userMedicine = json['userMedicine'] as Map<String, dynamic>?;
    final medicineName = (json['medicineName'] ??
        userMedicine?['customName'] ??
        (userMedicine?['medicine'] as Map<String, dynamic>?)?['name'] ??
        (userMedicine?['product'] as Map<String, dynamic>?)?['name'] ??
        'Medicine') as String;

    // Backend WEEKLY + daysOfWeek maps back to the app's WEEKDAYS/WEEKENDS
    // dialect; anything else falls through (_repeatLabel shows it as Custom).
    final days = (json['daysOfWeek'] as List<dynamic>?)?.cast<int>();
    final rawType = (json['scheduleType'] ?? 'DAILY') as String;
    final scheduleType = switch ((rawType, days)) {
      ('WEEKLY', [1, 2, 3, 4, 5]) => 'WEEKDAYS',
      ('WEEKLY', [6, 7]) => 'WEEKENDS',
      _ => rawType,
    };

    final rawDoseTimes =
        (json['doseTimes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return ReminderScheduleModel(
      id: json['id'] as String,
      userMedicineId: json['userMedicineId']?.toString(),
      medicineName: medicineName,
      reminderType: (json['reminderType'] ?? 'MEDICINE') as String,
      scheduleType: scheduleType,
      doseTimes: rawDoseTimes.map(ReminderDoseTime.fromJson).toList(),
      // Backend stores the lead time per dose time, not on the schedule.
      preNotifyMinutes: (json['preNotifyMinutes'] ??
          (rawDoseTimes.isNotEmpty
              ? rawDoseTimes.first['preNotifyMinutes']
              : null) ??
          10) as int,
      isActive: (json['isActive'] ?? json['active'] ?? true) as bool,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  ReminderScheduleModel copyWith({bool? isActive}) => ReminderScheduleModel(
        id: id,
        userMedicineId: userMedicineId,
        medicineName: medicineName,
        reminderType: reminderType,
        scheduleType: scheduleType,
        doseTimes: doseTimes,
        preNotifyMinutes: preNotifyMinutes,
        isActive: isActive ?? this.isActive,
        startDate: startDate,
        endDate: endDate,
      );
}
