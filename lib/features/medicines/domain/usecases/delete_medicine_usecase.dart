import '../repositories/medicines_repository.dart';

class DeleteMedicineUseCase {
  const DeleteMedicineUseCase(this._repository);

  final MedicinesRepository _repository;

  Future<void> call(String id) => _repository.deleteMedicine(id);
}
