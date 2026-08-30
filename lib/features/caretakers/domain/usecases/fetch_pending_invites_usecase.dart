import '../entities/caretaker_entity.dart';
import '../repositories/caretakers_repository.dart';

class FetchPendingInvitesUseCase {
  const FetchPendingInvitesUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<List<PendingCaretakerInviteEntity>> call() => _repo.getPendingInvites();
}
