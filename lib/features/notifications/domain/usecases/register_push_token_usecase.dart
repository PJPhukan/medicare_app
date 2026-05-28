import '../repositories/notifications_repository.dart';

class RegisterPushTokenUseCase {
  const RegisterPushTokenUseCase(this._repo);

  final NotificationsRepository _repo;

  Future<void> call(String token, String platform) =>
      _repo.registerPushToken(token, platform);
}
