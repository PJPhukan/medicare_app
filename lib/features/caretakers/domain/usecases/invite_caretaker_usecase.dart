import '../repositories/caretakers_repository.dart';

class InviteCaretakerUseCase {
  const InviteCaretakerUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<void> call({
    required String phone,
    required String relationshipId,
    required List<String> permissions,
  }) =>
      _repo.inviteCaretaker(
        phone: phone,
        relationshipId: relationshipId,
        permissions: permissions,
      );
}
