import '../../domain/entities/caretaker_entity.dart';
import '../../domain/repositories/caretakers_repository.dart';
import '../datasources/caretakers_remote_datasource.dart';

class CaretakersRepositoryImpl implements CaretakersRepository {
  const CaretakersRepositoryImpl(this._ds);

  final CaretakersRemoteDataSource _ds;

  @override
  Future<List<CaretakerEntity>> getCaretakers() => _ds.getCaretakers();

  @override
  Future<List<PendingCaretakerInviteEntity>> getPendingInvites() => _ds.getPendingInvites();

  @override
  Future<List<GrantableTabEntity>> getGrantableTabs() => _ds.getGrantableTabs();

  @override
  Future<List<ManageablePatientEntity>> getManageablePatients() => _ds.getManageablePatients();

  @override
  Future<InviteCaretakerResult> inviteCaretaker({
    required String name,
    String? phone,
    String? email,
    required GranteeRole role,
    required List<String> patientIds,
    DateTime? expiresAt,
  }) =>
      _ds.inviteCaretaker(
        name: name,
        phone: phone,
        email: email,
        role: role,
        patientIds: patientIds,
        expiresAt: expiresAt,
      );

  @override
  Future<void> cancelInvite(String inviteId) => _ds.cancelInvite(inviteId);

  @override
  Future<void> revokeCaretaker(String relationshipId) => _ds.revokeCaretaker(relationshipId);

  @override
  Future<void> saveTabGrant({
    required String relationshipId,
    required String tabId,
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  }) =>
      _ds.saveTabGrant(
        relationshipId: relationshipId,
        tabId: tabId,
        opView: opView,
        opAdd: opAdd,
        opEdit: opEdit,
        opDelete: opDelete,
        opShare: opShare,
      );
}
