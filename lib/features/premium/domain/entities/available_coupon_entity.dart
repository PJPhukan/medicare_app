class AvailableCouponEntity {
  const AvailableCouponEntity({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.description,
    this.expiresAt,
  });

  final String code;
  final String discountType; // 'PERCENT' | 'FLAT' | 'FREE_MONTHS'
  final double discountValue;
  final String? description;
  final DateTime? expiresAt;
}
