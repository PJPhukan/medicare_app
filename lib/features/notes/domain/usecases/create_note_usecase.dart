import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repo);

  final NotesRepository _repo;

  Future<NoteEntity> call({
    required String title,
    required String body,
    String? color,
    List<String> tags = const [],
  }) =>
      _repo.createNote(title: title, body: body, color: color, tags: tags);
}
