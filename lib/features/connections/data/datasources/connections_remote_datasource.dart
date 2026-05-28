import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';
import '../models/connection_model.dart';
import '../models/connection_request_model.dart';

class ConnectionsRemoteDataSource {
  const ConnectionsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Connection>> getConnections() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.professionalConnections,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Connection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConnectionRequest>> getIncomingRequests() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.professionalConnections}/requests/incoming',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendConnectionRequest(String targetUserId) async {
    await _dio.post<void>(
      '${ApiConstants.professionalConnections}/requests',
      data: {'targetUserId': targetUserId},
    );
  }

  Future<void> acceptRequest(String requestId) async {
    await _dio.post<void>(
      '${ApiConstants.professionalConnections}/requests/$requestId/accept',
    );
  }

  Future<void> declineRequest(String requestId) async {
    await _dio.post<void>(
      '${ApiConstants.professionalConnections}/requests/$requestId/decline',
    );
  }

  Future<List<ChatMessage>> getMessages(String connectionId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.professionalConnections}/$connectionId/messages',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage({
    required String connectionId,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.professionalConnections}/$connectionId/messages',
      data: {'body': body},
    );
    return ChatMessage.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
