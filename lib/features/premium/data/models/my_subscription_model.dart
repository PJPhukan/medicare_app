import '../../domain/entities/my_subscription_entity.dart';
import 'plan_model.dart';

class MySubscriptionModel extends MySubscriptionEntity {
  const MySubscriptionModel({
    required super.subscriptionPlanId,
    required super.autoRenew,
    required super.plan,
    super.subscriptionExpiresAt,
    super.subscriptionCancelledAt,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) =>
      MySubscriptionModel(
        subscriptionPlanId: json['subscriptionPlanId'] as String,
        autoRenew: json['autoRenew'] as bool? ?? false,
        subscriptionExpiresAt: json['subscriptionExpiresAt'] as String?,
        subscriptionCancelledAt: json['subscriptionCancelledAt'] as String?,
        plan: PlanModel.fromJson(
            json['subscriptionPlan'] as Map<String, dynamic>),
      );
}
