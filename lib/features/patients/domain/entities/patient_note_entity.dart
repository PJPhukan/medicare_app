// Pure domain entity for a caretaker note left on a patient profile.
// No Flutter, no JSON, no Dio.

class PatientNoteEntity {
  const PatientNoteEntity({
    required this.id,
    required this.note,
    required this.createdAt,
    this.authorName,
  });

  final String id;
  final String note;
  final String createdAt;
  final String? authorName;

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
