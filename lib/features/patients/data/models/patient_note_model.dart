import '../../domain/entities/patient_note_entity.dart';

class PatientNote extends PatientNoteEntity {
  const PatientNote({
    required super.id,
    required super.note,
    required super.createdAt,
    super.authorName,
  });

  factory PatientNote.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return PatientNote(
      id: json['id'] as String,
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as String,
      authorName: author?['name'] as String?,
    );
  }
}
