import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/reminder_schedule_model.dart';

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
    required String reminderType,
    required String scheduleType,
    int preNotifyMinutes = 10,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.reminderSchedules,
      data: {
        'medicineName': medicineName,
        'doseTimes': doseTimes,
        'reminderType': reminderType,
        'scheduleType': scheduleType,
        'preNotifyMinutes': preNotifyMinutes,
      },
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
