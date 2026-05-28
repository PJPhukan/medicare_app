import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncPhase { idle, draining, error }

class SyncState {
  const SyncState({
    this.phase = SyncPhase.idle,
    this.pendingCount = 0,
    this.lastError,
  });

  final SyncPhase phase;
  final int pendingCount;
  final String? lastError;

  bool get isSyncing => phase == SyncPhase.draining;

  SyncState copyWith({
    SyncPhase? phase,
    int? pendingCount,
    String? lastError,
    bool clearError = false,
  }) =>
      SyncState(
        phase: phase ?? this.phase,
        pendingCount: pendingCount ?? this.pendingCount,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

class SyncStateNotifier extends StateNotifier<SyncState> {
  SyncStateNotifier() : super(const SyncState());

  void setDraining(int count) =>
      state = state.copyWith(phase: SyncPhase.draining, pendingCount: count, clearError: true);

  void setIdle(int remaining) =>
      state = state.copyWith(phase: SyncPhase.idle, pendingCount: remaining, clearError: true);

  void setError(String msg) =>
      state = state.copyWith(phase: SyncPhase.error, lastError: msg);
}

final syncStateProvider =
    StateNotifierProvider<SyncStateNotifier, SyncState>((_) => SyncStateNotifier());
