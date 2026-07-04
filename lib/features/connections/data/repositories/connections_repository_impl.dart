import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../../domain/repositories/connections_repository.dart';
import '../datasources/connections_remote_datasource.dart';
import '../models/create_request_result.dart';

class ConnectionsRepositoryImpl implements ConnectionsRepository {
  const ConnectionsRepositoryImpl(this._ds);

  final ConnectionsRemoteDataSource _ds;

  @override
  Future<List<ConnectionEntity>> getConnections() => _ds.getConnections();

  @override
  Future<List<ConnectionEntity>> getConnectionsAsProfessional() =>
      _ds.getConnectionsAsProfessional();

  @override
  Future<List<ConnectionRequestEntity>> getMyRequests() => _ds.getMyRequests();

  @override
  Future<List<ConnectionRequestEntity>> getIncomingRequests() =>
      _ds.getIncomingRequests();

  @override
  Future<void> sendConnectionRequest({
    required String professionalId,
    required String planType,
    String? areaId,
    String? note,
  }) =>
      _ds.sendConnectionRequest(
        professionalId: professionalId,
        planType: planType,
        areaId: areaId,
        note: note,
      );

  @override
  Future<CreateRequestResult> payForRequest(String requestId) =>
      _ds.payForRequest(requestId);

  @override
  Future<void> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) =>
      _ds.confirmPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

  @override
  Future<void> acceptRequest(String requestId) => _ds.acceptRequest(requestId);

  @override
  Future<void> declineRequest(String requestId) =>
      _ds.declineRequest(requestId);

  @override
  Future<List<ChatMessageEntity>> getMessages(String connectionId) =>
      _ds.getMessages(connectionId);

  @override
  Future<ChatMessageEntity> sendMessage({
    required String connectionId,
    required String body,
  }) =>
      _ds.sendMessage(connectionId: connectionId, body: body);
}
