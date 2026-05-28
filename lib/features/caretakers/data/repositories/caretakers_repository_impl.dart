import '../../domain/entities/caretaker_entity.dart';
import '../../domain/repositories/caretakers_repository.dart';
import '../datasources/caretakers_remote_datasource.dart';

class CaretakersRepositoryImpl implements CaretakersRepository {
  const CaretakersRepositoryImpl(this._ds);

  final CaretakersRemoteDataSource _ds;

  @override
  Future<List<CaretakerEntity>> getCaretakers() async {
    final List<CaretakerEntity> list = await _ds.getCaretakers();
    return list;
  }

  @override
  Future<void> inviteCaretaker({
    required String phone,
    required String relationshipId,
    required List<String> permissions,
  }) =>
      _ds.inviteCaretaker(
        phone: phone,
        relationshipId: relationshipId,
        permissions: permissions,
      );

  @override
  Future<void> removeCaretaker(String id) => _ds.removeCaretaker(id);
}
