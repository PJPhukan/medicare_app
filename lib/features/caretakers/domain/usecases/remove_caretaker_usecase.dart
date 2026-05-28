import '../repositories/caretakers_repository.dart';

class RemoveCaretakerUseCase {
  const RemoveCaretakerUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<void> call(String id) => _repo.removeCaretaker(id);
}
