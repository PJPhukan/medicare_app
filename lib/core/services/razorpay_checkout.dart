import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/utils/logger.dart';

/// Thrown when the patient cancels or the Razorpay checkout fails.
class RazorpayCheckoutException implements Exception {
  RazorpayCheckoutException(this.message, {this.code});
  final String message;
  final int? code;

  @override
  String toString() => message;
}

/// Successful checkout payload, forwarded to `confirm-payment`.
typedef RazorpayResult = ({String paymentId, String orderId, String signature});

/// Thin wrapper around [Razorpay] that turns the event-based SDK into a single
/// awaitable [open] call. Always [clear]s native listeners when done.
class RazorpayCheckout {
  RazorpayCheckout() : _razorpay = Razorpay();

  final Razorpay _razorpay;
  Completer<RazorpayResult>? _completer;

  Future<RazorpayResult> open({
    required String keyId,
    required String orderId,
    required int amountPaise,
    required String name,
    String currency = 'INR',
    String? description,
    String? email,
    String? contact,
  }) {
    if (_completer != null && !_completer!.isCompleted) {
      throw StateError('A payment is already in progress.');
    }
    _completer = Completer<RazorpayResult>();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': keyId,
      'amount': amountPaise,
      'order_id': orderId,
      'name': name,
      'description': description ?? 'Subscription Payment',
      'currency': currency,
      'prefill': {
        if (contact != null && contact.isNotEmpty) 'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      'theme': {'color': '#0FB9B1'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      AppLogger.e('Razorpay open failed', tag: 'Payment', error: e);
      _fail(RazorpayCheckoutException('Could not start payment: $e'));
    }

    return _completer!.future;
  }

  void _onSuccess(PaymentSuccessResponse res) {
    AppLogger.i('Razorpay success → payment:${res.paymentId}', tag: 'Payment');
    if (res.paymentId == null || res.orderId == null || res.signature == null) {
      _fail(RazorpayCheckoutException('Payment response was incomplete'));
      return;
    }
    _complete((
      paymentId: res.paymentId!,
      orderId: res.orderId!,
      signature: res.signature!,
    ));
  }

  void _onError(PaymentFailureResponse res) {
    AppLogger.e('Razorpay error → ${res.code}: ${res.message}', tag: 'Payment');
    final cancelled = res.code == Razorpay.PAYMENT_CANCELLED;
    _fail(RazorpayCheckoutException(
      cancelled ? 'Payment cancelled' : (res.message ?? 'Payment failed'),
      code: res.code,
    ));
  }

  void _onExternalWallet(ExternalWalletResponse res) {
    // External wallet selection does not complete the order in this flow.
    AppLogger.i('Razorpay external wallet: ${res.walletName}', tag: 'Payment');
    _fail(RazorpayCheckoutException('External wallet is not supported'));
  }

  void _complete(RazorpayResult result) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(result);
    }
    dispose();
  }

  void _fail(Object error) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(error);
    }
    dispose();
  }

  void dispose() {
    _razorpay.clear();
    _completer = null;
  }
}
