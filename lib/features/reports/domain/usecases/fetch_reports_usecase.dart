import '../entities/report_entity.dart';
import '../repositories/reports_repository.dart';

class FetchReportsUseCase {
  const FetchReportsUseCase(this._repo);

  final ReportsRepository _repo;

  Future<List<MedicalReportEntity>> call() => _repo.getMyReports();
}
