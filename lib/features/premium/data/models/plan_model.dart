import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.code,
    required super.description,
    required super.maxPatients,
    required super.maxCaretakers,
    required super.priceMonthly,
    required super.priceYearly,
    required super.trialDays,
    required super.features,
    required super.currency,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        description: json['description'] as String? ?? '',
        maxPatients: json['maxPatients'] as int? ?? 1,
        maxCaretakers: json['maxCaretakers'] as int? ?? 0,
        priceMonthly: (json['priceMonthly'] as num?)?.toDouble() ?? 0,
        priceYearly: (json['priceYearly'] as num?)?.toDouble() ?? 0,
        trialDays: json['trialDays'] as int? ?? 0,
        features: (json['features'] as List<dynamic>? ?? []).cast<String>(),
        currency: json['currency'] as String? ?? 'INR',
      );
}
