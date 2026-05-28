import '../../../../core/local_db/sync_queue.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._ds, this._queue, this._isOnline);

  final ReportsRemoteDataSource _ds;
  final SyncQueue _queue;
  final bool Function() _isOnline;

  @override
  Future<List<MedicalReportEntity>> getMyReports() async {
    final List<MedicalReportEntity> list = await _ds.getMyReports();
    return list;
  }

  @override
  Future<void> deleteReport(String id) async {
    if (_isOnline()) {
      await _ds.deleteReport(id);
    } else {
      await _queue.enqueue(SyncOperation.create(
        feature: 'reports',
        action: 'delete_report',
        payload: {'id': id},
      ));
    }
  }

  @override
  Future<MedicalReportEntity> uploadReport({
    required String filePath,
    required String title,
    String? description,
    String? reportDate,
    List<String>? tags,
  }) async {
    final MedicalReportEntity report = await _ds.uploadReport(
      filePath: filePath,
      title: title,
      description: description,
      reportDate: reportDate,
      tags: tags,
    );
    return report;
  }
}
