import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/fetch_reports_usecase.dart';
import '../../domain/usecases/delete_report_usecase.dart';
import '../../domain/usecases/upload_report_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReportsState {
  const ReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final List<MedicalReport> reports;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  ReportsState copyWith({
    List<MedicalReport>? reports,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) =>
      ReportsState(
        reports: reports ?? this.reports,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isOffline: isOffline ?? this.isOffline,
      );
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier(
    this._fetchReports,
    this._deleteReport,
    this._uploadReport,
    this._ref,
  ) : super(const ReportsState()) {
    load();
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchReportsUseCase _fetchReports;
  final DeleteReportUseCase _deleteReport;
  final UploadReportUseCase _uploadReport;
  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _fetchReports();
      state = state.copyWith(
        reports: list.whereType<MedicalReport>().toList(),
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReport(String id) async {
    AppLogger.i('Report delete → id:$id', tag: 'Reports');
    state = state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
    );
    try {
      await _deleteReport(id);
      AppLogger.i('Report deleted ✓', tag: 'Reports');
    } on Exception catch (e, s) {
      AppLogger.e('Report delete failed', tag: 'Reports', error: e, stack: s);
      await load();
      rethrow;
    }
  }

  Future<void> uploadReport({
    required String filePath,
    required String title,
    String? description,
    String? reportDate,
    List<String>? tags,
  }) async {
    AppLogger.i('Report upload', tag: 'Reports');
    try {
      final report = await _uploadReport(
        filePath: filePath,
        title: title,
        description: description,
        reportDate: reportDate,
        tags: tags,
      );
      state = state.copyWith(
        reports: [report as MedicalReport, ...state.reports],
      );
      AppLogger.i('Report uploaded ✓', tag: 'Reports');
    } on Exception catch (e, s) {
      AppLogger.e('Report upload failed', tag: 'Reports', error: e, stack: s);
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _reportsDsProvider = Provider<ReportsRemoteDataSource>(
  (ref) => ReportsRemoteDataSource(ref.read(dioProvider)),
);

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) =>
    ReportsRepositoryImpl(
      ref.read(_reportsDsProvider),
      ref.read(syncQueueProvider),
      () => ref.read(isOnlineProvider),
    ));

final _fetchReportsUseCaseProvider = Provider<FetchReportsUseCase>(
  (ref) => FetchReportsUseCase(ref.read(reportsRepositoryProvider)),
);

final _deleteReportUseCaseProvider = Provider<DeleteReportUseCase>(
  (ref) => DeleteReportUseCase(ref.read(reportsRepositoryProvider)),
);

final _uploadReportUseCaseProvider = Provider<UploadReportUseCase>(
  (ref) => UploadReportUseCase(ref.read(reportsRepositoryProvider)),
);

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  ref.watch(authTokenProvider);
  return ReportsNotifier(
    ref.read(_fetchReportsUseCaseProvider),
    ref.read(_deleteReportUseCaseProvider),
    ref.read(_uploadReportUseCaseProvider),
    ref,
  );
});
