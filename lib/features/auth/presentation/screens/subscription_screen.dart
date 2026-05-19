import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_shell.dart';

class _Plan {
  const _Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.badge,
    required this.badgeColor,
    required this.features,
    this.isFeatured = false,
  });
  final String id;
  final String name;
  final String price;
  final String period;
  final String badge;
  final Color badgeColor;
  final List<String> features;
  final bool isFeatured;
}

final _plans = [
  _Plan(
    id: 'free',
    name: AppStrings.planBasicName,
    price: AppStrings.planFreePrice,
    period: '',
    badge: AppStrings.planFreeBadge,
    badgeColor: AppColors.teal,
    features: [
      AppStrings.planBasicFeature1,
      AppStrings.planBasicFeature2,
      AppStrings.planBasicFeature3,
    ],
  ),
  _Plan(
    id: 'premium',
    name: AppStrings.planPremiumName,
    price: AppStrings.planPremiumPrice,
    period: AppStrings.planPeriodMonth,
    badge: AppStrings.planPremiumBadge,
    badgeColor: AppColors.purple,
    features: [
      AppStrings.planPremiumFeature1,
      AppStrings.planPremiumFeature2,
      AppStrings.planPremiumFeature3,
      AppStrings.planPremiumFeature4,
      AppStrings.planPremiumFeature5,
    ],
    isFeatured: true,
  ),
];

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
    this.onDone,
    required this.onBack,
  });

  final VoidCallback? onDone;
  final VoidCallback onBack;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selected = 'free';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 16),

          AuthStepper(steps: const ['Account', 'Health', 'Emergency', 'Plan'], current: 3),

          Center(
            child: Column(
              children: [
                Text(AppStrings.choosePlan,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 6),
                Text(AppStrings.planSubtitle,
                    style: GoogleFonts.inter(fontSize: 13, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ..._plans.map((plan) => _PlanCard(
            plan: plan,
            selected: _selected == plan.id,
            isDark: isDark,
            onTap: () => setState(() => _selected = plan.id),
          )),
          const SizedBox(height: 28),

          AuthButton(
            label: _selected == 'free' ? AppStrings.startForFree : AppStrings.getPremium,
            onPressed: widget.onDone,
          ),
          const SizedBox(height: 12),

          Center(
            child: Text(AppStrings.noCreditCard,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.dark500 : const Color(0xFFCBD5E1),
                )),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });
  final _Plan plan;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? plan.isFeatured ? AppColors.purple : AppColors.teal
        : isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgColor = selected
        ? (plan.isFeatured
            ? AppColors.purple.withValues(alpha: 0.08)
            : AppColors.teal.withValues(alpha: 0.06))
        : isDark ? AppColors.dark700 : Colors.white;

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
          boxShadow: selected && plan.isFeatured
              ? [BoxShadow(color: AppColors.purple.withValues(alpha: 0.15), blurRadius: 20)]
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
                      Text(plan.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A202C),
                          )),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: plan.badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(plan.badge,
                            style: GoogleFonts.inter(
                              fontSize: 9, fontWeight: FontWeight.w800,
                              color: plan.badgeColor, letterSpacing: 0.8,
                            )),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: plan.price,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: plan.isFeatured ? AppColors.purple : AppColors.teal,
                        ),
                      ),
                      if (plan.period.isNotEmpty)
                        TextSpan(
                          text: plan.period,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 14,
                      color: plan.isFeatured ? AppColors.purple : AppColors.teal),
                  const SizedBox(width: 8),
                  Text(f,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                      )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
