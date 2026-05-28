import '../entities/faq_entity.dart';
import '../entities/ticket_entity.dart';

abstract interface class SupportRepository {
  Future<List<FaqEntity>> getFaqs();
  Future<List<TicketEntity>> getTickets();
  Future<TicketEntity> submitTicket({
    required String subject,
    required String body,
    String? category,
  });
}
