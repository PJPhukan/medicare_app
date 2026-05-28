import '../entities/caretaker_entity.dart';

abstract interface class CaretakersRepository {
  Future<List<CaretakerEntity>> getCaretakers();
  Future<void> inviteCaretaker({
    required String phone,
    required String relationshipId,
    required List<String> permissions,
  });
  Future<void> removeCaretaker(String id);
}
