import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/connections_remote_datasource.dart';
import '../../data/repositories/connections_repository_impl.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../../domain/repositories/connections_repository.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/decline_request_usecase.dart';
import '../../domain/usecases/fetch_connections_usecase.dart';
import '../../domain/usecases/fetch_incoming_requests_usecase.dart';
import '../../domain/usecases/send_connection_request_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _connectionsDsProvider = Provider<ConnectionsRemoteDataSource>(
  (ref) => ConnectionsRemoteDataSource(ref.read(dioProvider)),
);

final connectionsRepositoryProvider = Provider<ConnectionsRepository>(
  (ref) => ConnectionsRepositoryImpl(ref.read(_connectionsDsProvider)),
);

final sendConnectionRequestProvider = Provider<SendConnectionRequestUseCase>(
  (ref) {
    ref.watch(authTokenProvider);
    return SendConnectionRequestUseCase(ref.read(connectionsRepositoryProvider));
  },
);

class _ConnectionsState {
  const _ConnectionsState({
    this.connections = const [],
    this.incomingRequests = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ConnectionEntity> connections;
  final List<ConnectionRequestEntity> incomingRequests;
  final bool isLoading;
  final String? error;

  _ConnectionsState copyWith({
    List<ConnectionEntity>? connections,
    List<ConnectionRequestEntity>? incomingRequests,
    bool? isLoading,
    String? error,
  }) =>
      _ConnectionsState(
        connections: connections ?? this.connections,
        incomingRequests: incomingRequests ?? this.incomingRequests,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _ConnectionsNotifier extends StateNotifier<_ConnectionsState> {
  _ConnectionsNotifier(this._fetch, this._fetchRequests, this._accept, this._decline)
      : super(const _ConnectionsState()) {
    load();
  }

  final FetchConnectionsUseCase _fetch;
  final FetchIncomingRequestsUseCase _fetchRequests;
  final AcceptRequestUseCase _accept;
  final DeclineRequestUseCase _decline;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([_fetch(), _fetchRequests()]);
      state = state.copyWith(
        connections: results[0] as List<ConnectionEntity>,
        incomingRequests: results[1] as List<ConnectionRequestEntity>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> acceptRequest(String requestId) async {
    AppLogger.i('Connection request accept → id:$requestId', tag: 'Connections');
    final prev = state.incomingRequests;
    state = state.copyWith(
      incomingRequests: prev.where((r) => r.id != requestId).toList(),
    );
    try {
      await _accept(requestId);
      await load();
      AppLogger.i('Connection request accepted ✓', tag: 'Connections');
    } catch (e, s) {
      AppLogger.e('Connection accept failed', tag: 'Connections', error: e, stack: s);
      state = state.copyWith(incomingRequests: prev, error: e.toString());
    }
  }

  Future<void> declineRequest(String requestId) async {
    AppLogger.i('Connection request decline → id:$requestId', tag: 'Connections');
    final prev = state.incomingRequests;
    state = state.copyWith(
      incomingRequests: prev.where((r) => r.id != requestId).toList(),
    );
    try {
      await _decline(requestId);
      AppLogger.i('Connection request declined ✓', tag: 'Connections');
    } catch (e, s) {
      AppLogger.e('Connection decline failed', tag: 'Connections', error: e, stack: s);
      state = state.copyWith(incomingRequests: prev, error: e.toString());
    }
  }
}

final connectionsProvider =
    StateNotifierProvider<_ConnectionsNotifier, _ConnectionsState>((ref) {
  ref.watch(authTokenProvider);
  final repo = ref.read(connectionsRepositoryProvider);
  return _ConnectionsNotifier(
    FetchConnectionsUseCase(repo),
    FetchIncomingRequestsUseCase(repo),
    AcceptRequestUseCase(repo),
    DeclineRequestUseCase(repo),
  );
});
