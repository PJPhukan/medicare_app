import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/notes_remote_datasource.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/fetch_notes_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _notesDsProvider = Provider<NotesRemoteDataSource>(
  (ref) => NotesRemoteDataSource(ref.read(dioProvider)),
);

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepositoryImpl(ref.read(_notesDsProvider)),
);

class _NotesState {
  const _NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<NoteEntity> notes;
  final bool isLoading;
  final String? error;

  _NotesState copyWith({
    List<NoteEntity>? notes,
    bool? isLoading,
    String? error,
  }) =>
      _NotesState(
        notes: notes ?? this.notes,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _NotesNotifier extends StateNotifier<_NotesState> {
  _NotesNotifier(this._fetch, this._create, this._update, this._delete)
      : super(const _NotesState()) {
    load();
  }

  final FetchNotesUseCase _fetch;
  final CreateNoteUseCase _create;
  final UpdateNoteUseCase _update;
  final DeleteNoteUseCase _delete;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(notes: list, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<NoteEntity> createNote({
    required String title,
    required String body,
    String? color,
    List<String> tags = const [],
  }) async {
    AppLogger.i('Note create', tag: 'Notes');
    try {
      final note = await _create(title: title, body: body, color: color, tags: tags);
      state = state.copyWith(notes: [note, ...state.notes]);
      AppLogger.i('Note created ✓ → id:${note.id}', tag: 'Notes');
      return note;
    } on Exception catch (e, s) {
      AppLogger.e('Note create failed', tag: 'Notes', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> updateNote({
    required String id,
    String? title,
    String? body,
    String? color,
    List<String>? tags,
  }) async {
    AppLogger.i('Note update → id:$id', tag: 'Notes');
    try {
      final updated = await _update(id: id, title: title, body: body, color: color, tags: tags);
      state = state.copyWith(
        notes: state.notes.map((n) => n.id == id ? updated : n).toList(),
      );
      AppLogger.i('Note updated ✓', tag: 'Notes');
    } on Exception catch (e, s) {
      AppLogger.e('Note update failed', tag: 'Notes', error: e, stack: s);
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    AppLogger.i('Note delete → id:$id', tag: 'Notes');
    final prev = state.notes;
    state = state.copyWith(notes: prev.where((n) => n.id != id).toList());
    try {
      await _delete(id);
      AppLogger.i('Note deleted ✓', tag: 'Notes');
    } catch (e, s) {
      AppLogger.e('Note delete failed', tag: 'Notes', error: e, stack: s as StackTrace?);
            if (!mounted) return;
      state = state.copyWith(notes: prev, error: e.toString());
    }
  }
}

final notesProvider =
    StateNotifierProvider<_NotesNotifier, _NotesState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(notesRepositoryProvider);
  return _NotesNotifier(
    FetchNotesUseCase(repo),
    CreateNoteUseCase(repo),
    UpdateNoteUseCase(repo),
    DeleteNoteUseCase(repo),
  );
});
