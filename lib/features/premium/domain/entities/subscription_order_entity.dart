class SubscriptionOrderEntity {
  const SubscriptionOrderEntity({
    required this.razorpayOrderId,
    required this.razorpayKeyId,
    required this.amount,
    required this.currency,
    required this.originalAmount,
    required this.discountApplied,
  });

  final String razorpayOrderId;
  final String razorpayKeyId;

  /// Final amount after discount, in whole currency units (₹).
  final int amount;
  final String currency;

  /// Amount before coupon discount.
  final int originalAmount;

  /// Discount in whole currency units (0 if no coupon).
  final int discountApplied;

  bool get hasDiscount => discountApplied > 0;

  int get amountPaise => amount * 100;
}
