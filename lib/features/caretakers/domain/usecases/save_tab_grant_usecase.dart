import '../repositories/caretakers_repository.dart';

class SaveTabGrantUseCase {
  const SaveTabGrantUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<void> call({
    required String relationshipId,
    required String tabId,
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  }) =>
      _repo.saveTabGrant(
        relationshipId: relationshipId,
        tabId: tabId,
        opView: opView,
        opAdd: opAdd,
        opEdit: opEdit,
        opDelete: opDelete,
        opShare: opShare,
      );
}
