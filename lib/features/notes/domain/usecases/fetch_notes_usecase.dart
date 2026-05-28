import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class FetchNotesUseCase {
  const FetchNotesUseCase(this._repo);

  final NotesRepository _repo;

  Future<List<NoteEntity>> call() => _repo.getNotes();
}
