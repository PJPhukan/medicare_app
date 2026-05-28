import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  const MessageRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Conversation>> getConversations() async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiConstants.conversations,
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Message>> getThread(String conversationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/messages/conversations/$conversationId/messages',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.users}/messages/conversations/$conversationId/messages',
      data: {'body': body},
    );
    return Message.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
