import '../../../../core/local_db/sync_queue.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(
    this._ds,
    this._queue,
    this._isOnline,
  );

  final ScheduleRemoteDataSource _ds;
  final SyncQueue _queue;
  final bool Function() _isOnline;

  @override
  Future<List<DoseEntity>> getTodayDoses({String? date}) =>
      _ds.getTodayDoses(date: date);

  @override
  Future<void> markDose({
    required String doseTimeId,
    required String status,
    String? scheduledDate,
    String? skippedReason,
  }) async {
    if (_isOnline()) {
      await _ds.markDose(
        doseTimeId: doseTimeId,
        status: status,
        scheduledDate: scheduledDate,
        skippedReason: skippedReason,
      );
    } else {
      await _queue.enqueue(SyncOperation.create(
        feature: 'schedule',
        action: 'mark_dose',
        payload: {
          'doseTimeId': doseTimeId,
          'status': status,
          if (scheduledDate != null) 'scheduledDate': scheduledDate,
          if (skippedReason != null) 'skippedReason': skippedReason,
        },
      ));
    }
  }
}
