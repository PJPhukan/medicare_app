import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../data/datasources/message_remote_datasource.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/usecases/fetch_conversations_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

final _messageDsProvider = Provider<MessageRemoteDataSource>(
  (ref) => MessageRemoteDataSource(ref.read(dioProvider)),
);

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepositoryImpl(ref.read(_messageDsProvider)),
);

final sendMessageProvider = Provider<SendMessageUseCase>((ref) {
  ref.watch(authTokenProvider);
  return SendMessageUseCase(ref.read(messageRepositoryProvider));
});

class _MessageState {
  const _MessageState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ConversationEntity> conversations;
  final bool isLoading;
  final String? error;

  _MessageState copyWith({
    List<ConversationEntity>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      _MessageState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _MessageNotifier extends StateNotifier<_MessageState> {
  _MessageNotifier(this._fetch) : super(const _MessageState()) {
    load();
  }

  final FetchConversationsUseCase _fetch;

  Future<void> load() async {
    AppLogger.d('Conversations load', tag: 'Message');
    state = state.copyWith(isLoading: true);
    try {
      final list = await _fetch();
      state = state.copyWith(conversations: list, isLoading: false);
      AppLogger.i('Conversations loaded ✓ → ${list.length}', tag: 'Message');
    } catch (e, s) {
      AppLogger.e('Conversations load failed', tag: 'Message', error: e, stack: s);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final messageProvider =
    StateNotifierProvider<_MessageNotifier, _MessageState>((ref) {
  ref.watch(authTokenProvider);
  return _MessageNotifier(
    FetchConversationsUseCase(ref.read(messageRepositoryProvider)),
  );
});
