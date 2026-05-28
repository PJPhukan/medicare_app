import '../repositories/notifications_repository.dart';

class MarkReadUseCase {
  const MarkReadUseCase(this._repo);

  final NotificationsRepository _repo;

  Future<void> call(String id) => _repo.markRead(id);
}
