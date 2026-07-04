import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/alerts_remote_datasource.dart';
import '../../data/repositories/alerts_repository_impl.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../domain/usecases/dismiss_alert_usecase.dart';
import '../../domain/usecases/fetch_alerts_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';
import 'alerts_state.dart';

class AlertsNotifier extends StateNotifier<AlertsState> {
  AlertsNotifier(this._fetchAlerts, this._dismissAlert)
      : super(const AlertsState()) {
    load();
  }

  final FetchAlertsUseCase _fetchAlerts;
  final DismissAlertUseCase _dismissAlert;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alerts = await _fetchAlerts();
      state = state.copyWith(alerts: alerts, isLoading: false);
    } catch (e, s) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> dismiss(String id) async {
    AppLogger.i('Alert dismiss → id:$id', tag: 'Alerts');
    state = state.copyWith(
      alerts: state.alerts.where((a) => a.id != id).toList(),
    );
    try {
      await _dismissAlert(id);
      AppLogger.i('Alert dismissed ✓', tag: 'Alerts');
    } on Exception catch (e, s) {
      AppLogger.e('Alert dismiss failed', tag: 'Alerts', error: e, stack: s);
      await load();
    }
  }
}

final _alertsDsProvider = Provider<AlertsRemoteDataSource>(
  (ref) => AlertsRemoteDataSource(ref.read(dioProvider)),
);

final alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) => AlertsRepositoryImpl(ref.read(_alertsDsProvider)),
);

final _fetchAlertsUseCaseProvider = Provider<FetchAlertsUseCase>(
  (ref) => FetchAlertsUseCase(ref.read(alertsRepositoryProvider)),
);

final _dismissAlertUseCaseProvider = Provider<DismissAlertUseCase>(
  (ref) => DismissAlertUseCase(ref.read(alertsRepositoryProvider)),
);

final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  ref.watch(authTokenProvider);
  return AlertsNotifier(
    ref.read(_fetchAlertsUseCaseProvider),
    ref.read(_dismissAlertUseCaseProvider),
  );
});
