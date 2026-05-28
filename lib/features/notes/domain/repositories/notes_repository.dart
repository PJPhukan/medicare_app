import '../entities/note_entity.dart';

abstract interface class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote({
    required String title,
    required String body,
    String? color,
    List<String> tags,
  });
  Future<NoteEntity> updateNote({
    required String id,
    String? title,
    String? body,
    String? color,
    List<String>? tags,
  });
  Future<void> deleteNote(String id);
}
