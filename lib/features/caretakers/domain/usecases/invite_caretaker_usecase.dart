import '../entities/caretaker_entity.dart';
import '../repositories/caretakers_repository.dart';

class InviteCaretakerUseCase {
  const InviteCaretakerUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<InviteCaretakerResult> call({
    required String name,
    String? phone,
    String? email,
    required GranteeRole role,
    required List<String> patientIds,
    DateTime? expiresAt,
  }) =>
      _repo.inviteCaretaker(
        name: name,
        phone: phone,
        email: email,
        role: role,
        patientIds: patientIds,
        expiresAt: expiresAt,
      );
}
