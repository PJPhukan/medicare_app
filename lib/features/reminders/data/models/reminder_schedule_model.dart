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
    this.preNotifyMinutes = 10,
    this.isActive = true,
  });

  final String id;
  final String medicineName;

  /// 'MEDICINE' | 'VITAL' | 'APPOINTMENT' | 'OTHER'
  final String reminderType;

  /// 'DAILY' | 'WEEKDAYS' | 'WEEKENDS' | 'CUSTOM'
  final String scheduleType;

  final List<ReminderDoseTime> doseTimes;
  final int preNotifyMinutes;
  final bool isActive;

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
    );
  }

  ReminderScheduleModel copyWith({bool? isActive}) => ReminderScheduleModel(
        id: id,
        medicineName: medicineName,
        reminderType: reminderType,
        scheduleType: scheduleType,
        doseTimes: doseTimes,
        preNotifyMinutes: preNotifyMinutes,
        isActive: isActive ?? this.isActive,
      );
}
