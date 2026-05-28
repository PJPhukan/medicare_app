import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../../domain/repositories/connections_repository.dart';
import '../datasources/connections_remote_datasource.dart';

class ConnectionsRepositoryImpl implements ConnectionsRepository {
  const ConnectionsRepositoryImpl(this._ds);

  final ConnectionsRemoteDataSource _ds;

  @override
  Future<List<ConnectionEntity>> getConnections() async {
    final List<ConnectionEntity> list = await _ds.getConnections();
    return list;
  }

  @override
  Future<List<ConnectionRequestEntity>> getIncomingRequests() async {
    final List<ConnectionRequestEntity> list =
        await _ds.getIncomingRequests();
    return list;
  }

  @override
  Future<void> sendConnectionRequest(String targetUserId) =>
      _ds.sendConnectionRequest(targetUserId);

  @override
  Future<void> acceptRequest(String requestId) =>
      _ds.acceptRequest(requestId);

  @override
  Future<void> declineRequest(String requestId) =>
      _ds.declineRequest(requestId);

  @override
  Future<List<ChatMessageEntity>> getMessages(String connectionId) async {
    final List<ChatMessageEntity> list =
        await _ds.getMessages(connectionId);
    return list;
  }

  @override
  Future<ChatMessageEntity> sendMessage({
    required String connectionId,
    required String body,
  }) async {
    final ChatMessageEntity msg =
        await _ds.sendMessage(connectionId: connectionId, body: body);
    return msg;
  }
}
