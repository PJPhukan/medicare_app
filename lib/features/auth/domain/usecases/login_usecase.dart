import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);

  final AuthRepository _repo;

  Future<({String token, UserEntity user, bool isNewUser})> call({
    required String identifier,
    required String password,
  }) =>
      _repo.login(identifier: identifier, password: password);
}
