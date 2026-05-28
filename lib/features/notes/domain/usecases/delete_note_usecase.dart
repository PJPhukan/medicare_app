import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repo);

  final NotesRepository _repo;

  Future<void> call(String id) => _repo.deleteNote(id);
}
