import '../repositories/caretakers_repository.dart';

class CancelInviteUseCase {
  const CancelInviteUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<void> call(String inviteId) => _repo.cancelInvite(inviteId);
}
