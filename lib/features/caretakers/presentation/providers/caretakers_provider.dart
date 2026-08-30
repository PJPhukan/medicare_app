import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/caretakers_remote_datasource.dart';
import '../../data/repositories/caretakers_repository_impl.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../../domain/repositories/caretakers_repository.dart';
import '../../domain/usecases/fetch_caretakers_usecase.dart';
import '../../domain/usecases/fetch_pending_invites_usecase.dart';
import '../../domain/usecases/fetch_grantable_tabs_usecase.dart';
import '../../domain/usecases/fetch_manageable_patients_usecase.dart';
import '../../domain/usecases/invite_caretaker_usecase.dart';
import '../../domain/usecases/cancel_invite_usecase.dart';
import '../../domain/usecases/remove_caretaker_usecase.dart';
import '../../domain/usecases/save_tab_grant_usecase.dart';
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

// One-shot fetch for the invite screen's "which patient" picker — not part of
// the caretakers list state since it's only ever needed while inviting.
final manageablePatientsProvider = FutureProvider.autoDispose<List<ManageablePatientEntity>>((ref) {
  ref.watch(authTokenProvider);
  return FetchManageablePatientsUseCase(ref.read(caretakersRepositoryProvider)).call();
});

class _CaretakersState {
  const _CaretakersState({
    this.caretakers = const [],
    this.pendingInvites = const [],
    this.grantableTabs = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CaretakerEntity> caretakers;
  final List<PendingCaretakerInviteEntity> pendingInvites;
  final List<GrantableTabEntity> grantableTabs;
  final bool isLoading;
  final String? error;

  _CaretakersState copyWith({
    List<CaretakerEntity>? caretakers,
    List<PendingCaretakerInviteEntity>? pendingInvites,
    List<GrantableTabEntity>? grantableTabs,
    bool? isLoading,
    String? error,
  }) =>
      _CaretakersState(
        caretakers: caretakers ?? this.caretakers,
        pendingInvites: pendingInvites ?? this.pendingInvites,
        grantableTabs: grantableTabs ?? this.grantableTabs,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _CaretakersNotifier extends StateNotifier<_CaretakersState> {
  _CaretakersNotifier(
    this._fetchCaretakers,
    this._fetchPendingInvites,
    this._fetchGrantableTabs,
    this._removeCaretaker,
    this._cancelInvite,
    this._saveTabGrant,
  ) : super(const _CaretakersState()) {
    load();
  }

  final FetchCaretakersUseCase _fetchCaretakers;
  final FetchPendingInvitesUseCase _fetchPendingInvites;
  final FetchGrantableTabsUseCase _fetchGrantableTabs;
  final RemoveCaretakerUseCase _removeCaretaker;
  final CancelInviteUseCase _cancelInvite;
  final SaveTabGrantUseCase _saveTabGrant;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final caretakers = await _fetchCaretakers();
      final invites = await _fetchPendingInvites();
      final tabs = await _fetchGrantableTabs();
      state = state.copyWith(
        caretakers: caretakers,
        pendingInvites: invites,
        grantableTabs: tabs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns whether the removal actually succeeded — the caller must not
  /// report success on a rolled-back optimistic update.
  Future<bool> removeCaretaker(String relationshipId) async {
    AppLogger.i('Caretaker remove → relationshipId:$relationshipId', tag: 'Caretakers');
    final prev = state.caretakers;
    state = state.copyWith(
      caretakers: prev.where((c) => c.relationshipId != relationshipId).toList(),
    );
    try {
      await _removeCaretaker(relationshipId);
      AppLogger.i('Caretaker removed ✓', tag: 'Caretakers');
      return true;
    } catch (e, s) {
      AppLogger.e('Caretaker remove failed', tag: 'Caretakers', error: e, stack: s);
      state = state.copyWith(caretakers: prev, error: e.toString());
      return false;
    }
  }

  /// Returns whether the cancellation actually succeeded (see [removeCaretaker]).
  Future<bool> cancelInvite(String inviteId) async {
    AppLogger.i('Caretaker invite cancel → id:$inviteId', tag: 'Caretakers');
    final prev = state.pendingInvites;
    state = state.copyWith(
      pendingInvites: prev.where((i) => i.id != inviteId).toList(),
    );
    try {
      await _cancelInvite(inviteId);
      return true;
    } catch (e, s) {
      AppLogger.e('Caretaker invite cancel failed', tag: 'Caretakers', error: e, stack: s);
      state = state.copyWith(pendingInvites: prev, error: e.toString());
      return false;
    }
  }

  Future<bool> saveTabGrant({
    required String relationshipId,
    required String tabId,
    required bool opView,
    required bool opAdd,
    required bool opEdit,
    required bool opDelete,
    required bool opShare,
  }) async {
    try {
      await _saveTabGrant(
        relationshipId: relationshipId,
        tabId: tabId,
        opView: opView,
        opAdd: opAdd,
        opEdit: opEdit,
        opDelete: opDelete,
        opShare: opShare,
      );
      // Re-fetch rather than patch state locally — the backend may clamp ops
      // to what the tab's TabConfig currently allows, so the reflected state
      // should always be the server's word, not an optimistic guess.
      await load();
      return true;
    } catch (e, s) {
      AppLogger.e('Tab grant save failed', tag: 'Caretakers', error: e, stack: s);
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final caretakersProvider =
    StateNotifierProvider<_CaretakersNotifier, _CaretakersState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(caretakersRepositoryProvider);
  return _CaretakersNotifier(
    FetchCaretakersUseCase(repo),
    FetchPendingInvitesUseCase(repo),
    FetchGrantableTabsUseCase(repo),
    RemoveCaretakerUseCase(repo),
    CancelInviteUseCase(repo),
    SaveTabGrantUseCase(repo),
  );
});
