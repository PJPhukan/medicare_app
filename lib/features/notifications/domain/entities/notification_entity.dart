class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.data,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String createdAt;
  final Map<String, dynamic>? data;
  final String? readAt;

  bool get isRead => readAt != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
