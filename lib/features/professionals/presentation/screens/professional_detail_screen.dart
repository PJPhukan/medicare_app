import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import 'professionals_screen.dart'
    show ProData, ProConnState, ProPlanType, ProConnectSheet;
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_args.dart';

// ─── Mock review model ────────────────────────────────────────────────────────

class _Review {
  final String reviewer;
  final double overall;
  final double communication;
  final double expertise;
  final double availability;
  final String comment;
  final DateTime date;

  const _Review({
    required this.reviewer,
    required this.overall,
    required this.communication,
    required this.expertise,
    required this.availability,
    required this.comment,
    required this.date,
  });
}

List<_Review> _generateReviews(String proId) {
  final rng = math.Random(proId.hashCode);
  final names = [
    'Anjali S.',
    'Rajesh K.',
    'Priya M.',
    'Suresh P.',
    'Nita R.',
    'Vikas T.'
  ];
  final comments = [
    'Extremely professional and caring. Made me feel comfortable throughout the process.',
    'Very knowledgeable and takes time to explain everything clearly. Highly recommend.',
    'Punctual, reliable, and genuinely invested in patient wellbeing. Great experience.',
    'Outstanding care quality. The guidance provided was practical and easy to follow.',
    'Friendly, experienced, and responsive. Would definitely connect again.',
  ];
  return List.generate(5, (i) {
    final o = 3.5 + rng.nextDouble() * 1.5;
    return _Review(
      reviewer: names[i % names.length],
      overall: double.parse(o.toStringAsFixed(1)),
      communication:
          double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      expertise:
          double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      availability:
          double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      comment: comments[i % comments.length],
      date: DateTime.now().subtract(Duration(days: 10 + rng.nextInt(120))),
    );
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfessionalDetailScreen extends ConsumerStatefulWidget {
  final ProData pro;
  const ProfessionalDetailScreen({super.key, required this.pro});

  @override
  ConsumerState<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState
    extends ConsumerState<ProfessionalDetailScreen> {
  late final List<_Review> _reviews;
  late final double _overallAvg;
  late final double _communicationAvg;
  late final double _expertiseAvg;
  late final double _availabilityAvg;

  @override
  void initState() {
    super.initState();
    _reviews = _generateReviews(widget.pro.id);
    _overallAvg = _reviews.map((r) => r.overall).reduce((a, b) => a + b) /
        _reviews.length;
    _communicationAvg =
        _reviews.map((r) => r.communication).reduce((a, b) => a + b) /
            _reviews.length;
    _expertiseAvg = _reviews.map((r) => r.expertise).reduce((a, b) => a + b) /
        _reviews.length;
    _availabilityAvg =
        _reviews.map((r) => r.availability).reduce((a, b) => a + b) /
            _reviews.length;
  }

  void _showConnect([ProPlanType? initial]) {
    if (widget.pro.connectionState == ProConnState.connected) {
      context.push(
        AppRoutes.chat,
        extra: ChatArgs(
          connectionId: 'conn_${widget.pro.id}',
          professionalName: widget.pro.name,
          professionalSpecialty: widget.pro.categoryName,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProConnectSheet(pro: widget.pro, initialPlan: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Professionals');
    }
    final pro = widget.pro;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            // ── Hero app bar ────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4D9EFF),
                        Color(0xFF00E5C3),
                        Color(0xFFA855F7)
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.07,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 20,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (_, __) => const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 1,
                          ),
                          itemCount: 200,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IdentitySection(pro: pro),
                    const SizedBox(height: 20),
                    if (pro.bio.isNotEmpty) ...[
                      _SectionLabel(AppStrings.bio),
                      const SizedBox(height: 8),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: AppText.bodyMd(pro.bio,
                            color: context.secondaryText),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (pro.certifications.isNotEmpty) ...[
                      _SectionLabel(AppStrings.certifications),
                      const SizedBox(height: 8),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pro.certifications
                              .map((c) => _CertBadge(label: c))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionLabel(AppStrings.selectPlanTitle),
                    const SizedBox(height: 8),
                    _PlanCards(pro: pro, onSelect: _showConnect),
                    const SizedBox(height: 16),
                    _SectionLabel('${AppStrings.reviews} (${_reviews.length})'),
                    const SizedBox(height: 8),
                    _ReviewsCard(
                      reviews: _reviews,
                      overall: _overallAvg,
                      communication: _communicationAvg,
                      expertise: _expertiseAvg,
                      availability: _availabilityAvg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            _BottomConnectBar(pro: pro, onConnect: _showConnect),
      ),
    );
  }
}

// ─── Identity section ─────────────────────────────────────────────────────────

class _IdentitySection extends StatelessWidget {
  final ProData pro;
  const _IdentitySection({required this.pro});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -36),
          child: Column(
            children: [
              // Avatar with bg-border to separate from hero
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.bg, width: 4),
                  shape: BoxShape.circle,
                ),
                child: AppAvatar(name: pro.name, size: AppAvatarSize.xl),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.h2(pro.name, textAlign: TextAlign.center),
                  if (pro.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        size: 20, color: AppColors.teal),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Badge(label: pro.categoryName, color: pro.categoryColor),
                  _Badge(
                    icon: Icons.star_rounded,
                    label:
                        '${pro.averageRating.toStringAsFixed(1)} (${pro.ratingCount})',
                    color: AppColors.amber,
                  ),
                  _Badge(
                    icon: Icons.work_outline_rounded,
                    label: '${pro.experienceYrs} yrs ${AppStrings.experience}',
                    color: AppColors.blue,
                  ),
                  _Badge(
                    icon: Icons.location_on_outlined,
                    label: pro.address,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return AppContainer.tinted(
      color: color,
      borderRadius: AppBorderRadius.pill,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          AppText.labelXs(label, color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

// ─── Pricing plan cards ───────────────────────────────────────────────────────

class _PlanCards extends StatelessWidget {
  final ProData pro;
  final void Function(ProPlanType) onSelect;
  const _PlanCards({required this.pro, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final plans = [
      (
        type: ProPlanType.hourly,
        label: AppStrings.hourlyPlan,
        desc: AppStrings.perHour,
        rate: pro.hourlyRate,
        color: AppColors.teal,
        icon: Icons.schedule_rounded
      ),
      (
        type: ProPlanType.daily,
        label: AppStrings.dailyPlan,
        desc: AppStrings.perDay,
        rate: pro.dailyRate,
        color: AppColors.blue,
        icon: Icons.calendar_today_rounded
      ),
      (
        type: ProPlanType.monthly,
        label: AppStrings.monthlyPlan,
        desc: AppStrings.perMonth,
        rate: pro.monthlyRate,
        color: AppColors.purple,
        icon: Icons.date_range_rounded
      ),
    ];

    return Row(
      children: plans.map((p) {
        final available = p.rate != null;
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: p.type == ProPlanType.monthly ? 0 : 8),
            child: GestureDetector(
              onTap: available ? () => onSelect(p.type) : null,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: available
                      ? p.color.withValues(alpha: 0.08)
                      : context.cardBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: available
                        ? p.color.withValues(alpha: 0.3)
                        : context.borderCol,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(p.icon,
                        size: 18,
                        color: available ? p.color : AppColors.textHint),
                    const SizedBox(height: 8),
                    AppText.labelSm(
                      p.label,
                      color:
                          available ? context.primaryText : AppColors.textHint,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      available ? '₹${p.rate}' : '—',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: available ? p.color : AppColors.textHint,
                      ),
                    ),
                    AppText.bodyXs(p.desc, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Reviews card ─────────────────────────────────────────────────────────────

class _ReviewsCard extends StatelessWidget {
  final List<_Review> reviews;
  final double overall;
  final double communication;
  final double expertise;
  final double availability;
  const _ReviewsCard({
    required this.reviews,
    required this.overall,
    required this.communication,
    required this.expertise,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                overall.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < overall.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  AppText.bodyXs('${reviews.length} ${AppStrings.reviews}',
                      color: AppColors.textHint),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StarBar(label: AppStrings.overallRatingLabel, value: overall),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.communicationRating, value: communication),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.expertiseRating, value: expertise),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.availabilityRating, value: availability),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: context.borderCol, height: 1),
          ),
          ...reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ReviewItem(review: r),
              )),
        ],
      ),
    );
  }
}

class _StarBar extends StatelessWidget {
  final String label;
  final double value;
  const _StarBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: AppText.labelXs(label, color: context.secondaryText),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppBorderRadius.pill,
            child: LinearProgressIndicator(
              value: value / 5.0,
              backgroundColor: context.inputBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.amber),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AppText.labelXs(value.toStringAsFixed(1), color: context.secondaryText),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final _Review review;
  const _ReviewItem({required this.review});

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(name: review.reviewer, size: AppAvatarSize.xs),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelSm(review.reviewer),
                  AppText.bodyXs(_fmtDate(review.date),
                      color: AppColors.textHint),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 13, color: AppColors.amber),
                const SizedBox(width: 3),
                AppText.labelXs(review.overall.toStringAsFixed(1),
                    color: AppColors.amber),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText.bodySm(review.comment, color: context.secondaryText),
      ],
    );
  }
}

// ─── Bottom connect bar ───────────────────────────────────────────────────────

class _BottomConnectBar extends StatelessWidget {
  final ProData pro;
  final VoidCallback onConnect;
  const _BottomConnectBar({required this.pro, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: switch (pro.connectionState) {
        ProConnState.connected => Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              AppText.labelMd(AppStrings.connected, color: AppColors.teal),
              const Spacer(),
              AppButton(
                variant: AppButtonVariant.primary,
                label: AppStrings.openChat,
                leading:
                    const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                onPressed: onConnect,
              ),
            ],
          ),
        ProConnState.pending => Row(
            children: [
              const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.amber, size: 18),
              const SizedBox(width: 8),
              AppText.labelMd(AppStrings.pending, color: AppColors.amber),
              const Spacer(),
              AppContainer.tinted(
                color: AppColors.amber,
                borderRadius: AppBorderRadius.lgAll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: AppText.labelSm(AppStrings.cancelRequest,
                    color: AppColors.amber, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ProConnState.none => SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onConnect,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: pro.categoryColor,
                  borderRadius: AppBorderRadius.lgAll,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    AppText.labelMd(AppStrings.connect,
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ],
                ),
              ),
            ),
          ),
      },
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      );
}

class _CertBadge extends StatelessWidget {
  final String label;
  const _CertBadge({required this.label});

  @override
  Widget build(BuildContext context) => AppContainer.tinted(
        color: AppColors.blue,
        borderRadius: AppBorderRadius.pill,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: AppText.labelXs(label, color: AppColors.blue),
      );
}
