enum AlertSeverity { critical, warning, info }

class AlertEntity {
  const AlertEntity({
    required this.id,
    required this.severity,
    required this.title,
    required this.body,
    required this.createdAt,
    this.dismissedAt,
  });

  final String id;
  final AlertSeverity severity;
  final String title;
  final String body;
  final String createdAt;
  final String? dismissedAt;

  bool get isDismissed => dismissedAt != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
