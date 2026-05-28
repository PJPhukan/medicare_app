import '../entities/medicine_entity.dart';
import '../repositories/medicines_repository.dart';

class FetchMedicinesUseCase {
  const FetchMedicinesUseCase(this._repository);

  final MedicinesRepository _repository;

  Future<List<UserMedicineEntity>> call() => _repository.getMyMedicines();
}
