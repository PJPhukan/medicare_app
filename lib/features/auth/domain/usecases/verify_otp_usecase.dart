import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repo);

  final AuthRepository _repo;

  Future<({String token, UserEntity user, bool isNewUser})> call({
    required String identifier,
    required String otp,
  }) =>
      _repo.verifyOtp(identifier: identifier, otp: otp);
}
