import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/coupon_entity.dart';
import '../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';
import '../widgets/active_plan_card.dart';
import '../widgets/subscription_billing_toggle.dart';
import '../widgets/subscription_coupon_section.dart';
import '../../../auth/presentation/widgets/auth_shell.dart';
import '../../../../core/services/razorpay_checkout.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({
    super.key,
    this.onDone,
    required this.onBack,
  });

  final VoidCallback? onDone;
  final VoidCallback onBack;

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _selectedIndex = 0;
  BillingCycle _cycle = BillingCycle.monthly;
  bool _acting = false;
  bool _couponLoading = false;
  bool _didAutoSkip = false;

  /// If the backend has no plans configured, skip this screen entirely.
  void _autoSkipIfNeeded(SubscriptionState st) {
    if (_didAutoSkip) return;
    if (st.isLoadingPlans || st.isLoadingMine) return;
    if (st.plans.isEmpty) {
      _didAutoSkip = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDone?.call();
      });
    }
  }

  String _ctaLabel(bool hasActivePaidSub, bool selectedIsFree,
      PlanEntity? selectedPlan, CouponEntity? coupon) {
    if (hasActivePaidSub) return AppStrings.continueText;
    if (selectedIsFree) return AppStrings.startForFree;
    if (coupon?.valid == true && selectedPlan != null) {
      final sym = selectedPlan.currency == 'INR' ? '₹' : '\$';
      final discounted = _discountedAmount(selectedPlan, coupon!);
      return 'Get ${selectedPlan.name} · $sym${discounted.toStringAsFixed(0)}/ Month';
    }
    return 'Get ${selectedPlan!.name}';
  }

  double _discountedAmount(PlanEntity plan, CouponEntity coupon) {
    final base = _cycle == BillingCycle.yearly
        ? plan.priceYearly / 12
        : plan.priceMonthly.toDouble();
    if (coupon.discountType == 'PERCENT') {
      return base * (1 - (coupon.discountValue ?? 0) / 100);
    }
    return (base - (coupon.discountValue ?? 0)).clamp(0, double.infinity).toDouble();
  }


  @override
  Widget build(BuildContext context) {
    final st = ref.watch(subscriptionProvider);
    _autoSkipIfNeeded(st);

    final plans            = st.plans;
    final sub              = st.mySubscription;
    final hasActivePaidSub = sub != null && sub.isActive && !sub.plan.isFree;
    final isLoading        = (st.isLoadingPlans || st.isLoadingMine) && plans.isEmpty;

    final selectedPlan = plans.isNotEmpty && _selectedIndex < plans.length
        ? plans[_selectedIndex]
        : plans.firstOrNull;
    final selectedIsFree = selectedPlan?.isFree ?? true;

    return AuthShell(
      leading: AppBarLeading.back,
      onBack: widget.onBack,
      bottomBar: isLoading
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthButton(
                  label: _ctaLabel(
                      hasActivePaidSub, selectedIsFree, selectedPlan, st.coupon),
                  loading: _acting,
                  onPressed: _acting
                      ? null
                      : () => hasActivePaidSub
                          ? widget.onDone?.call()
                          : _onContinue(plans, selectedPlan, st.coupon),
                ),
                const SizedBox(height: 8),
                Center(child: AppText.caption(AppStrings.noCreditCard)),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                AppText.h1(
                  AppStrings.choosePlan,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                AppText.labelMd(
                  AppStrings.planSubtitle,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!isLoading && !hasActivePaidSub && plans.any((p) => !p.isFree))
            SubscriptionBillingToggle(
              cycle: _cycle,
              plans: plans,
              onChanged: (c) => setState(() => _cycle = c),
            ),

          const SizedBox(height: 16),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                    color: AppColors.teal, strokeWidth: 2),
              ),
            )
          else if (hasActivePaidSub)
            ActivePlanCard(subscription: sub)
          else ...[
            ...() {
              final sorted = [...plans]
                ..sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));
              return plans.asMap().entries.map((e) {
                final si = sorted.indexWhere((p) => p.id == e.value.id);
                return PlanCard(
                  plan: e.value,
                  cycle: _cycle,
                  lowerPlan: si > 0 ? sorted[si - 1] : null,
                  selected: _selectedIndex == e.key,
                  onTap: () => setState(() => _selectedIndex = e.key),
                );
              });
            }(),
          ],

          if (!isLoading && !hasActivePaidSub && !selectedIsFree) ...[
            const SizedBox(height: 16),
            SubscriptionCouponSection(
              coupon: st.coupon,
              loading: _couponLoading,
              planId: selectedPlan?.id,
              availableCoupons: st.availableCoupons,
              onValidate: (code, {planId}) => _validateCoupon(code, planId),
              onClear: () =>
                  ref.read(subscriptionProvider.notifier).clearCoupon(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _validateCoupon(String code, String? planId) async {
    setState(() => _couponLoading = true);
    await ref
        .read(subscriptionProvider.notifier)
        .validateCoupon(code, planId: planId);
    if (mounted) setState(() => _couponLoading = false);
  }

  Future<void> _onContinue(
      List<PlanEntity> plans, PlanEntity? selected, CouponEntity? coupon) async {
    if (plans.isEmpty || selected == null) {
      widget.onDone?.call();
      return;
    }

    if (selected.isFree) {
      setState(() => _acting = true);
      try {
        await ref.read(subscriptionProvider.notifier).selectPlan(selected.id);
      } catch (_) {}
      if (mounted) {
        setState(() => _acting = false);
        widget.onDone?.call();
      }
      return;
    }

    setState(() => _acting = true);
    final notifier = ref.read(subscriptionProvider.notifier);
    final order = await notifier.createOrder(
      planId: selected.id,
      billingCycle: _cycle.name,
      couponCode: coupon?.valid == true ? coupon!.code : null,
    );
    if (!mounted || order == null) {
      if (mounted) setState(() => _acting = false);
      return;
    }

    try {
      final result = await RazorpayCheckout().open(
        keyId: order.razorpayKeyId,
        orderId: order.razorpayOrderId,
        amountPaise: order.amountPaise,
        name: selected.name,
        currency: order.currency,
      );
      final success = await notifier.confirmPayment(
        razorpayOrderId: result.orderId,
        razorpayPaymentId: result.paymentId,
        razorpaySignature: result.signature,
      );
      if (mounted) {
        setState(() => _acting = false);
        if (success) widget.onDone?.call();
      }
    } on RazorpayCheckoutException {
      if (mounted) setState(() => _acting = false);
    } catch (_) {
      if (mounted) setState(() => _acting = false);
    }
  }
}
