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
  Future<CatalogPageEntity> searchCatalog(
    String query, {
    int page = 1,
    int limit = 20,
  }) =>
      _ds.searchCatalog(query, page: page, limit: limit);

  @override
  Future<UserMedicineEntity> addPersonalMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    String? patientProfileId,
  }) =>
      _ds.addPersonalMedicine(
        medicineId: medicineId,
        productId: productId,
        customName: customName,
        patientProfileId: patientProfileId,
      );

  @override
  Future<MedicineStockEntity> addStock(
    String userMedicineId, {
    required int quantity,
    String? expiryDate,
    int? minThreshold,
  }) =>
      _ds.addStock(
        userMedicineId,
        quantity: quantity,
        expiryDate: expiryDate,
        minThreshold: minThreshold,
      );

  @override
  Future<UserMedicineEntity> reassignMedicine(
    String userMedicineId, {
    required String? patientProfileId,
  }) =>
      _ds.reassignMedicine(userMedicineId, patientProfileId: patientProfileId);

  @override
  Future<UserMedicineEntity> addSharedMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    required List<String> memberPatientProfileIds,
  }) =>
      _ds.addSharedMedicine(
        medicineId: medicineId,
        productId: productId,
        customName: customName,
        memberPatientProfileIds: memberPatientProfileIds,
      );

  @override
  Future<void> requestMedicine({
    required String medicineName,
    String? details,
  }) =>
      _ds.requestMedicine(medicineName: medicineName, details: details);

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
