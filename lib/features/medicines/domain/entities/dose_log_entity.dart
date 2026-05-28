// Pure domain entity for a dose log entry.
// No Flutter, no JSON, no Dio.

class DoseLogEntity {
  const DoseLogEntity({
    required this.id,
    required this.status,
    this.takenAt,
  });

  final String id;
  final String status;
  final String? takenAt;

  bool get isTaken => status == 'TAKEN';
  bool get isSkipped => status == 'SKIPPED';
}
