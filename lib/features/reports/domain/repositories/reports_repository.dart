import '../entities/report_entity.dart';

abstract interface class ReportsRepository {
  Future<List<MedicalReportEntity>> getMyReports();
  Future<void> deleteReport(String id);
  Future<MedicalReportEntity> uploadReport({
    required String filePath,
    required String title,
    String? description,
    String? reportDate,
    List<String>? tags,
  });
}
