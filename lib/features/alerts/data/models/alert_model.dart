import '../../domain/entities/alert_entity.dart';

class Alert extends AlertEntity {
  const Alert({
    required super.id,
    required super.severity,
    required super.title,
    required super.body,
    required super.createdAt,
    super.dismissedAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'] as String,
        severity: _parseSeverity(json['severity'] as String? ?? 'info'),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        dismissedAt: json['dismissedAt'] as String?,
      );

  static AlertSeverity _parseSeverity(String raw) => switch (raw.toUpperCase()) {
        'CRITICAL' => AlertSeverity.critical,
        'WARNING' => AlertSeverity.warning,
        _ => AlertSeverity.info,
      };
}
