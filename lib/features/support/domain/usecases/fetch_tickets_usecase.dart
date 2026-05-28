import '../entities/ticket_entity.dart';
import '../repositories/support_repository.dart';

class FetchTicketsUseCase {
  const FetchTicketsUseCase(this._repo);

  final SupportRepository _repo;

  Future<List<TicketEntity>> call() => _repo.getTickets();
}
