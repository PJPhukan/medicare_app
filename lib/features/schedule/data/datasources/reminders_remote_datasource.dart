import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/reminder_schedule_model.dart';

/// Translates the app's schedule dialect into the backend contract:
/// WEEKDAYS / WEEKENDS become WEEKLY with an explicit daysOfWeek, and the
/// day-picker-less CUSTOM pins all seven days (valid CUSTOM, reads back as
/// "Custom" in the UI). Used by the online create AND the offline sync queue
/// so both paths always send the same shape.
/// Either [userMedicineId] (an existing entry in the user's cabinet) or
/// [medicineName] (quick-add, backend resolves/creates the entry) must be set.
/// Prefer [userMedicineId] — a bare name creates a UserMedicine with no catalog
/// link and no stock.
/// [startDate] / [endDate] bound a fixed course (a 5-day antibiotic). Both
/// null means the schedule runs indefinitely, which is the default. The
/// backend treats [endDate] as inclusive of that whole local day.
Map<String, dynamic> buildCreateSchedulePayload({
  String? userMedicineId,
  String? medicineName,
  required List<Map<String, dynamic>> doseTimes,
  required String scheduleType,
  required String timezone,
  bool isPrn = false,
  int preNotifyMinutes = 10,
  DateTime? startDate,
  DateTime? endDate,
}) {
  assert(userMedicineId != null || medicineName != null,
      'provide userMedicineId or medicineName');
  final (apiType, days) = switch (scheduleType) {
    'WEEKDAYS' => ('WEEKLY', [1, 2, 3, 4, 5]),
    'WEEKENDS' => ('WEEKLY', [6, 7]),
    'CUSTOM' => ('CUSTOM', [1, 2, 3, 4, 5, 6, 7]),
    'PRN' => ('PRN', null),
    _ => ('DAILY', null),
  };
  return {
    if (userMedicineId != null) 'userMedicineId': userMedicineId,
    if (medicineName != null) 'medicineName': medicineName,
    'doseTimes': doseTimes,
    'scheduleType': apiType,
    if (days != null) 'daysOfWeek': days,
    'timezone': timezone,
    if (isPrn || apiType == 'PRN') 'isPrn': true,
    'preNotifyMinutes': preNotifyMinutes,
    if (startDate != null) 'startDate': startDate.toIso8601String(),
    if (endDate != null) 'endDate': endDate.toIso8601String(),
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
    String? userMedicineId,
    String? medicineName,
    required List<Map<String, dynamic>> doseTimes,
    required String scheduleType,
    required String timezone,
    bool isPrn = false,
    int preNotifyMinutes = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.reminderSchedules,
      data: buildCreateSchedulePayload(
        userMedicineId: userMedicineId,
        medicineName: medicineName,
        doseTimes: doseTimes,
        scheduleType: scheduleType,
        timezone: timezone,
        isPrn: isPrn,
        preNotifyMinutes: preNotifyMinutes,
        startDate: startDate,
        endDate: endDate,
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

  /// Edits a schedule in place.
  ///
  /// Dose times carrying an `id` are updated rather than replaced, so their
  /// adherence history survives — DoseLog cascades on doseTimeId, and dropping
  /// a dose time deletes every log for it. Any existing id left out of
  /// [doseTimes] is therefore a deliberate removal.
  Future<ReminderScheduleModel> updateSchedule(
    String id, {
    List<Map<String, dynamic>>? doseTimes,
    String? scheduleType,
    String? timezone,
    DateTime? endDate,
    bool clearEndDate = false,
  }) async {
    final (apiType, days) = switch (scheduleType) {
      'WEEKDAYS' => ('WEEKLY', [1, 2, 3, 4, 5]),
      'WEEKENDS' => ('WEEKLY', [6, 7]),
      'CUSTOM' => ('CUSTOM', [1, 2, 3, 4, 5, 6, 7]),
      'PRN' => ('PRN', null),
      null => (null, null),
      _ => ('DAILY', null),
    };
    final res = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.reminderSchedules}/$id',
      data: {
        if (doseTimes != null) 'doseTimes': doseTimes,
        if (apiType != null) 'scheduleType': apiType,
        if (days != null) 'daysOfWeek': days,
        if (timezone != null) 'timezone': timezone,
        // null is the explicit "make it ongoing again" value, so it is only
        // sent when the caller asks for it.
        if (clearEndDate) 'endDate': null
        else if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
    );
    return ReminderScheduleModel.fromJson(
        res.data!['data'] as Map<String, dynamic>);
  }
}
