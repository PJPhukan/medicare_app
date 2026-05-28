import '../../domain/entities/faq_entity.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._ds);

  final SupportRemoteDataSource _ds;

  @override
  Future<List<FaqEntity>> getFaqs() async {
    final List<FaqEntity> list = await _ds.getFaqs();
    return list;
  }

  @override
  Future<List<TicketEntity>> getTickets() async {
    final List<TicketEntity> list = await _ds.getTickets();
    return list;
  }

  @override
  Future<TicketEntity> submitTicket({
    required String subject,
    required String body,
    String? category,
  }) async {
    final TicketEntity ticket = await _ds.submitTicket(
      subject: subject,
      body: body,
      category: category,
    );
    return ticket;
  }
}
