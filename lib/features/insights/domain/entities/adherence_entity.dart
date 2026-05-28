// Pure domain entity for medication adherence data.
// No Flutter, no JSON, no Dio.

class DailyAdherenceEntity {
  const DailyAdherenceEntity({
    required this.date,
    required this.total,
    required this.taken,
    required this.skipped,
    required this.missed,
  });

  final String date;
  final int total;
  final int taken;
  final int skipped;
  final int missed;

  double get rate => total == 0 ? 0.0 : taken / total;
  DateTime get dateTime => DateTime.parse(date);
}

class AdherenceEntity {
  const AdherenceEntity({
    required this.overallRate,
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.missedDoses,
    required this.daily,
    required this.periodDays,
  });

  final double overallRate;
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final int missedDoses;
  final List<DailyAdherenceEntity> daily;
  final int periodDays;

  bool get isGood => overallRate >= 0.8;
}
