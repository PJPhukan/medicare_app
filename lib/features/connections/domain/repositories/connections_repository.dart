import '../entities/chat_message_entity.dart';
import '../entities/connection_entity.dart';
import '../entities/connection_request_entity.dart';

abstract interface class ConnectionsRepository {
  Future<List<ConnectionEntity>> getConnections();
  Future<List<ConnectionRequestEntity>> getIncomingRequests();
  Future<void> sendConnectionRequest(String targetUserId);
  Future<void> acceptRequest(String requestId);
  Future<void> declineRequest(String requestId);
  Future<List<ChatMessageEntity>> getMessages(String connectionId);
  Future<ChatMessageEntity> sendMessage({
    required String connectionId,
    required String body,
  });
}
