import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/fetch_notifications_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/register_push_token_usecase.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      NotificationsState(
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(
    this._fetchNotifications,
    this._markRead,
    this._markAllRead,
    this._registerToken,
    this._repository,
  ) : super(const NotificationsState()) {
    load();
  }

  final FetchNotificationsUseCase _fetchNotifications;
  final MarkReadUseCase _markRead;
  final MarkAllReadUseCase _markAllRead;
  final RegisterPushTokenUseCase _registerToken;
  final NotificationsRepository _repository;

  /// Call this after login with the FCM token once Firebase is set up.
  /// Platform should be 'android' or 'ios'.
  Future<void> registerPushToken(String token, String platform) {
    AppLogger.i('Push token register → platform:$platform', tag: 'Notifications');
    return _registerToken(token, platform);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _fetchNotifications();
      state = state.copyWith(
        notifications:
            result.notifications.whereType<AppNotification>().toList(),
        unreadCount: result.unreadCount,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markRead(String id) async {
    AppLogger.i('Notification mark read → id:$id', tag: 'Notifications');
    await _markRead(id);
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id
              ? AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  createdAt: n.createdAt,
                  data: n.data,
                  readAt: DateTime.now().toIso8601String(),
                )
              : n)
          .toList(),
      unreadCount: (state.unreadCount - 1).clamp(0, 9999),
    );
  }

  Future<void> markAllRead() async {
    AppLogger.i('Notifications mark all read', tag: 'Notifications');
    await _markAllRead();
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                data: n.data,
                readAt: n.readAt ?? DateTime.now().toIso8601String(),
              ))
          .toList(),
      unreadCount: 0,
    );
  }

  void dismiss(String id) {
    AppLogger.i('Notification dismiss → id:$id', tag: 'Notifications');
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }

  Future<void> deleteNotification(String id) async {
    AppLogger.i('Notification delete → id:$id', tag: 'Notifications');
    // Remove from UI immediately
    dismiss(id);
    try {
      // Delete from backend
      await _repository.deleteNotification(id);
    } catch (e) {
      AppLogger.e('Failed to delete notification', tag: 'Notifications', error: e);
    }
  }

  Future<void> bulkDeleteNotifications(List<String> ids) async {
    AppLogger.i('Bulk delete notifications → count:${ids.length}', tag: 'Notifications');
    // Remove from UI immediately
    state = state.copyWith(
      notifications: state.notifications.where((n) => !ids.contains(n.id)).toList(),
    );
    try {
      // Delete from backend in parallel
      await Future.wait(ids.map((id) => _repository.deleteNotification(id)));
    } catch (e) {
      AppLogger.e('Failed to bulk delete notifications', tag: 'Notifications', error: e);
      // Reload to restore UI state
      await load();
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _notifDsProvider = Provider<NotificationsRemoteDataSource>(
  (ref) => NotificationsRemoteDataSource(ref.read(dioProvider)),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(ref.read(_notifDsProvider)),
);

final _fetchNotifUseCaseProvider = Provider<FetchNotificationsUseCase>(
  (ref) =>
      FetchNotificationsUseCase(ref.read(notificationsRepositoryProvider)),
);

final _markReadUseCaseProvider = Provider<MarkReadUseCase>(
  (ref) => MarkReadUseCase(ref.read(notificationsRepositoryProvider)),
);

final _markAllReadUseCaseProvider = Provider<MarkAllReadUseCase>(
  (ref) => MarkAllReadUseCase(ref.read(notificationsRepositoryProvider)),
);

final _registerTokenUseCaseProvider = Provider<RegisterPushTokenUseCase>(
  (ref) => RegisterPushTokenUseCase(ref.read(notificationsRepositoryProvider)),
);

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  ref.watch(authTokenProvider);
  return NotificationsNotifier(
    ref.read(_fetchNotifUseCaseProvider),
    ref.read(_markReadUseCaseProvider),
    ref.read(_markAllReadUseCaseProvider),
    ref.read(_registerTokenUseCaseProvider),
    ref.read(notificationsRepositoryProvider),
  );
});
