import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/support_remote_datasource.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/usecases/fetch_tickets_usecase.dart';
import '../../domain/usecases/submit_ticket_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _supportDsProvider = Provider<SupportRemoteDataSource>(
  (ref) => SupportRemoteDataSource(ref.read(dioProvider)),
);

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(ref.read(_supportDsProvider)),
);

final submitTicketProvider = Provider<SubmitTicketUseCase>((ref) {
  ref.watch(authTokenProvider);
  return SubmitTicketUseCase(ref.read(supportRepositoryProvider));
});

class _SupportState {
  const _SupportState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
  });

  final List<TicketEntity> tickets;
  final bool isLoading;
  final String? error;

  _SupportState copyWith({
    List<TicketEntity>? tickets,
    bool? isLoading,
    String? error,
  }) =>
      _SupportState(
        tickets: tickets ?? this.tickets,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _SupportNotifier extends StateNotifier<_SupportState> {
  _SupportNotifier(this._fetch) : super(const _SupportState()) {
    load();
  }

  final FetchTicketsUseCase _fetch;

  Future<void> load() async {
    AppLogger.d('Support tickets load', tag: 'Support');
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(tickets: list, isLoading: false);
      AppLogger.i('Support tickets loaded ✓ → ${list.length}', tag: 'Support');
    } catch (e, s) {
      AppLogger.e('Support tickets load failed', tag: 'Support', error: e, stack: s);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final supportProvider =
    StateNotifierProvider<_SupportNotifier, _SupportState>((ref) {
  ref.watch(authTokenProvider);
  return _SupportNotifier(
    FetchTicketsUseCase(ref.read(supportRepositoryProvider)),
  );
});
