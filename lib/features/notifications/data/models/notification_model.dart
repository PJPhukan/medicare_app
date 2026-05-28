import '../../domain/entities/notification_entity.dart';

class AppNotification extends NotificationEntity {
  const AppNotification({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.createdAt,
    super.data,
    super.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        readAt: json['readAt'] as String?,
        data: json['data'] as Map<String, dynamic>?,
      );
}
