import '../../domain/entities/insight_entity.dart';

class Insight extends InsightEntity {
  const Insight({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.createdAt,
    super.severity,
    super.data,
  });

  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        severity: json['severity'] as String?,
        data: json['data'] as Map<String, dynamic>?,
      );
}
