import '../entities/notification_entity.dart';

abstract interface class NotificationsRepository {
  Future<({List<NotificationEntity> notifications, int unreadCount})>
      getNotifications({int take});
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> registerPushToken(String token, String platform);
}
