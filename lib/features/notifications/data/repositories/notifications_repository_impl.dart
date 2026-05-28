import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._ds);

  final NotificationsRemoteDataSource _ds;

  @override
  Future<({List<NotificationEntity> notifications, int unreadCount})>
      getNotifications({int take = 50}) async {
    final result = await _ds.getNotifications(take: take);
    final List<NotificationEntity> notifs = result.notifications;
    return (notifications: notifs, unreadCount: result.unreadCount);
  }

  @override
  Future<void> markRead(String id) => _ds.markRead(id);

  @override
  Future<void> markAllRead() => _ds.markAllRead();

  @override
  Future<void> registerPushToken(String token, String platform) =>
      _ds.registerPushToken(token, platform);
}
