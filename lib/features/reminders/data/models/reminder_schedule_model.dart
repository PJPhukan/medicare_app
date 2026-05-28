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

  factory ReminderScheduleModel.fromJson(Map<String, dynamic> json) =>
      ReminderScheduleModel(
        id: json['id'] as String,
        medicineName: (json['medicineName'] ?? json['name'] ?? 'Medicine') as String,
        reminderType: (json['reminderType'] ?? 'MEDICINE') as String,
        scheduleType: (json['scheduleType'] ?? 'DAILY') as String,
        doseTimes: (json['doseTimes'] as List<dynamic>? ?? [])
            .map((e) => ReminderDoseTime.fromJson(e as Map<String, dynamic>))
            .toList(),
        preNotifyMinutes: (json['preNotifyMinutes'] as int?) ?? 10,
        isActive: (json['isActive'] as bool?) ?? true,
      );

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
