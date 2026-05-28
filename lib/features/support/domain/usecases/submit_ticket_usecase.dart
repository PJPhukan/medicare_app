import '../entities/ticket_entity.dart';
import '../repositories/support_repository.dart';

class SubmitTicketUseCase {
  const SubmitTicketUseCase(this._repo);

  final SupportRepository _repo;

  Future<TicketEntity> call({
    required String subject,
    required String body,
    String? category,
  }) =>
      _repo.submitTicket(subject: subject, body: body, category: category);
}
