class CouponEntity {
  const CouponEntity({
    required this.valid,
    this.reason,
    this.couponId,
    this.code,
    this.discountType,
    this.discountValue,
    this.freeMonths,
    this.freePlanId,
    this.freePlanName,
  });

  final bool valid;
  final String? reason;
  final String? couponId;
  final String? code;
  final String? discountType;
  final double? discountValue;
  final int? freeMonths;
  final String? freePlanId;
  final String? freePlanName;
}
