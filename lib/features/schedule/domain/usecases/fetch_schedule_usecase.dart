import '../entities/dose_entity.dart';
import '../repositories/schedule_repository.dart';

class FetchScheduleUseCase {
  const FetchScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<List<DoseEntity>> call({String? date}) =>
      _repository.getTodayDoses(date: date);
}
