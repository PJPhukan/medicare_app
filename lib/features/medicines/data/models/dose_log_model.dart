// Dose log model — represents a recorded dose action.
// Extend as needed when the medicines feature adds log tracking.

class DoseLog {
  const DoseLog({
    required this.id,
    required this.doseTimeId,
    required this.status,
    required this.createdAt,
    this.takenAt,
    this.skippedReason,
  });

  final String id;
  final String doseTimeId;
  final String status; // 'TAKEN' | 'SKIPPED' | 'MISSED'
  final String createdAt;
  final String? takenAt;
  final String? skippedReason;

  bool get isTaken => status == 'TAKEN';
  bool get isSkipped => status == 'SKIPPED';
  bool get isMissed => status == 'MISSED';

  factory DoseLog.fromJson(Map<String, dynamic> json) => DoseLog(
        id: json['id'] as String,
        doseTimeId: json['doseTimeId'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        takenAt: json['takenAt'] as String?,
        skippedReason: json['skippedReason'] as String?,
      );
}
