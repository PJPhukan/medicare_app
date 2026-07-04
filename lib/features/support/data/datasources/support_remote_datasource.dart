import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/faq_model.dart';
import '../models/ticket_model.dart';

class SupportRemoteDataSource {
  const SupportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Faq>> getFaqs() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/support/faqs',
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Faq.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ticket>> getTickets() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.users}/support/tickets',
    );
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket> submitTicket({
    required String subject,
    required String body,
    String? category,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '${ApiConstants.users}/support/tickets',
      data: {
        'subject': subject,
        'body': body,
        if (category != null) 'category': category,
      },
    );
    return Ticket.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
