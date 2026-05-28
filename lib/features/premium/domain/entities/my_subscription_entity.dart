import 'plan_entity.dart';

class MySubscriptionEntity {
  const MySubscriptionEntity({
    required this.subscriptionPlanId,
    required this.autoRenew,
    required this.plan,
    this.subscriptionExpiresAt,
    this.subscriptionCancelledAt,
  });

  final String subscriptionPlanId;
  final bool autoRenew;
  final PlanEntity plan;
  final String? subscriptionExpiresAt;
  final String? subscriptionCancelledAt;

  bool get isActive => subscriptionCancelledAt == null &&
      (subscriptionExpiresAt == null ||
          DateTime.tryParse(subscriptionExpiresAt!)?.isAfter(DateTime.now()) == true);

  bool get isCancelled => subscriptionCancelledAt != null;

  DateTime? get expiresAt => subscriptionExpiresAt != null
      ? DateTime.tryParse(subscriptionExpiresAt!)?.toLocal()
      : null;
}
