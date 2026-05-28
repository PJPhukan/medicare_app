import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/insights_remote_datasource.dart';
import '../../data/repositories/insights_repository_impl.dart';
import '../../domain/entities/adherence_entity.dart';
import '../../domain/entities/insight_entity.dart';
import '../../domain/repositories/insights_repository.dart';
import '../../domain/usecases/fetch_adherence_usecase.dart';
import '../../domain/usecases/fetch_insights_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _insightsDsProvider = Provider<InsightsRemoteDataSource>(
  (ref) => InsightsRemoteDataSource(ref.read(dioProvider)),
);

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepositoryImpl(ref.read(_insightsDsProvider)),
);

class _InsightsState {
  const _InsightsState({
    this.insights = const [],
    this.adherence,
    this.isLoading = false,
    this.error,
  });

  final List<InsightEntity> insights;
  final AdherenceEntity? adherence;
  final bool isLoading;
  final String? error;

  _InsightsState copyWith({
    List<InsightEntity>? insights,
    AdherenceEntity? adherence,
    bool? isLoading,
    String? error,
  }) =>
      _InsightsState(
        insights: insights ?? this.insights,
        adherence: adherence ?? this.adherence,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _InsightsNotifier extends StateNotifier<_InsightsState> {
  _InsightsNotifier(this._fetchInsights, this._fetchAdherence)
      : super(const _InsightsState()) {
    load();
  }

  final FetchInsightsUseCase _fetchInsights;
  final FetchAdherenceUseCase _fetchAdherence;

  Future<void> load() async {
    AppLogger.d('Insights load', tag: 'Insights');
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _fetchInsights(),
        _fetchAdherence(),
      ]);
      state = state.copyWith(
        insights: results[0] as List<InsightEntity>,
        adherence: results[1] as AdherenceEntity,
        isLoading: false,
      );
      AppLogger.i('Insights loaded ✓ → ${(results[0] as List).length} insights', tag: 'Insights');
    } catch (e, s) {
      AppLogger.e('Insights load failed', tag: 'Insights', error: e, stack: s);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final insightsProvider =
    StateNotifierProvider<_InsightsNotifier, _InsightsState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(insightsRepositoryProvider);
  return _InsightsNotifier(
    FetchInsightsUseCase(repo),
    FetchAdherenceUseCase(repo),
  );
});
