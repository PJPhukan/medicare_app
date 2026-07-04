import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_coupon_section.dart';
import '../../../../core/services/razorpay_checkout.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  String _billingCycle = 'monthly';
  String? _selectedPlanId;
  bool _couponLoading = false;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(subscriptionProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            onPressed: () => context.pop(),
          ),
          title: const Text('Subscription', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        body: st.isLoadingPlans && st.plans.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!st.isLoadingMine)
                            _StatusCard(sub: st.mySubscription),
                          if (!st.isLoadingMine) const SizedBox(height: 20),

                          if (st.error != null)
                            _ErrorBanner(
                              message: st.error!,
                              onDismiss: () =>
                                  ref.read(subscriptionProvider.notifier).clearError(),
                            ),
                          if (st.error != null) const SizedBox(height: 12),

                          if (st.plans.any((p) => !p.isFree)) ...[
                            _BillingToggle(
                              selected: _billingCycle,
                              onChanged: (v) => setState(() => _billingCycle = v),
                            ),
                            const SizedBox(height: 16),
                          ],

                          ...st.plans.map((plan) {
                            final isCurrent =
                                st.mySubscription?.subscriptionPlanId == plan.id;
                            final isSelected = _selectedPlanId == plan.id;
                            return _PlanCard(
                              plan: plan,
                              billingCycle: _billingCycle,
                              isCurrent: isCurrent,
                              isSelected: isSelected,
                              onTap: isCurrent
                                  ? null
                                  : () => setState(() => _selectedPlanId = plan.id),
                            );
                          }),

                          if (_selectedPlanId != null &&
                              !(st.plans
                                      .firstWhere((p) => p.id == _selectedPlanId,
                                          orElse: () => st.plans.first)
                                      .isFree)) ...[
                            const SizedBox(height: 8),
                            SubscriptionCouponSection(
                              coupon: st.coupon,
                              loading: _couponLoading,
                              planId: _selectedPlanId,
                              availableCoupons: st.availableCoupons,
                              onValidate: (code, {planId}) =>
                                  _validateCoupon(code, planId: planId),
                              onClear: () =>
                                  ref.read(subscriptionProvider.notifier).clearCoupon(),
                            ),
                          ],

                          const SizedBox(height: 20),

                          if (_selectedPlanId != null)
                            _CtaButton(
                              plan: st.plans.firstWhere(
                                (p) => p.id == _selectedPlanId,
                                orElse: () => st.plans.first,
                              ),
                              billingCycle: _billingCycle,
                              couponCode:
                                  st.coupon?.valid == true ? st.coupon?.code : null,
                              isActing: st.isActing,
                              onConfirm: _onConfirm,
                            ),

                          if (st.mySubscription != null &&
                              !st.mySubscription!.plan.isFree &&
                              st.mySubscription!.isActive) ...[
                            const SizedBox(height: 20),
                            _ManageSection(
                              sub: st.mySubscription!,
                              isActing: st.isActing,
                              onToggleAutoRenew: (v) => ref
                                  .read(subscriptionProvider.notifier)
                                  .toggleAutoRenew(v),
                              onCancel: _confirmCancel,
                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _validateCoupon(String code, {String? planId}) async {
    if (code.isEmpty) return;
    setState(() => _couponLoading = true);
    await ref
        .read(subscriptionProvider.notifier)
        .validateCoupon(code, planId: planId ?? _selectedPlanId);
    if (mounted) setState(() => _couponLoading = false);
  }

  Future<void> _onConfirm() async {
    final plan = ref
        .read(subscriptionProvider)
        .plans
        .firstWhere((p) => p.id == _selectedPlanId!);

    if (plan.isFree) {
      await ref.read(subscriptionProvider.notifier).selectPlan(plan.id);
      if (mounted) context.pop();
      return;
    }

    final notifier = ref.read(subscriptionProvider.notifier);
    final couponCode = ref.read(subscriptionProvider).coupon?.valid == true
        ? ref.read(subscriptionProvider).coupon?.code
        : null;

    final order = await notifier.createOrder(
      planId: plan.id,
      billingCycle: _billingCycle,
      couponCode: couponCode,
    );
    if (!mounted || order == null) return;

    try {
      final result = await RazorpayCheckout().open(
        keyId: order.razorpayKeyId,
        orderId: order.razorpayOrderId,
        amountPaise: order.amountPaise,
        name: plan.name,
        currency: order.currency,
      );
      final success = await notifier.confirmPayment(
        razorpayOrderId: result.orderId,
        razorpayPaymentId: result.paymentId,
        razorpaySignature: result.signature,
      );
      if (success && mounted) {
        final sub = ref.read(subscriptionProvider).mySubscription;
        _showSuccess(
          plan.name,
          sub?.expiresAt?.toIso8601String() ?? '',
        );
      }
    } on RazorpayCheckoutException {
      // user cancelled — no-op
    }
  }

  void _showSuccess(String planName, String expiresAt) {
    final dt = DateTime.tryParse(expiresAt)?.toLocal();
    final label = dt != null ? '${dt.day}/${dt.month}/${dt.year}' : expiresAt;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: AppText.h3('Subscribed!'),
        content: AppText.bodyMd(
          'You\'re now on $planName. Valid until $label.',
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Done', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.teal)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Cancel Subscription',
      message: 'Your plan will remain active until the end of the billing period.',
      confirmLabel: 'Cancel Plan',
      cancelLabel: 'Keep Plan',
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(subscriptionProvider.notifier).cancelSubscription();
  }
}

// ── Current status card ───────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final MySubscriptionEntity? sub;
  const _StatusCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final isFree = sub == null || sub!.plan.isFree;
    final color = isFree ? AppColors.teal : AppColors.purple;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFree ? Icons.workspace_premium_outlined : Icons.workspace_premium_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelMd(sub?.plan.name ?? 'Free Plan', color: color),
                if (sub != null && !isFree && sub!.expiresAt != null)
                  AppText.bodyXs('Renews ${_fmt(sub!.expiresAt!)}', color: AppColors.textSecondary),
                if (sub != null && sub!.isCancelled)
                  AppText.bodyXs(
                    'Cancelled — active until ${sub!.expiresAt != null ? _fmt(sub!.expiresAt!) : "—"}',
                    color: AppColors.amber,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppBorderRadius.pill,
            ),
            child: AppText.labelXs(
              isFree ? 'FREE' : 'ACTIVE',
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ── Billing toggle ────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _BillingToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          _Seg(label: 'Monthly', value: 'monthly', selected: selected, onTap: onChanged),
          _Seg(label: 'Yearly  (save 20%)', value: 'yearly', selected: selected, onTap: onChanged),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _Seg({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.transparent,
            borderRadius: AppBorderRadius.pill,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final String billingCycle;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.plan,
    required this.billingCycle,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accent => plan.isFree ? AppColors.teal : AppColors.purple;

  String get _priceLabel {
    if (plan.isFree) return 'Free';
    final price = billingCycle == 'yearly' ? plan.priceYearly / 12 : plan.priceMonthly;
    final sym = plan.currency == 'INR' ? '₹' : '\$';
    return '$sym${price.toStringAsFixed(0)}/mo';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? _accent
        : isCurrent
            ? _accent.withValues(alpha: 0.35)
            : context.borderCol;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _accent.withValues(alpha: 0.07) : context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppText.labelMd(plan.name, color: isSelected ? _accent : context.primaryText),
                      const SizedBox(width: 8),
                      AppContainer.tinted(
                        color: _accent,
                        borderRadius: AppBorderRadius.pill,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        child: AppText.labelXs(
                          plan.isFree ? 'FREE' : 'PREMIUM',
                          color: _accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _priceLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _accent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 13, color: _accent),
                      const SizedBox(width: 7),
                      Expanded(child: AppText.bodyXs(f, color: AppColors.textSecondary)),
                    ],
                  ),
                )),
            if (isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: _accent, size: 13),
                    const SizedBox(width: 6),
                    Text('Current plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accent)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final PlanEntity plan;
  final String billingCycle;
  final String? couponCode;
  final bool isActing;
  final VoidCallback onConfirm;

  const _CtaButton({
    required this.plan,
    required this.billingCycle,
    required this.isActing,
    required this.onConfirm,
    this.couponCode,
  });

  @override
  Widget build(BuildContext context) {
    final label = plan.isFree
        ? 'Switch to Free Plan'
        : 'Subscribe — ${billingCycle == 'yearly' ? 'Yearly' : 'Monthly'}';

    return GestureDetector(
      onTap: isActing ? null : onConfirm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isActing ? AppColors.teal.withValues(alpha: 0.6) : AppColors.teal,
          borderRadius: AppBorderRadius.lgAll,
        ),
        alignment: Alignment.center,
        child: isActing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: Colors.white)),
      ),
    );
  }
}

// ── Manage section (auto-renew + cancel) ──────────────────────────────────────

class _ManageSection extends StatelessWidget {
  final MySubscriptionEntity sub;
  final bool isActing;
  final ValueChanged<bool> onToggleAutoRenew;
  final VoidCallback onCancel;

  const _ManageSection({
    required this.sub,
    required this.isActing,
    required this.onToggleAutoRenew,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'MANAGE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 0.8),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AppContainer.tinted(
                      color: AppColors.teal,
                      borderRadius: AppBorderRadius.smAll,
                      padding: const EdgeInsets.all(7),
                      child: const Icon(Icons.autorenew_rounded, size: 16, color: AppColors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyMd('Auto-renew'),
                          AppText.bodyXs('Automatically renew when your plan expires', color: AppColors.textHint),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: sub.autoRenew,
                      onChanged: isActing ? null : onToggleAutoRenew,
                      activeTrackColor: AppColors.teal,
                      activeThumbColor: Colors.white,
                      inactiveThumbColor: AppColors.textHint,
                      inactiveTrackColor: context.borderCol,
                    ),
                  ],
                ),
              ),
              Container(height: 1, margin: const EdgeInsets.only(left: 58), color: context.borderCol),
              if (!sub.isCancelled)
                GestureDetector(
                  onTap: isActing ? null : onCancel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        AppContainer.tinted(
                          color: AppColors.red,
                          borderRadius: AppBorderRadius.smAll,
                          padding: const EdgeInsets.all(7),
                          child: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.red),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: AppText.bodyMd('Cancel Subscription', color: AppColors.red)),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(child: AppText.bodyXs(message, color: AppColors.red)),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.red),
            ),
          ],
        ),
      );
}
