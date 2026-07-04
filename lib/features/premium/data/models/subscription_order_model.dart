import '../../domain/entities/subscription_order_entity.dart';

class SubscriptionOrderModel extends SubscriptionOrderEntity {
  const SubscriptionOrderModel({
    required super.razorpayOrderId,
    required super.razorpayKeyId,
    required super.amount,
    required super.currency,
    required super.originalAmount,
    required super.discountApplied,
  });

  factory SubscriptionOrderModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionOrderModel(
        razorpayOrderId: json['razorpayOrderId'] as String,
        razorpayKeyId: json['razorpayKeyId'] as String,
        amount: (json['amount'] as num).toInt(),
        currency: json['currency'] as String? ?? 'INR',
        originalAmount: (json['originalAmount'] as num?)?.toInt() ??
            (json['amount'] as num).toInt(),
        discountApplied: (json['discountApplied'] as num?)?.toInt() ?? 0,
      );
}
