import '../../../../core/local_db/sync_queue.dart';
import '../../domain/entities/vital_config_entity.dart';
import '../../domain/entities/vital_reading_entity.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../datasources/vitals_remote_datasource.dart';

class VitalsRepositoryImpl implements VitalsRepository {
  const VitalsRepositoryImpl(
    this._ds,
    this._queue,
    this._isOnline,
  );

  final VitalsRemoteDataSource _ds;
  final SyncQueue _queue;
  final bool Function() _isOnline;

  @override
  Future<List<VitalConfigEntity>> getConfigs() => _ds.getConfigs();

  @override
  Future<List<VitalReadingEntity>> getMyVitals() => _ds.getMyVitals();

  @override
  Future<VitalReadingEntity> addReading({
    required String vitalConfigId,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) async {
    if (_isOnline()) {
      return _ds.addReading(
        vitalConfigId: vitalConfigId,
        values: values,
        measuredAt: measuredAt,
        notes: notes,
      );
    } else {
      await _queue.enqueue(SyncOperation.create(
        feature: 'vitals',
        action: 'add_reading',
        payload: {
          'vitalConfigId': vitalConfigId,
          'values': values,
          if (notes != null) 'notes': notes,
          if (measuredAt != null) 'measuredAt': measuredAt,
        },
      ));
      // Return a provisional entity so callers can do an optimistic update.
      throw UnsupportedError(
        'Offline: reading queued for sync. '
        'Refresh when connectivity is restored.',
      );
    }
  }

  @override
  Future<VitalReadingEntity> updateReading({
    required String id,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) async {
    // Editing needs a live connection — there's no offline replay handler for
    // updates (unlike create), so we don't silently queue an unhandled op.
    if (!_isOnline()) {
      throw UnsupportedError('Editing a reading requires an internet connection.');
    }
    return _ds.updateReading(
      id: id,
      values: values,
      measuredAt: measuredAt,
      notes: notes,
    );
  }
}
