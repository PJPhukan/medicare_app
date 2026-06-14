import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/constants/api_constants.dart';

// ─── Payout details (bank / UPI) ──────────────────────────────────────────────

class PayoutDetails {
  const PayoutDetails({
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfsc,
    this.upiId,
  });

  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final String? upiId;

  bool get isSet =>
      (bankAccountNumber?.isNotEmpty ?? false) || (upiId?.isNotEmpty ?? false);

  factory PayoutDetails.fromJson(Map<String, dynamic> json) => PayoutDetails(
        bankAccountName:   json['bankAccountName'] as String?,
        bankAccountNumber: json['bankAccountNumber'] as String?,
        bankIfsc:          json['bankIfsc'] as String?,
        upiId:             json['upiId'] as String?,
      );
}

class PayoutDetailsState {
  const PayoutDetailsState({
    this.details,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final PayoutDetails? details;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  PayoutDetailsState copyWith({
    PayoutDetails? details,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      PayoutDetailsState(
        details:   details   ?? this.details,
        isLoading: isLoading ?? this.isLoading,
        isSaving:  isSaving  ?? this.isSaving,
        error:     clearError ? null : (error ?? this.error),
      );
}

class PayoutDetailsNotifier extends StateNotifier<PayoutDetailsState> {
  PayoutDetailsNotifier(this._ref) : super(const PayoutDetailsState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(ApiConstants.profPayoutDetails);
      state = state.copyWith(
        details: PayoutDetails.fromJson(res.data!['data'] as Map<String, dynamic>),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Save payout details. Throws on failure so the screen can surface it.
  Future<void> save({
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfsc,
    String? upiId,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dio = _ref.read(dioProvider);
      final res = await dio.patch<Map<String, dynamic>>(
        ApiConstants.profPayoutDetails,
        data: {
          'bankAccountName': bankAccountName,
          'bankAccountNumber': bankAccountNumber,
          'bankIfsc': bankIfsc,
          'upiId': upiId,
        },
      );
      state = state.copyWith(
        details: PayoutDetails.fromJson(res.data!['data'] as Map<String, dynamic>),
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final payoutDetailsProvider =
    StateNotifierProvider<PayoutDetailsNotifier, PayoutDetailsState>(
  (ref) => PayoutDetailsNotifier(ref),
);
