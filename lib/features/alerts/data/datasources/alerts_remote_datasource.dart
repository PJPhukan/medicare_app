import 'package:dio/dio.dart';
import '../models/alert_model.dart';

class AlertsRemoteDataSource {
  const AlertsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Alert>> getAlerts() async {
    final res = await _dio.get<Map<String, dynamic>>('/alerts');
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Alert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> dismissAlert(String id) async {
    await _dio.patch<void>('/alerts/$id/dismiss');
  }
}
