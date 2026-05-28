import '../../domain/entities/purchase_result_entity.dart';

class PurchaseResultModel extends PurchaseResultEntity {
  const PurchaseResultModel({
    required super.planId,
    required super.planName,
    required super.billingCycle,
    required super.originalPrice,
    required super.finalPrice,
    required super.currency,
    required super.expiresAt,
    required super.transactionId,
    super.discountApplied,
  });

  factory PurchaseResultModel.fromJson(Map<String, dynamic> json) =>
      PurchaseResultModel(
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        billingCycle: json['billingCycle'] as String,
        originalPrice: (json['originalPrice'] as num).toDouble(),
        finalPrice: (json['finalPrice'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        expiresAt: json['expiresAt'] as String,
        transactionId: json['transactionId'] as String,
        discountApplied: (json['discountApplied'] as num?)?.toDouble(),
      );
}
