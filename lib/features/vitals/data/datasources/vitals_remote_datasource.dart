import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/vital_config_model.dart';
import '../models/vital_reading_model.dart';

class VitalsRemoteDataSource {
  const VitalsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<VitalConfig>> getConfigs() async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiConstants.vitalConfigs);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => VitalConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VitalReading>> getMyVitals() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.myVitals);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => VitalReading.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VitalReading> addReading({
    required String vitalConfigId,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.myVitals,
      data: {
        'vitalConfigId': vitalConfigId,
        'values': values,
        if (measuredAt != null) 'measuredAt': measuredAt,
        if (notes != null) 'notes': notes,
      },
    );
    return VitalReading.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
