import '../../data/models/create_request_result.dart';
import '../entities/chat_message_entity.dart';
import '../entities/connection_entity.dart';
import '../entities/connection_request_entity.dart';

abstract interface class ConnectionsRepository {
  Future<List<ConnectionEntity>> getConnections();
  Future<List<ConnectionEntity>> getConnectionsAsProfessional();
  Future<List<ConnectionRequestEntity>> getMyRequests();
  Future<List<ConnectionRequestEntity>> getIncomingRequests();
  Future<void> sendConnectionRequest({
    required String professionalId,
    required String planType,
    String? areaId,
    String? note,
  });
  Future<CreateRequestResult> payForRequest(String requestId);
  Future<void> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
  Future<void> acceptRequest(String requestId);
  Future<void> declineRequest(String requestId);
  Future<List<ChatMessageEntity>> getMessages(String connectionId);
  Future<ChatMessageEntity> sendMessage({
    required String connectionId,
    required String body,
  });
}
