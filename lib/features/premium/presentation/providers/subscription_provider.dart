import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/entities/purchase_result_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/get_my_subscription_usecase.dart';
import '../../domain/usecases/select_plan_usecase.dart';
import '../../domain/usecases/purchase_plan_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/toggle_auto_renew_usecase.dart';
import '../../domain/usecases/validate_coupon_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/create_subscription_order_usecase.dart';
import '../../domain/usecases/confirm_subscription_payment_usecase.dart';
import '../../domain/usecases/get_available_coupons_usecase.dart';
import '../../domain/entities/subscription_order_entity.dart';
import '../../domain/entities/available_coupon_entity.dart';

// ── DI providers ──────────────────────────────────────────────────────────────

final _subscriptionDsProvider = Provider<SubscriptionRemoteDataSource>(
  (ref) => SubscriptionRemoteDataSource(ref.read(dioProvider)),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(ref.read(_subscriptionDsProvider)),
);

// ── Use-case providers ────────────────────────────────────────────────────────

final getPlansProvider = Provider<GetPlansUseCase>(
  (ref) => GetPlansUseCase(ref.read(subscriptionRepositoryProvider)),
);

final getMySubscriptionProvider = Provider<GetMySubscriptionUseCase>((ref) {
  ref.watch(authTokenProvider);
  return GetMySubscriptionUseCase(ref.read(subscriptionRepositoryProvider));
});

final selectPlanProvider = Provider<SelectPlanUseCase>((ref) {
  ref.watch(authTokenProvider);
  return SelectPlanUseCase(ref.read(subscriptionRepositoryProvider));
});

final purchasePlanProvider = Provider<PurchasePlanUseCase>((ref) {
  ref.watch(authTokenProvider);
  return PurchasePlanUseCase(ref.read(subscriptionRepositoryProvider));
});

final cancelSubscriptionProvider = Provider<CancelSubscriptionUseCase>((ref) {
  ref.watch(authTokenProvider);
  return CancelSubscriptionUseCase(ref.read(subscriptionRepositoryProvider));
});

final toggleAutoRenewProvider = Provider<ToggleAutoRenewUseCase>((ref) {
  ref.watch(authTokenProvider);
  return ToggleAutoRenewUseCase(ref.read(subscriptionRepositoryProvider));
});

final validateCouponProvider = Provider<ValidateCouponUseCase>(
  (ref) => ValidateCouponUseCase(ref.read(subscriptionRepositoryProvider)),
);

final applyCouponProvider = Provider<ApplyCouponUseCase>((ref) {
  ref.watch(authTokenProvider);
  return ApplyCouponUseCase(ref.read(subscriptionRepositoryProvider));
});

final createSubscriptionOrderProvider = Provider<CreateSubscriptionOrderUseCase>((ref) {
  ref.watch(authTokenProvider);
  return CreateSubscriptionOrderUseCase(ref.read(subscriptionRepositoryProvider));
});

final confirmSubscriptionPaymentProvider = Provider<ConfirmSubscriptionPaymentUseCase>((ref) {
  ref.watch(authTokenProvider);
  return ConfirmSubscriptionPaymentUseCase(ref.read(subscriptionRepositoryProvider));
});

final getAvailableCouponsProvider = Provider<GetAvailableCouponsUseCase>(
  (ref) => GetAvailableCouponsUseCase(ref.read(subscriptionRepositoryProvider)),
);

// ── State ─────────────────────────────────────────────────────────────────────

class SubscriptionState {
  const SubscriptionState({
    this.plans = const [],
    this.availableCoupons = const [],
    this.mySubscription,
    this.coupon,
    this.purchaseResult,
    this.isLoadingPlans = false,
    this.isLoadingMine = false,
    this.isActing = false,
    this.error,
  });

  final List<PlanEntity> plans;
  final List<AvailableCouponEntity> availableCoupons;
  final MySubscriptionEntity? mySubscription;
  final CouponEntity? coupon;
  final PurchaseResultEntity? purchaseResult;
  final bool isLoadingPlans;
  final bool isLoadingMine;
  final bool isActing;
  final String? error;

  bool get isOnFreePlan =>
      mySubscription == null || mySubscription!.plan.isFree;

  SubscriptionState copyWith({
    List<PlanEntity>? plans,
    List<AvailableCouponEntity>? availableCoupons,
    MySubscriptionEntity? mySubscription,
    bool clearSubscription = false,
    CouponEntity? coupon,
    bool clearCoupon = false,
    PurchaseResultEntity? purchaseResult,
    bool clearPurchaseResult = false,
    bool? isLoadingPlans,
    bool? isLoadingMine,
    bool? isActing,
    String? error,
    bool clearError = false,
  }) =>
      SubscriptionState(
        plans: plans ?? this.plans,
        availableCoupons: availableCoupons ?? this.availableCoupons,
        mySubscription: clearSubscription ? null : mySubscription ?? this.mySubscription,
        coupon: clearCoupon ? null : coupon ?? this.coupon,
        purchaseResult: clearPurchaseResult ? null : purchaseResult ?? this.purchaseResult,
        isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
        isLoadingMine: isLoadingMine ?? this.isLoadingMine,
        isActing: isActing ?? this.isActing,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier({
    required GetPlansUseCase getPlans,
    required GetMySubscriptionUseCase getMySubscription,
    required SelectPlanUseCase selectPlan,
    required PurchasePlanUseCase purchasePlan,
    required CancelSubscriptionUseCase cancelSubscription,
    required ToggleAutoRenewUseCase toggleAutoRenew,
    required ValidateCouponUseCase validateCoupon,
    required ApplyCouponUseCase applyCoupon,
    required CreateSubscriptionOrderUseCase createOrder,
    required ConfirmSubscriptionPaymentUseCase confirmPayment,
    required GetAvailableCouponsUseCase getAvailableCoupons,
  })  : _getPlans = getPlans,
        _getMine = getMySubscription,
        _selectPlan = selectPlan,
        _purchase = purchasePlan,
        _cancel = cancelSubscription,
        _toggleAutoRenew = toggleAutoRenew,
        _validateCoupon = validateCoupon,
        _applyCoupon = applyCoupon,
        _createOrder = createOrder,
        _confirmPayment = confirmPayment,
        _getAvailableCoupons = getAvailableCoupons,
        super(const SubscriptionState(isLoadingPlans: true, isLoadingMine: true)) {
    loadAll();
  }

  final GetPlansUseCase _getPlans;
  final GetMySubscriptionUseCase _getMine;
  final SelectPlanUseCase _selectPlan;
  final PurchasePlanUseCase _purchase;
  final CancelSubscriptionUseCase _cancel;
  final ToggleAutoRenewUseCase _toggleAutoRenew;
  final ValidateCouponUseCase _validateCoupon;
  final ApplyCouponUseCase _applyCoupon;
  final CreateSubscriptionOrderUseCase _createOrder;
  final ConfirmSubscriptionPaymentUseCase _confirmPayment;
  final GetAvailableCouponsUseCase _getAvailableCoupons;

  Future<void> loadAll() async {
    await Future.wait([loadPlans(), loadMySubscription(), loadAvailableCoupons()]);
  }

  Future<void> loadAvailableCoupons() async {
    try {
      final coupons = await _getAvailableCoupons();
      state = state.copyWith(availableCoupons: coupons);
    } catch (_) {}
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    try {
      final plans = await _getPlans();
      state = state.copyWith(plans: plans, isLoadingPlans: false);
    } catch (e) {
      state = state.copyWith(isLoadingPlans: false, error: e.toString());
    }
  }

  Future<void> loadMySubscription() async {
    state = state.copyWith(isLoadingMine: true);
    try {
      final sub = await _getMine();
      state = state.copyWith(mySubscription: sub, isLoadingMine: false);
    } catch (_) {
      state = state.copyWith(isLoadingMine: false);
    }
  }

  Future<void> selectPlan(String planId) async {
    AppLogger.i('Plan select → id:$planId', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _selectPlan(planId);
      await loadMySubscription();
      AppLogger.i('Plan selected ✓', tag: 'Subscription');
    } catch (e, s) {
      AppLogger.e('Plan select failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isActing: false);
    }
  }

  Future<PurchaseResultEntity?> purchasePlan({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) async {
    AppLogger.i('Plan purchase → id:$planId cycle:$billingCycle coupon:${couponCode != null}', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      final result = await _purchase(
        planId: planId,
        billingCycle: billingCycle,
        couponCode: couponCode,
      );
      state = state.copyWith(purchaseResult: result, isActing: false);
      await loadMySubscription();
      AppLogger.i('Plan purchased ✓', tag: 'Subscription');
      AppLogger.track('subscription.purchased', meta: {'planId': planId, 'billingCycle': billingCycle});
      return result;
    } catch (e, s) {
      AppLogger.e('Plan purchase failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(isActing: false, error: e.toString());
      return null;
    }
  }

  Future<void> cancelSubscription() async {
    AppLogger.i('Subscription cancel', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _cancel();
      await loadMySubscription();
      AppLogger.i('Subscription cancelled ✓', tag: 'Subscription');
      AppLogger.track('subscription.cancelled');
    } catch (e, s) {
      AppLogger.e('Subscription cancel failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isActing: false);
    }
  }

  Future<void> toggleAutoRenew(bool enabled) async {
    AppLogger.i('Auto-renew toggle → $enabled', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _toggleAutoRenew(enabled);
      await loadMySubscription();
      AppLogger.i('Auto-renew toggled ✓', tag: 'Subscription');
    } catch (e, s) {
      AppLogger.e('Auto-renew toggle failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isActing: false);
    }
  }

  Future<CouponEntity?> validateCoupon(String code, {String? planId}) async {
    AppLogger.i('Coupon validate', tag: 'Subscription');
    state = state.copyWith(clearCoupon: true, clearError: true);
    try {
      final coupon = await _validateCoupon(code: code, planId: planId);
      state = state.copyWith(coupon: coupon);
      AppLogger.i('Coupon valid ✓', tag: 'Subscription');
      return coupon;
    } catch (e, s) {
      AppLogger.e('Coupon validate failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<CouponEntity?> applyCoupon(String code, {String? planId}) async {
    AppLogger.i('Coupon apply', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearCoupon: true, clearError: true);
    try {
      final coupon = await _applyCoupon(code: code, planId: planId);
      state = state.copyWith(coupon: coupon, isActing: false);
      AppLogger.i('Coupon applied ✓', tag: 'Subscription');
      return coupon;
    } catch (e, s) {
      AppLogger.e('Coupon apply failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(isActing: false, error: e.toString());
      return null;
    }
  }

  Future<SubscriptionOrderEntity?> createOrder({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) async {
    AppLogger.i('Create order → plan:$planId cycle:$billingCycle', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      final order = await _createOrder(
        planId: planId,
        billingCycle: billingCycle,
        couponCode: couponCode,
      );
      state = state.copyWith(isActing: false);
      return order;
    } catch (e, s) {
      AppLogger.e('Create order failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(isActing: false, error: e.toString());
      return null;
    }
  }

  Future<bool> confirmPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    AppLogger.i('Confirm payment → order:$razorpayOrderId', tag: 'Subscription');
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _confirmPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      await loadMySubscription();
      AppLogger.i('Payment confirmed ✓', tag: 'Subscription');
      AppLogger.track('subscription.paid', meta: {'planId': razorpayOrderId});
      state = state.copyWith(isActing: false);
      return true;
    } catch (e, s) {
      AppLogger.e('Confirm payment failed', tag: 'Subscription', error: e, stack: s);
      state = state.copyWith(isActing: false, error: e.toString());
      return false;
    }
  }

  void clearCoupon() => state = state.copyWith(clearCoupon: true);
  void clearError() => state = state.copyWith(clearError: true);
}

// ── Top-level provider ────────────────────────────────────────────────────────

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  ref.watch(authTokenProvider);
  return SubscriptionNotifier(
    getPlans: ref.read(getPlansProvider),
    getMySubscription: ref.read(getMySubscriptionProvider),
    selectPlan: ref.read(selectPlanProvider),
    purchasePlan: ref.read(purchasePlanProvider),
    cancelSubscription: ref.read(cancelSubscriptionProvider),
    toggleAutoRenew: ref.read(toggleAutoRenewProvider),
    validateCoupon: ref.read(validateCouponProvider),
    applyCoupon: ref.read(applyCouponProvider),
    createOrder: ref.read(createSubscriptionOrderProvider),
    confirmPayment: ref.read(confirmSubscriptionPaymentProvider),
    getAvailableCoupons: ref.read(getAvailableCouponsProvider),
  );
});
