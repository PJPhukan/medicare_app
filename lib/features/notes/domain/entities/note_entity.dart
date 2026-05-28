// Pure domain entity for user notes.
// No Flutter, no JSON, no Dio.

class NoteEntity {
  const NoteEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.updatedAt,
    this.color,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;
  final String createdAt;
  final String? updatedAt;
  final String? color;
  final List<String> tags;

  bool get isEdited => updatedAt != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
