import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../premium/domain/entities/plan_entity.dart';
import '../../../premium/presentation/providers/subscription_provider.dart';
import '../widgets/auth_shell.dart';

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
  bool _acting = false;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(subscriptionProvider);

    final plans = st.plans;
    final freePlan = plans.isEmpty ? null : plans.firstWhere(
      (p) => p.isFree,
      orElse: () => plans.first,
    );
    final selectedIsFree = plans.isEmpty ||
        (_selectedIndex < plans.length && plans[_selectedIndex].isFree);

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 16),

          AuthStepper(
              steps: const ['Account', 'Health', 'Emergency', 'Plan'],
              current: 3),

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
          const SizedBox(height: 24),

          if (st.isLoadingPlans && plans.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                    color: AppColors.teal, strokeWidth: 2),
              ),
            )
          else if (plans.isNotEmpty)
            ...plans.asMap().entries.map((e) => _PlanCard(
                  plan: e.value,
                  selected: _selectedIndex == e.key,
                  onTap: () => setState(() => _selectedIndex = e.key),
                ))
          else
            _StaticPlans(
              selectedIsFree: selectedIsFree,
              onSelectFree: () => setState(() => _selectedIndex = 0),
              onSelectPremium: () => setState(() => _selectedIndex = 1),
            ),

          const SizedBox(height: 28),

          AuthButton(
            label: selectedIsFree
                ? AppStrings.startForFree
                : AppStrings.getPremium,
            loading: _acting,
            onPressed: _acting ? null : () => _onContinue(plans, freePlan),
          ),
          const SizedBox(height: 12),

          Center(
            child: AppText.caption(AppStrings.noCreditCard),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _onContinue(List<PlanEntity> plans, PlanEntity? freePlan) async {
    if (plans.isEmpty) {
      widget.onDone?.call();
      return;
    }

    final selected = _selectedIndex < plans.length
        ? plans[_selectedIndex]
        : (freePlan ?? plans.first);

    setState(() => _acting = true);
    try {
      await ref.read(subscriptionProvider.notifier).selectPlan(selected.id);
    } catch (_) {}
    if (mounted) {
      setState(() => _acting = false);
      widget.onDone?.call();
    }
  }
}

// ── Real plan card (from API) ─────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlanEntity plan;
  final bool selected;
  final VoidCallback onTap;

  Color get _accent => plan.isFree ? AppColors.teal : AppColors.purple;

  String get _priceLabel {
    if (plan.isFree) return AppStrings.planFreePrice;
    final sym = plan.currency == 'INR' ? '₹' : '\$';
    return '$sym${plan.priceMonthly.toStringAsFixed(0)}${AppStrings.planPeriodMonth}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final borderColor = selected
        ? _accent
        : context.borderCol;
    final bgColor = selected
        ? _accent.withValues(alpha: 0.08)
        : (isDark ? AppColors.dark700 : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          boxShadow: selected && !plan.isFree
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.15),
                    blurRadius: 20,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppText.h3(plan.name, fontWeight: FontWeight.w800),
                      const SizedBox(width: 8),
                      AppContainer.tinted(
                        color: _accent,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: AppText.labelXs(
                          plan.isFree ? AppStrings.planFreeBadge : AppStrings.planPremiumBadge,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                ),
                AppText.h2(_priceLabel, color: _accent, fontWeight: FontWeight.w800),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: _accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.labelMd(f, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Static fallback while plans load ─────────────────────────────────────────

class _StaticPlans extends StatelessWidget {
  const _StaticPlans({
    required this.selectedIsFree,
    required this.onSelectFree,
    required this.onSelectPremium,
  });

  final bool selectedIsFree;
  final VoidCallback onSelectFree;
  final VoidCallback onSelectPremium;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StaticCard(
          name: AppStrings.planBasicName,
          badge: AppStrings.planFreeBadge,
          price: AppStrings.planFreePrice,
          period: '',
          badgeColor: AppColors.teal,
          features: [
            AppStrings.planBasicFeature1,
            AppStrings.planBasicFeature2,
            AppStrings.planBasicFeature3,
          ],
          selected: selectedIsFree,
          onTap: onSelectFree,
        ),
        _StaticCard(
          name: AppStrings.planPremiumName,
          badge: AppStrings.planPremiumBadge,
          price: AppStrings.planPremiumPrice,
          period: AppStrings.planPeriodMonth,
          badgeColor: AppColors.purple,
          features: [
            AppStrings.planPremiumFeature1,
            AppStrings.planPremiumFeature2,
            AppStrings.planPremiumFeature3,
            AppStrings.planPremiumFeature4,
            AppStrings.planPremiumFeature5,
          ],
          selected: !selectedIsFree,
          onTap: onSelectPremium,
        ),
      ],
    );
  }
}

class _StaticCard extends StatelessWidget {
  const _StaticCard({
    required this.name,
    required this.badge,
    required this.price,
    required this.period,
    required this.badgeColor,
    required this.features,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String badge;
  final String price;
  final String period;
  final Color badgeColor;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final borderColor = selected
        ? badgeColor
        : context.borderCol;
    final bgColor = selected
        ? badgeColor.withValues(alpha: 0.08)
        : (isDark ? AppColors.dark700 : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppText.h3(name, fontWeight: FontWeight.w800),
                      const SizedBox(width: 8),
                      AppContainer.tinted(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: AppText.labelXs(badge, color: badgeColor),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: AppText.h2(price, color: badgeColor, fontWeight: FontWeight.w800),
                      ),
                      if (period.isNotEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: AppText.labelSm(period, color: AppColors.textHint),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: badgeColor),
                      const SizedBox(width: 8),
                      AppText.labelMd(f, color: AppColors.textSecondary),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
