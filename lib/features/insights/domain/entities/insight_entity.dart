// Pure domain entity for health insights.
// No Flutter, no JSON, no Dio.

class InsightEntity {
  const InsightEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.severity,
    this.data,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String createdAt;
  final String? severity; // 'INFO' | 'WARNING' | 'CRITICAL'
  final Map<String, dynamic>? data;

  bool get isWarning => severity == 'WARNING';
  bool get isCritical => severity == 'CRITICAL';
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
