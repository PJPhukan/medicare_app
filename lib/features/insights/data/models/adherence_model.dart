import '../../domain/entities/adherence_entity.dart';

class DailyAdherence extends DailyAdherenceEntity {
  const DailyAdherence({
    required super.date,
    required super.total,
    required super.taken,
    required super.skipped,
    required super.missed,
  });

  factory DailyAdherence.fromJson(Map<String, dynamic> json) => DailyAdherence(
        date: json['date'] as String,
        total: json['total'] as int? ?? 0,
        taken: json['taken'] as int? ?? 0,
        skipped: json['skipped'] as int? ?? 0,
        missed: json['missed'] as int? ?? 0,
      );
}

class Adherence extends AdherenceEntity {
  const Adherence({
    required super.overallRate,
    required super.totalDoses,
    required super.takenDoses,
    required super.skippedDoses,
    required super.missedDoses,
    required List<DailyAdherence> daily,
    required super.periodDays,
  }) : super(daily: daily);

  @override
  List<DailyAdherence> get daily => super.daily.cast<DailyAdherence>();

  factory Adherence.fromJson(Map<String, dynamic> json) => Adherence(
        overallRate: (json['overallRate'] as num?)?.toDouble() ?? 0.0,
        totalDoses: json['totalDoses'] as int? ?? 0,
        takenDoses: json['takenDoses'] as int? ?? 0,
        skippedDoses: json['skippedDoses'] as int? ?? 0,
        missedDoses: json['missedDoses'] as int? ?? 0,
        periodDays: json['periodDays'] as int? ?? 7,
        daily: (json['daily'] as List<dynamic>? ?? [])
            .map((e) => DailyAdherence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
