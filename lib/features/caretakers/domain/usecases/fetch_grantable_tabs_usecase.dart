import '../entities/caretaker_entity.dart';
import '../repositories/caretakers_repository.dart';

class FetchGrantableTabsUseCase {
  const FetchGrantableTabsUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<List<GrantableTabEntity>> call() => _repo.getGrantableTabs();
}
