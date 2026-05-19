import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'professionals_screen.dart' show ProData, ProConnState, ProPlanType, ProConnectSheet;
import '../../../connections/presentation/screens/chat_screen.dart';

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
  final names = ['Anjali S.', 'Rajesh K.', 'Priya M.', 'Suresh P.', 'Nita R.', 'Vikas T.'];
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
      communication: double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      expertise: double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      availability: double.parse((3.5 + rng.nextDouble() * 1.5).toStringAsFixed(1)),
      comment: comments[i % comments.length],
      date: DateTime.now().subtract(Duration(days: 10 + rng.nextInt(120))),
    );
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfessionalDetailScreen extends StatefulWidget {
  final ProData pro;
  const ProfessionalDetailScreen({super.key, required this.pro});

  @override
  State<ProfessionalDetailScreen> createState() => _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  late final List<_Review> _reviews;
  late final double _overallAvg;
  late final double _communicationAvg;
  late final double _expertiseAvg;
  late final double _availabilityAvg;

  @override
  void initState() {
    super.initState();
    _reviews = _generateReviews(widget.pro.id);
    _overallAvg = _reviews.map((r) => r.overall).reduce((a, b) => a + b) / _reviews.length;
    _communicationAvg = _reviews.map((r) => r.communication).reduce((a, b) => a + b) / _reviews.length;
    _expertiseAvg = _reviews.map((r) => r.expertise).reduce((a, b) => a + b) / _reviews.length;
    _availabilityAvg = _reviews.map((r) => r.availability).reduce((a, b) => a + b) / _reviews.length;
  }

  void _showConnect([ProPlanType? initial]) {
    if (widget.pro.connectionState == ProConnState.connected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            connectionId: 'conn_${widget.pro.id}',
            professionalName: widget.pro.name,
            professionalSpecialty: widget.pro.categoryName,
            avatarColor: widget.pro.categoryColor,
          ),
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

  String get _initials {
    final parts = widget.pro.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final pro = widget.pro;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            // ── Hero app bar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4D9EFF), Color(0xFF00E5C3), Color(0xFFA855F7)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle dot pattern overlay
                      Opacity(
                        opacity: 0.07,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

            // ── Content ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + identity
                    _IdentitySection(pro: pro, initials: _initials),

                    const SizedBox(height: 20),

                    // Bio
                    if (pro.bio.isNotEmpty) ...[
                      _SectionLabel(AppStrings.bio),
                      const SizedBox(height: 8),
                      _Card(
                        child: Text(
                          pro.bio,
                          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Certifications
                    if (pro.certifications.isNotEmpty) ...[
                      _SectionLabel(AppStrings.certifications),
                      const SizedBox(height: 8),
                      _Card(
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

                    // Pricing plans
                    _SectionLabel(AppStrings.selectPlanTitle),
                    const SizedBox(height: 8),
                    _PlanCards(pro: pro, onSelect: _showConnect),
                    const SizedBox(height: 16),

                    // Ratings & reviews
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

        // ── Bottom connect button ─────────────────────────────────────────────
        bottomNavigationBar: _BottomConnectBar(pro: pro, onConnect: _showConnect),
      ),
    );
  }
}

// ─── Identity section (avatar + name + badges) ────────────────────────────────

class _IdentitySection extends StatelessWidget {
  final ProData pro;
  final String initials;
  const _IdentitySection({required this.pro, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar positioned to overlap with hero
        Transform.translate(
          offset: Offset(0, -36),
          child: Column(
            children: [
              // Avatar circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: pro.categoryColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.bg, width: 4),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: pro.categoryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pro.name, style: AppTypography.h2),
                  if (pro.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified_rounded, size: 20, color: AppColors.teal),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Badges row
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Category
                  _Badge(
                    label: pro.categoryName,
                    color: pro.categoryColor,
                  ),
                  // Rating
                  _Badge(
                    icon: Icons.star_rounded,
                    label: '${pro.averageRating.toStringAsFixed(1)} (${pro.ratingCount})',
                    color: AppColors.amber,
                  ),
                  // Experience
                  _Badge(
                    icon: Icons.work_outline_rounded,
                    label: '${pro.experienceYrs} yrs ${AppStrings.experience}',
                    color: AppColors.blue,
                  ),
                  // Location
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelXs.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
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
        icon: Icons.schedule_rounded,
      ),
      (
        type: ProPlanType.daily,
        label: AppStrings.dailyPlan,
        desc: AppStrings.perDay,
        rate: pro.dailyRate,
        color: AppColors.blue,
        icon: Icons.calendar_today_rounded,
      ),
      (
        type: ProPlanType.monthly,
        label: AppStrings.monthlyPlan,
        desc: AppStrings.perMonth,
        rate: pro.monthlyRate,
        color: AppColors.purple,
        icon: Icons.date_range_rounded,
      ),
    ];

    return Row(
      children: plans.map((p) {
        final available = p.rate != null;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p.type == ProPlanType.monthly ? 0 : 8),
            child: GestureDetector(
              onTap: available ? () => onSelect(p.type) : null,
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: available ? p.color.withValues(alpha: 0.08) : context.cardBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: available ? p.color.withValues(alpha: 0.3) : context.borderCol,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(p.icon, size: 18, color: available ? p.color : AppColors.textHint),
                    SizedBox(height: 8),
                    Text(
                      p.label,
                      style: AppTypography.labelSm.copyWith(
                        color: available ? context.primaryText : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      available ? '₹${p.rate}' : '—',
                      style: AppTypography.statMd.copyWith(
                        color: available ? p.color : AppColors.textHint,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      p.desc,
                      style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                    ),
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
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall score
          Row(
            children: [
              Text(
                overall.toStringAsFixed(1),
                style: AppTypography.statXl.copyWith(color: AppColors.amber),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < overall.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 16,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  Text(
                    '${reviews.length} ${AppStrings.reviews}',
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Star bars
          _StarBar(label: AppStrings.overallRatingLabel, value: overall),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.communicationRating, value: communication),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.expertiseRating, value: expertise),
          const SizedBox(height: 8),
          _StarBar(label: AppStrings.availabilityRating, value: availability),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: context.borderCol, height: 1),
          ),

          // Review list
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
  _StarBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary)),
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
        Text(
          value.toStringAsFixed(1),
          style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final _Review review;
  _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.inputBg,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderCol),
              ),
              alignment: Alignment.center,
              child: Text(
                review.reviewer[0],
                style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewer, style: AppTypography.labelSm),
                  Text(
                    _fmtDate(review.date),
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 13, color: AppColors.amber),
                const SizedBox(width: 3),
                Text(
                  review.overall.toStringAsFixed(1),
                  style: AppTypography.labelXs.copyWith(color: AppColors.amber),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.comment,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ─── Bottom connect bar ───────────────────────────────────────────────────────

class _BottomConnectBar extends StatelessWidget {
  final ProData pro;
  final VoidCallback onConnect;
  _BottomConnectBar({required this.pro, required this.onConnect});

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
              const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.connected, style: AppTypography.labelMd.copyWith(color: AppColors.teal)),
              const Spacer(),
              _FilledBtn(
                label: AppStrings.openChat,
                color: AppColors.teal,
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onConnect,
              ),
            ],
          ),
        ProConnState.pending => Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: AppColors.amber, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.pending, style: AppTypography.labelMd.copyWith(color: AppColors.amber)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  AppStrings.cancelRequest,
                  style: AppTypography.buttonSm.copyWith(color: AppColors.amber),
                ),
              ),
            ],
          ),
        ProConnState.none => SizedBox(
            width: double.infinity,
            child: _FilledBtn(
              label: AppStrings.connect,
              color: pro.categoryColor,
              icon: Icons.add_rounded,
              onTap: onConnect,
            ),
          ),
      },
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  _FilledBtn({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: AppBorderRadius.lgAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: context.bg),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.buttonMd.copyWith(color: context.bg)),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.overline.copyWith(color: AppColors.textHint, letterSpacing: 1.2),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: child,
    );
  }
}

class _CertBadge extends StatelessWidget {
  final String label;
  const _CertBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
      ),
      child: Text(label, style: AppTypography.labelXs.copyWith(color: AppColors.blue)),
    );
  }
}
