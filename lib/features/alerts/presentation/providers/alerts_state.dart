import '../../domain/entities/alert_entity.dart';

class AlertsState {
  const AlertsState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AlertEntity> alerts;
  final bool isLoading;
  final String? error;

  AlertsState copyWith({
    List<AlertEntity>? alerts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      AlertsState(
        alerts: alerts ?? this.alerts,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}
