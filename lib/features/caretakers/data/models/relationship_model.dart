import '../../domain/entities/relationship_entity.dart';

class CaretakerRelationship extends CaretakerRelationshipEntity {
  const CaretakerRelationship({
    required super.id,
    required super.label,
  });

  factory CaretakerRelationship.fromJson(Map<String, dynamic> json) =>
      CaretakerRelationship(
        id: json['id'] as String,
        label: json['label'] as String,
      );
}
