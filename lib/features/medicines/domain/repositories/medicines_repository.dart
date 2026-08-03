import '../entities/medicine_entity.dart';

abstract interface class MedicinesRepository {
  Future<List<UserMedicineEntity>> getMyMedicines();

  /// One page of the merged medicine + product catalog.
  Future<CatalogPageEntity> searchCatalog(
    String query, {
    int page,
    int limit,
  });

  /// Exactly one of [medicineId] / [productId] identifies the catalog row the
  /// entry points at — the merged catalog serves both.
  Future<UserMedicineEntity> addPersonalMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    String? patientProfileId,
  });

  /// Creates the first stock entry for a medicine, or tops up an existing one.
  Future<MedicineStockEntity> addStock(
    String userMedicineId, {
    required int quantity,
    String? expiryDate,
    int? minThreshold,
  });

  /// Changes who a PERSONAL medicine is for; null means the caller.
  Future<UserMedicineEntity> reassignMedicine(
    String userMedicineId, {
    required String? patientProfileId,
  });

  /// Creates a shared bottle owned by the caller with one member per profile.
  Future<UserMedicineEntity> addSharedMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    required List<String> memberPatientProfileIds,
  });

  /// Asks an admin to add a medicine the catalog doesn't carry yet.
  Future<void> requestMedicine({required String medicineName, String? details});

  Future<void> deleteMedicine(String id);
}
