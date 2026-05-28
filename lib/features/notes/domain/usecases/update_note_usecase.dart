import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repo);

  final NotesRepository _repo;

  Future<NoteEntity> call({
    required String id,
    String? title,
    String? body,
    String? color,
    List<String>? tags,
  }) =>
      _repo.updateNote(
        id: id,
        title: title,
        body: body,
        color: color,
        tags: tags,
      );
}
