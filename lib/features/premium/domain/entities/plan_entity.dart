class PlanEntity {
  const PlanEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.maxPatients,
    required this.maxCaretakers,
    required this.priceMonthly,
    required this.priceYearly,
    required this.trialDays,
    required this.features,
    required this.currency,
  });

  final String id;
  final String name;
  final String code;
  final String description;
  final int maxPatients;
  final int maxCaretakers;
  final double priceMonthly;
  final double priceYearly;
  final int trialDays;
  final List<String> features;
  final String currency;

  bool get isFree => priceMonthly == 0;
}
