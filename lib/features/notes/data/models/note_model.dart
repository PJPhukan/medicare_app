import '../../domain/entities/note_entity.dart';

class Note extends NoteEntity {
  const Note({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    super.updatedAt,
    super.color,
    super.tags,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String?,
        color: json['color'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      );
}
