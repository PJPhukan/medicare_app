import '../entities/caretaker_entity.dart';

abstract interface class CaretakersRepository {
  Future<List<CaretakerEntity>> getCaretakers();
  Future<List<PendingCaretakerInviteEntity>> getPendingInvites();
  Future<List<GrantableTabEntity>> getGrantableTabs();
  Future<List<ManageablePatientEntity>> getManageablePatients();

  Future<InviteCaretakerResult> inviteCaretaker({
    required String name,
    String? phone,
    String? email,
    required GranteeRole role,
    required List<String> patientIds,
    DateTime? expiresAt,
  });

  Future<void> cancelInvite(String inviteId);
  Future<void> revokeCaretaker(String relationshipId);

  Future<void> saveTabGrant({
    required String relationshipId,
    required String tabId,
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  });
}
