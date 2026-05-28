class PurchaseResultEntity {
  const PurchaseResultEntity({
    required this.planId,
    required this.planName,
    required this.billingCycle,
    required this.originalPrice,
    required this.finalPrice,
    required this.currency,
    required this.expiresAt,
    required this.transactionId,
    this.discountApplied,
  });

  final String planId;
  final String planName;
  final String billingCycle;
  final double originalPrice;
  final double finalPrice;
  final String currency;
  final String expiresAt;
  final String transactionId;
  final double? discountApplied;
}
