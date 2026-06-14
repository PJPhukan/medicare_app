import '../repositories/pro_profile_repository.dart';

class RequestNewAreaUseCase {
  const RequestNewAreaUseCase(this._repo);

  final ProProfileRepository _repo;

  Future<void> call({
    required String name,
    required String pincodes,
    required String state,
    required String district,
  }) =>
      _repo.requestNewArea(
        name: name,
        pincodes: pincodes,
        state: state,
        district: district,
      );
}
