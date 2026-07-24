import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/professionals_remote_datasource.dart';
import '../../data/models/location_models.dart';
import '../../data/models/professional_category_model.dart';
import '../../data/models/professional_model.dart';
import '../../data/repositories/professionals_repository_impl.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ProfessionalsState {
  const ProfessionalsState({
    this.professionals    = const [],
    this.categories       = const [],
    this.isLoading        = false,
    this.isLoadingMore    = false,
    this.error,
    this.selectedCategoryId,
    this.search           = '',
    this.currentPage      = 1,
    this.totalPages       = 1,
    this.isFallback       = false,
    this.fallbackDistrict,
    this.fallbackAreas    = const [],
    this.currentArea,
  });

  final List<Professional> professionals;
  final List<ProfessionalCategory> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? selectedCategoryId;
  final String search;

  // Pagination
  final int currentPage;
  final int totalPages;

  // Location context
  final bool isFallback;
  final String? fallbackDistrict;
  final List<AreaInfo> fallbackAreas;
  final AreaInfo? currentArea;

  bool get hasMore => currentPage < totalPages;

  ProfessionalsState copyWith({
    List<Professional>? professionals,
    List<ProfessionalCategory>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? selectedCategoryId,
    String? search,
    int? currentPage,
    int? totalPages,
    bool? isFallback,
    String? fallbackDistrict,
    List<AreaInfo>? fallbackAreas,
    AreaInfo? currentArea,
    bool clearError      = false,
    bool clearCategory   = false,
    bool clearArea       = false,
  }) =>
      ProfessionalsState(
        professionals:    professionals    ?? this.professionals,
        categories:       categories       ?? this.categories,
        isLoading:        isLoading        ?? this.isLoading,
        isLoadingMore:    isLoadingMore    ?? this.isLoadingMore,
        error:            clearError       ? null : (error ?? this.error),
        selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
        search:           search           ?? this.search,
        currentPage:      currentPage      ?? this.currentPage,
        totalPages:       totalPages       ?? this.totalPages,
        isFallback:       isFallback       ?? this.isFallback,
        fallbackDistrict: fallbackDistrict ?? this.fallbackDistrict,
        fallbackAreas:    fallbackAreas    ?? this.fallbackAreas,
        currentArea:      clearArea        ? null : (currentArea ?? this.currentArea),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ProfessionalsNotifier extends StateNotifier<ProfessionalsState> {
  ProfessionalsNotifier(this._repo) : super(const ProfessionalsState()) {
    loadCategories();
  }

  final ProfessionalsRepository _repo;

  // ── Categories (loaded once) ───────────────────────────────────────────────

  Future<void> loadCategories() async {
    try {
      final cats = await _repo.getCategories();
      state = state.copyWith(
        categories: cats.whereType<ProfessionalCategory>().toList(),
      );
    } catch (e) {
      AppLogger.e('Failed to load categories: $e', tag: 'Professionals');
        if (!mounted) return;
    }
  }

  /// Submit a custom category for admin approval; returns its id so it can be
  /// selected immediately. Reloads categories so the pending one appears.
  Future<String?> requestCustomCategory(String name) async {
    try {
      final created = await _repo.requestCategory(name);
      await loadCategories();
      return created.id;
    } catch (e) {
      AppLogger.e('Failed to request category: $e', tag: 'Professionals');
      return null;
    }
  }

  // ── Location-based load (first page) ──────────────────────────────────────

  Future<void> loadForLocation({
    required String? pincode,
    required String? areaId,
  }) async {
    if (pincode == null && areaId == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: 1,
      professionals: [],
    );

    try {
      final page = await _repo.listByLocation(
        pincode:    pincode,
        areaId:     areaId,
        categoryId: state.selectedCategoryId,
        page:       1,
        limit:      10,
      );

      state = state.copyWith(
        professionals:    page.items.map(_fromJson).whereType<Professional>().toList(),
        currentPage:      1,
        totalPages:       page.pages,
        isLoading:        false,
        isFallback:       page.isFallback,
        fallbackDistrict: page.fallbackDistrict,
        fallbackAreas:    page.fallbackAreas,
        currentArea:      page.area,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Infinite scroll: load next page ───────────────────────────────────────

  Future<void> loadMore({
    required String? pincode,
    required String? areaId,
  }) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final page = await _repo.listByLocation(
        pincode:    pincode,
        areaId:     areaId,
        categoryId: state.selectedCategoryId,
        page:       nextPage,
        limit:      10,
      );

      state = state.copyWith(
        professionals: [
          ...state.professionals,
          ...page.items.map(_fromJson).whereType<Professional>(),
        ],
        currentPage:   nextPage,
        totalPages:    page.pages,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  // ── Category filter ────────────────────────────────────────────────────────

  Future<void> filterByCategory({
    required String? categoryId,
    required String? pincode,
    required String? areaId,
  }) async {
    AppLogger.i('Category filter → ${categoryId ?? 'all'}', tag: 'Professionals');
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    await loadForLocation(pincode: pincode, areaId: areaId);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Professional? _fromJson(Map<String, dynamic> json) {
    try {
      return Professional.fromJson(json);
    } catch (e) {
      AppLogger.e('Failed to parse professional: $e', tag: 'Professionals');
      return null;
    }
  }
}

// ─── Wire-up providers ────────────────────────────────────────────────────────

final _profsDsProvider = Provider<ProfessionalsRemoteDataSource>(
  (ref) => ProfessionalsRemoteDataSource(ref.read(dioProvider)),
);

final professionalsRepositoryProvider = Provider<ProfessionalsRepository>(
  (ref) => ProfessionalsRepositoryImpl(ref.read(_profsDsProvider)),
);

final professionalsProvider =
    StateNotifierProvider<ProfessionalsNotifier, ProfessionalsState>((ref) {
  ref.watch(authTokenProvider);
  return ProfessionalsNotifier(ref.read(professionalsRepositoryProvider));
});
