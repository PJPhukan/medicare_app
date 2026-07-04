import '../../domain/entities/available_coupon_entity.dart';

class AvailableCouponModel extends AvailableCouponEntity {
  const AvailableCouponModel({
    required super.code,
    required super.discountType,
    required super.discountValue,
    super.description,
    super.expiresAt,
  });

  factory AvailableCouponModel.fromJson(Map<String, dynamic> json) =>
      AvailableCouponModel(
        code: json['code'] as String,
        discountType: json['discountType'] as String? ?? 'PERCENT',
        discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String?,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'] as String)
            : null,
      );
}
