import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/professionals_remote_datasource.dart';
import '../../data/models/professional_category_model.dart';
import '../../data/models/professional_model.dart';
import '../../data/repositories/professionals_repository_impl.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../../domain/usecases/fetch_categories_usecase.dart';
import '../../domain/usecases/fetch_professionals_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

class ProfessionalsState {
  const ProfessionalsState({
    this.professionals = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.search = '',
  });

  final List<Professional> professionals;
  final List<ProfessionalCategory> categories;
  final bool isLoading;
  final String? error;
  final String? selectedCategoryId;
  final String search;

  ProfessionalsState copyWith({
    List<Professional>? professionals,
    List<ProfessionalCategory>? categories,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
    String? search,
    bool clearError = false,
    bool clearCategory = false,
  }) =>
      ProfessionalsState(
        professionals: professionals ?? this.professionals,
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        selectedCategoryId:
            clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
        search: search ?? this.search,
      );
}

class ProfessionalsNotifier extends StateNotifier<ProfessionalsState> {
  ProfessionalsNotifier(this._fetchCategories, this._fetchProfessionals)
      : super(const ProfessionalsState()) {
    load();
  }

  final FetchCategoriesUseCase _fetchCategories;
  final FetchProfessionalsUseCase _fetchProfessionals;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _fetchCategories(),
        _fetchProfessionals(
          categoryId: state.selectedCategoryId,
          search: state.search.isNotEmpty ? state.search : null,
        ),
      ]);
      state = state.copyWith(
        categories:
            (results[0] as List).whereType<ProfessionalCategory>().toList(),
        professionals:
            (results[1] as List).whereType<Professional>().toList(),
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    AppLogger.i('Professionals filter → categoryId:${categoryId ?? 'all'}', tag: 'Professionals');
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    await load();
  }

  Future<void> setSearch(String query) async {
    AppLogger.i('Professionals search → "${query.isEmpty ? '<cleared>' : query}"', tag: 'Professionals');
    state = state.copyWith(search: query);
    await load();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _profsDsProvider = Provider<ProfessionalsRemoteDataSource>(
  (ref) => ProfessionalsRemoteDataSource(ref.read(dioProvider)),
);

final professionalsRepositoryProvider = Provider<ProfessionalsRepository>(
  (ref) => ProfessionalsRepositoryImpl(ref.read(_profsDsProvider)),
);

final _fetchCategoriesUseCaseProvider = Provider<FetchCategoriesUseCase>(
  (ref) => FetchCategoriesUseCase(ref.read(professionalsRepositoryProvider)),
);

final _fetchProfessionalsUseCaseProvider = Provider<FetchProfessionalsUseCase>(
  (ref) =>
      FetchProfessionalsUseCase(ref.read(professionalsRepositoryProvider)),
);

final professionalsProvider =
    StateNotifierProvider<ProfessionalsNotifier, ProfessionalsState>((ref) {
  ref.watch(authTokenProvider);
  return ProfessionalsNotifier(
    ref.read(_fetchCategoriesUseCaseProvider),
    ref.read(_fetchProfessionalsUseCaseProvider),
  );
});
