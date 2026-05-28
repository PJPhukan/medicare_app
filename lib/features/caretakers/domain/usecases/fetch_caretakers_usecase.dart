import '../entities/caretaker_entity.dart';
import '../repositories/caretakers_repository.dart';

class FetchCaretakersUseCase {
  const FetchCaretakersUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<List<CaretakerEntity>> call() => _repo.getCaretakers();
}
