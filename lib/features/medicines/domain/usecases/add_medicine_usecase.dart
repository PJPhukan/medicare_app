import '../entities/medicine_entity.dart';
import '../repositories/medicines_repository.dart';

class AddMedicineUseCase {
  const AddMedicineUseCase(this._repository);

  final MedicinesRepository _repository;

  Future<UserMedicineEntity> call({
    String? medicineId,
    String? productId,
    String? customName,
    String? patientProfileId,
  }) =>
      _repository.addPersonalMedicine(
        medicineId: medicineId,
        productId: productId,
        customName: customName,
        patientProfileId: patientProfileId,
      );
}
