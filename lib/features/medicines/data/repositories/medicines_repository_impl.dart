import '../../../../core/local_db/sync_queue.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../datasources/medicines_remote_datasource.dart';

class MedicinesRepositoryImpl implements MedicinesRepository {
  const MedicinesRepositoryImpl(
    this._ds,
    this._queue,
    this._isOnline,
  );

  final MedicinesRemoteDataSource _ds;
  final SyncQueue _queue;
  final bool Function() _isOnline;

  @override
  Future<List<UserMedicineEntity>> getMyMedicines() => _ds.getMyMedicines();

  @override
  Future<List<CatalogMedicineEntity>> searchCatalog(String query) =>
      _ds.searchCatalog(query);

  @override
  Future<UserMedicineEntity> addPersonalMedicine({
    required String medicineId,
    String? customName,
    String? patientProfileId,
  }) =>
      _ds.addPersonalMedicine(
        medicineId: medicineId,
        customName: customName,
        patientProfileId: patientProfileId,
      );

  @override
  Future<void> deleteMedicine(String id) async {
    if (_isOnline()) {
      await _ds.deleteMedicine(id);
    } else {
      await _queue.enqueue(SyncOperation.create(
        feature: 'medicines',
        action: 'delete_medicine',
        payload: {'id': id},
      ));
    }
  }
}
