import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';
import '../models/connection_model.dart';
import '../models/connection_request_model.dart';
import '../models/create_request_result.dart';

class ConnectionsRemoteDataSource {
  const ConnectionsRemoteDataSource(this._dio);

  final Dio _dio;

  static const String _base = ApiConstants.professionalConnections;

  Future<List<Connection>> getConnections() async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/connections');
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Connection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Connection>> getConnectionsAsProfessional() async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/connections?as=professional');
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Connection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Requests the patient has sent (GET /requests/mine → data: [...]).
  Future<List<ConnectionRequest>> getMyRequests() async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/requests/mine');
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Requests incoming to the professional (GET /requests/incoming →
  /// data: { requests: [...], capacity: {...} }).
  Future<List<ConnectionRequest>> getIncomingRequests() async {
    final res =
        await _dio.get<Map<String, dynamic>>('$_base/requests/incoming');
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = data['requests'] as List<dynamic>;
    return list
        .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates a FREE connection request (no payment yet — pay on acceptance).
  Future<void> sendConnectionRequest({
    required String professionalId,
    required String planType,
    String? areaId,
    String? note,
  }) async {
    await _dio.post<void>(
      '$_base/requests',
      data: {
        'professionalId': professionalId,
        'planType': planType,
        if (areaId != null) 'areaId': areaId,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
  }

  /// Starts payment for an accepted (AWAITING_PAYMENT) request → Razorpay order.
  Future<CreateRequestResult> payForRequest(String requestId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/requests/$requestId/pay',
    );
    return CreateRequestResult.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  /// Confirms payment after the Razorpay checkout succeeds.
  Future<void> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    await _dio.post<void>(
      '$_base/requests/confirm-payment',
      data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
    );
  }

  Future<void> acceptRequest(String requestId) async {
    await _dio.post<void>('$_base/requests/$requestId/accept');
  }

  Future<void> declineRequest(String requestId) async {
    await _dio.post<void>('$_base/requests/$requestId/decline');
  }

  Future<List<ChatMessage>> getMessages(String connectionId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/connections/$connectionId/messages',
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage({
    required String connectionId,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/connections/$connectionId/messages',
      data: {'body': body},
    );
    return ChatMessage.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
