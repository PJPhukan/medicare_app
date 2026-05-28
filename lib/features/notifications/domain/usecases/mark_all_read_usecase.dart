import '../repositories/notifications_repository.dart';

class MarkAllReadUseCase {
  const MarkAllReadUseCase(this._repo);

  final NotificationsRepository _repo;

  Future<void> call() => _repo.markAllRead();
}
