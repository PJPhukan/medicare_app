import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/adherence_model.dart';
import '../models/insight_model.dart';

class InsightsRemoteDataSource {
  const InsightsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Insight>> getInsights() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/insights',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Insight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Adherence> getAdherence({int periodDays = 7}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/insights/adherence',
      queryParameters: {'periodDays': periodDays},
    );
    return Adherence.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
