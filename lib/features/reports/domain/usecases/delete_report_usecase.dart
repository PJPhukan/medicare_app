import '../repositories/reports_repository.dart';

class DeleteReportUseCase {
  const DeleteReportUseCase(this._repo);

  final ReportsRepository _repo;

  Future<void> call(String id) => _repo.deleteReport(id);
}
