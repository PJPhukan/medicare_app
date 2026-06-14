// Result of POST /requests/:id/pay — the Razorpay order needed for checkout.
class CreateRequestResult {
  const CreateRequestResult({
    required this.requestId,
    required this.amount,
    required this.razorpayOrderId,
    required this.razorpayKeyId,
  });

  final String requestId;

  /// Amount in rupees (backend stores/returns whole-rupee amounts).
  final int amount;
  final String razorpayOrderId;
  final String razorpayKeyId;

  int get amountPaise => amount * 100;

  factory CreateRequestResult.fromJson(Map<String, dynamic> json) =>
      CreateRequestResult(
        requestId: json['requestId'] as String,
        amount: (json['amount'] as num).toInt(),
        razorpayOrderId: json['razorpayOrderId'] as String,
        razorpayKeyId: json['razorpayKeyId'] as String,
      );
}
