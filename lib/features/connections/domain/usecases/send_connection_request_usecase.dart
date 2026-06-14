import '../repositories/connections_repository.dart';

class SendConnectionRequestUseCase {
  const SendConnectionRequestUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<void> call({
    required String professionalId,
    required String planType,
    String? areaId,
    String? note,
  }) =>
      _repo.sendConnectionRequest(
        professionalId: professionalId,
        planType: planType,
        areaId: areaId,
        note: note,
      );
}
