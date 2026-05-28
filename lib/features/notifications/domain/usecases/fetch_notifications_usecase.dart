import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class FetchNotificationsUseCase {
  const FetchNotificationsUseCase(this._repo);

  final NotificationsRepository _repo;

  Future<({List<NotificationEntity> notifications, int unreadCount})> call({
    int take = 50,
  }) =>
      _repo.getNotifications(take: take);
}
