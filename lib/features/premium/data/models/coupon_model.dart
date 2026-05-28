import '../../domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.valid,
    super.reason,
    super.couponId,
    super.code,
    super.discountType,
    super.discountValue,
    super.freeMonths,
    super.freePlanId,
    super.freePlanName,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        valid: json['valid'] as bool,
        reason: json['reason'] as String?,
        couponId: json['couponId'] as String?,
        code: json['code'] as String?,
        discountType: json['discountType'] as String?,
        discountValue: (json['discountValue'] as num?)?.toDouble(),
        freeMonths: json['freeMonths'] as int?,
        freePlanId: json['freePlanId'] as String?,
        freePlanName: json['freePlanName'] as String?,
      );
}
