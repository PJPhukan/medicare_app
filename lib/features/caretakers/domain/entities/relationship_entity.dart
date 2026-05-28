// Pure domain entity for caretaker relationship types.
// No Flutter, no JSON, no Dio.

class CaretakerRelationshipEntity {
  const CaretakerRelationshipEntity({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}
