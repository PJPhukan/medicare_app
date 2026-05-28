import '../entities/appointment_entity.dart';
import '../repositories/schedule_repository.dart';

class FetchScheduleUseCase {
  const FetchScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<List<DoseEntity>> call() => _repository.getTodayDoses();
}
