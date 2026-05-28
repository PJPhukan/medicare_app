import '../entities/faq_entity.dart';
import '../repositories/support_repository.dart';

class FetchFaqsUseCase {
  const FetchFaqsUseCase(this._repo);

  final SupportRepository _repo;

  Future<List<FaqEntity>> call() => _repo.getFaqs();
}
