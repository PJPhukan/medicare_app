import '../entities/medicine_entity.dart';

abstract interface class MedicinesRepository {
  Future<List<UserMedicineEntity>> getMyMedicines();

  Future<List<CatalogMedicineEntity>> searchCatalog(String query);

  Future<UserMedicineEntity> addPersonalMedicine({
    required String medicineId,
    String? customName,
    String? patientProfileId,
  });

  Future<void> deleteMedicine(String id);
}
