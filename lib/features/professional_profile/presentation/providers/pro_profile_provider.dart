import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../data/datasources/pro_profile_remote_datasource.dart';
import '../../data/repositories/pro_profile_repository_impl.dart';
import '../../domain/entities/pro_profile_entity.dart';
import '../../domain/repositories/pro_profile_repository.dart';
import '../../domain/usecases/fetch_my_pro_profile_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ProProfileState {
  const ProProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.notFound = false,
  });

  final ProProfileEntity? profile;
  final bool isLoading;
  final String? error;
  final bool notFound;

  ProProfileState copyWith({
    ProProfileEntity? profile,
    bool? isLoading,
    String? error,
    bool? notFound,
    bool clearError = false,
  }) =>
      ProProfileState(
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        notFound: notFound ?? this.notFound,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProProfileNotifier extends StateNotifier<ProProfileState> {
  ProProfileNotifier(this._fetch, this._repo, this._ref) : super(const ProProfileState()) {
    load();
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchMyProProfileUseCase _fetch;
  final ProProfileRepository _repo;
  final Ref _ref;

  /// Create (or, when [isEditing], update) the professional profile.
  /// Throws on failure so the caller can show the error inline.
  Future<ProProfileEntity> submit(
    Map<String, dynamic> data, {
    required bool isEditing,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final entity = isEditing
          ? await _repo.updateProProfile(data)
          : await _repo.createProProfile(data);
      state = state.copyWith(profile: entity, isLoading: false, notFound: false);
      return entity;
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> load() async {
    AppLogger.d('Pro profile load', tag: 'ProProfile');
    state = state.copyWith(isLoading: true, clearError: true, notFound: false);
    try {
      final entity = await _fetch();
      state = state.copyWith(profile: entity, isLoading: false);
      AppLogger.i('Pro profile loaded ✓', tag: 'ProProfile');
    } on DioException catch (e) {
      final is404 = e.response?.statusCode == 404;
      AppLogger.i('Pro profile ${is404 ? 'not found (404)' : 'load failed'}', tag: 'ProProfile', error: e);
      state = state.copyWith(
        isLoading: false,
        notFound: is404,
        error: is404 ? null : (e.message ?? 'Failed to load profile'),
      );
    } on Exception catch (e, s) {
      AppLogger.e('Pro profile load failed', tag: 'ProProfile', error: e, stack: s);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _proProfileDsProvider = Provider<ProProfileRemoteDataSource>(
  (ref) => ProProfileRemoteDataSource(ref.read(dioProvider)),
);

final _proProfileRepositoryProvider = Provider<ProProfileRepository>(
  (ref) => ProProfileRepositoryImpl(ref.read(_proProfileDsProvider)),
);

final _fetchProProfileUseCaseProvider = Provider<FetchMyProProfileUseCase>(
  (ref) => FetchMyProProfileUseCase(ref.read(_proProfileRepositoryProvider)),
);

final proProfileProvider =
    StateNotifierProvider<ProProfileNotifier, ProProfileState>((ref) {
  ref.watch(authTokenProvider);
  return ProProfileNotifier(
    ref.read(_fetchProProfileUseCaseProvider),
    ref.read(_proProfileRepositoryProvider),
    ref,
  );
});
