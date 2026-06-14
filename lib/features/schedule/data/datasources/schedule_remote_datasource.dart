import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/appointment_model.dart';

class ScheduleRemoteDataSource {
  const ScheduleRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TodayDose>> getTodayDoses({String? date}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.todayDoses,
      queryParameters: date != null ? {'date': date} : null,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => TodayDose.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markDose({
    required String doseTimeId,
    required String status,
    String? scheduledDate,
    String? skippedReason,
  }) async {
    await _dio.post<void>(
      '${ApiConstants.doseLogs}/$doseTimeId/mark',
      data: {
        'status': status,
        if (scheduledDate != null) 'scheduledDate': scheduledDate,
        if (skippedReason != null) 'skippedReason': skippedReason,
      },
    );
  }
}
