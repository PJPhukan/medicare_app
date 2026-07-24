import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/reminder_schedule_model.dart';

/// Translates the app's schedule dialect into the backend contract:
/// WEEKDAYS / WEEKENDS become WEEKLY with an explicit daysOfWeek, and the
/// day-picker-less CUSTOM pins all seven days (valid CUSTOM, reads back as
/// "Custom" in the UI). Used by the online create AND the offline sync queue
/// so both paths always send the same shape.
Map<String, dynamic> buildCreateSchedulePayload({
  required String medicineName,
  required List<Map<String, String>> doseTimes,
  required String scheduleType,
  required String timezone,
  int preNotifyMinutes = 10,
}) {
  final (apiType, days) = switch (scheduleType) {
    'WEEKDAYS' => ('WEEKLY', [1, 2, 3, 4, 5]),
    'WEEKENDS' => ('WEEKLY', [6, 7]),
    'CUSTOM' => ('CUSTOM', [1, 2, 3, 4, 5, 6, 7]),
    _ => ('DAILY', null),
  };
  return {
    'medicineName': medicineName,
    'doseTimes': doseTimes,
    'scheduleType': apiType,
    if (days != null) 'daysOfWeek': days,
    'timezone': timezone,
    'preNotifyMinutes': preNotifyMinutes,
  };
}

class RemindersRemoteDataSource {
  const RemindersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ReminderScheduleModel>> getSchedules() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.reminderSchedules);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ReminderScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReminderScheduleModel> createSchedule({
    required String medicineName,
    required List<Map<String, String>> doseTimes,
    required String scheduleType,
    required String timezone,
    int preNotifyMinutes = 10,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.reminderSchedules,
      data: buildCreateSchedulePayload(
        medicineName: medicineName,
        doseTimes: doseTimes,
        scheduleType: scheduleType,
        timezone: timezone,
        preNotifyMinutes: preNotifyMinutes,
      ),
    );
    return ReminderScheduleModel.fromJson(
        res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSchedule(String id) async {
    await _dio.delete<void>('${ApiConstants.reminderSchedules}/$id');
  }

  Future<void> toggleSchedule(String id, {required bool isActive}) async {
    await _dio.patch<void>(
      '${ApiConstants.reminderSchedules}/$id',
      data: {'isActive': isActive},
    );
  }
}
