import '../repositories/subscription_repository.dart';

class ConfirmSubscriptionPaymentUseCase {
  const ConfirmSubscriptionPaymentUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<void> call({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) =>
      _repo.confirmPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
}
