import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/report_model.dart';

class ReportsRemoteDataSource {
  const ReportsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MedicalReport>> getMyReports() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.reports);
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => MedicalReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReport(String id) async {
    await _dio.delete<void>('${ApiConstants.reports}/$id');
  }

  Future<MedicalReport> uploadReport({
    required String filePath,
    required String title,
    String? description,
    String? reportDate,
    List<String>? tags,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'title': title,
      if (description != null) 'description': description,
      if (reportDate != null) 'reportDate': reportDate,
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.reports,
      data: form,
    );
    return MedicalReport.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
