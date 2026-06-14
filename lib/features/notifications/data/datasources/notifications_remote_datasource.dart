import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({List<AppNotification> notifications, int unreadCount})>
      getNotifications({int? take, bool unreadOnly = false}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {
        if (take != null) 'take': take,
        if (unreadOnly) 'unread': 'true',
      },
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = data['notifications'] as List<dynamic>;
    return (
      notifications: list
          .map((e) =>
              AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: data['unreadCount'] as int? ?? 0,
    );
  }

  Future<void> markRead(String id) async {
    await _dio.patch<void>('${ApiConstants.notifications}/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.post<void>(ApiConstants.notifReadAll);
  }

  Future<void> registerPushToken(String token, String platform) async {
    await _dio.post<void>(
      ApiConstants.pushTokens,
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete<void>('${ApiConstants.notifications}/$id');
  }
}
