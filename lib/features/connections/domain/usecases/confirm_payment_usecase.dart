import '../repositories/connections_repository.dart';

class ConfirmPaymentUseCase {
  const ConfirmPaymentUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<void> call({
    required String orderId,
    required String paymentId,
    required String signature,
  }) =>
      _repo.confirmPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
}
