import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/caretakers_remote_datasource.dart';
import '../../data/repositories/caretakers_repository_impl.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../../domain/repositories/caretakers_repository.dart';
import '../../domain/usecases/fetch_caretakers_usecase.dart';
import '../../domain/usecases/invite_caretaker_usecase.dart';
import '../../domain/usecases/remove_caretaker_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _caretakersDsProvider = Provider<CaretakersRemoteDataSource>(
  (ref) => CaretakersRemoteDataSource(ref.read(dioProvider)),
);

final caretakersRepositoryProvider = Provider<CaretakersRepository>(
  (ref) => CaretakersRepositoryImpl(ref.read(_caretakersDsProvider)),
);

final inviteCaretakerProvider = Provider<InviteCaretakerUseCase>((ref) {
  ref.watch(authTokenProvider);
  return InviteCaretakerUseCase(ref.read(caretakersRepositoryProvider));
});

class _CaretakersState {
  const _CaretakersState({
    this.caretakers = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CaretakerEntity> caretakers;
  final bool isLoading;
  final String? error;

  _CaretakersState copyWith({
    List<CaretakerEntity>? caretakers,
    bool? isLoading,
    String? error,
  }) =>
      _CaretakersState(
        caretakers: caretakers ?? this.caretakers,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _CaretakersNotifier extends StateNotifier<_CaretakersState> {
  _CaretakersNotifier(this._fetch, this._remove) : super(const _CaretakersState()) {
    load();
  }

  final FetchCaretakersUseCase _fetch;
  final RemoveCaretakerUseCase _remove;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(caretakers: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeCaretaker(String id) async {
    AppLogger.i('Caretaker remove → id:$id', tag: 'Caretakers');
    final prev = state.caretakers;
    state = state.copyWith(caretakers: prev.where((c) => c.id != id).toList());
    try {
      await _remove(id);
      AppLogger.i('Caretaker removed ✓', tag: 'Caretakers');
    } catch (e, s) {
      AppLogger.e('Caretaker remove failed', tag: 'Caretakers', error: e, stack: s);
      state = state.copyWith(caretakers: prev, error: e.toString());
    }
  }
}

final caretakersProvider =
    StateNotifierProvider<_CaretakersNotifier, _CaretakersState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(caretakersRepositoryProvider);
  return _CaretakersNotifier(
    FetchCaretakersUseCase(repo),
    RemoveCaretakerUseCase(repo),
  );
});
