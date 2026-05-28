import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._ds);

  final NotesRemoteDataSource _ds;

  @override
  Future<List<NoteEntity>> getNotes() async {
    final List<NoteEntity> list = await _ds.getNotes();
    return list;
  }

  @override
  Future<NoteEntity> createNote({
    required String title,
    required String body,
    String? color,
    List<String> tags = const [],
  }) async {
    final NoteEntity note = await _ds.createNote(
      title: title,
      body: body,
      color: color,
      tags: tags,
    );
    return note;
  }

  @override
  Future<NoteEntity> updateNote({
    required String id,
    String? title,
    String? body,
    String? color,
    List<String>? tags,
  }) async {
    final NoteEntity note = await _ds.updateNote(
      id: id,
      title: title,
      body: body,
      color: color,
      tags: tags,
    );
    return note;
  }

  @override
  Future<void> deleteNote(String id) => _ds.deleteNote(id);
}
