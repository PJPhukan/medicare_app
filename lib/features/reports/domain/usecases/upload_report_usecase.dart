import '../entities/report_entity.dart';
import '../repositories/reports_repository.dart';

class UploadReportUseCase {
  const UploadReportUseCase(this._repo);

  final ReportsRepository _repo;

  Future<MedicalReportEntity> call({
    required String filePath,
    required String title,
    String? description,
    String? reportDate,
    List<String>? tags,
  }) =>
      _repo.uploadReport(
        filePath: filePath,
        title: title,
        description: description,
        reportDate: reportDate,
        tags: tags,
      );
}
