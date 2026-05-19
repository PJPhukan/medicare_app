import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Enums & models ───────────────────────────────────────────────────────────

enum _PlanType { hourly, daily, monthly }

enum _Status { active, expired, cancelled }

class _Connection {
  final String id;
  final String proName;
  final String categoryName;
  final Color categoryColor;
  final _PlanType planType;
  final _Status status;
  final int amount;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final DateTime? nextBillingAt;
  final double? ratingGiven;

  const _Connection({
    required this.id,
    required this.proName,
    required this.categoryName,
    required this.categoryColor,
    required this.planType,
    required this.status,
    required this.amount,
    required this.startedAt,
    this.expiresAt,
    this.nextBillingAt,
    this.ratingGiven,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kConnections = [
  _Connection(
    id: 'c1',
    proName: 'Sunita Devi',
    categoryName: 'Caregiver',
    categoryColor: AppColors.red,
    planType: _PlanType.monthly,
    status: _Status.active,
    amount: 18000,
    startedAt: DateTime.now().subtract(const Duration(days: 12)),
    nextBillingAt: DateTime.now().add(const Duration(days: 18)),
    ratingGiven: null,
  ),
  _Connection(
    id: 'c2',
    proName: 'Dr. Arjun Sharma',
    categoryName: 'Doctor',
    categoryColor: AppColors.teal,
    planType: _PlanType.hourly,
    status: _Status.expired,
    amount: 500,
    startedAt: DateTime.now().subtract(const Duration(days: 60)),
    expiresAt: DateTime.now().subtract(const Duration(days: 30)),
    ratingGiven: 4.5,
  ),
  _Connection(
    id: 'c3',
    proName: 'Ravi Shankar',
    categoryName: 'Dietitian',
    categoryColor: AppColors.amber,
    planType: _PlanType.daily,
    status: _Status.cancelled,
    amount: 2500,
    startedAt: DateTime.now().subtract(const Duration(days: 45)),
    expiresAt: DateTime.now().subtract(const Duration(days: 40)),
    ratingGiven: null,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  bool _asPatient = true;

  List<_Connection> get _active =>
      _kConnections.where((c) => c.status == _Status.active).toList();

  List<_Connection> get _past =>
      _kConnections.where((c) => c.status != _Status.active).toList();

  void _cancel(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.xlAll),
        title: Text(AppStrings.cancelRequest, style: AppTypography.h3),
        content: Text(
          AppStrings.cancelConnectionConfirm,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel, style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.connectionCancelledMsg),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                ),
              );
            },
            child: Text(AppStrings.cancelRequest, style: AppTypography.buttonMd.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final past = _past;
    final isEmpty = _kConnections.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: Text(AppStrings.myConnections, style: AppTypography.h3),
              ),
            ),

            // Tab selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _TabToggle(
                  asPatient: _asPatient,
                  onToggle: (v) => setState(() => _asPatient = v),
                ),
              ),
            ),

            if (isEmpty)
              SliverFillRemaining(
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (active.isNotEmpty) ...[
                      _SectionHeader(AppStrings.activeConnections),
                      const SizedBox(height: 10),
                      ...active.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ConnectionCard(conn: c, onCancel: _cancel),
                          )),
                      const SizedBox(height: 8),
                    ],
                    if (past.isNotEmpty) ...[
                      _SectionHeader(AppStrings.pastConnections),
                      const SizedBox(height: 10),
                      ...past.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ConnectionCard(conn: c, onCancel: _cancel),
                          )),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab toggle ───────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final bool asPatient;
  final ValueChanged<bool> onToggle;
  const _TabToggle({required this.asPatient, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          _Tab(label: AppStrings.asPatient, isActive: asPatient, onTap: () => onToggle(true)),
          _Tab(label: AppStrings.asProfessionalTab, isActive: !asPatient, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal : Colors.transparent,
            borderRadius: AppBorderRadius.mdAll,
          ),
          child: Text(
            label,
            style: AppTypography.buttonSm.copyWith(
              color: isActive ? context.bg : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Connection card ──────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final _Connection conn;
  final void Function(String id) onCancel;
  const _ConnectionCard({required this.conn, required this.onCancel});

  IconData get _planIcon => switch (conn.planType) {
        _PlanType.hourly => Icons.schedule_rounded,
        _PlanType.daily => Icons.calendar_today_rounded,
        _PlanType.monthly => Icons.date_range_rounded,
      };

  ({Color bg, Color text, String label}) _statusMeta(BuildContext context) => switch (conn.status) {
        _Status.active => (bg: AppColors.teal10, text: AppColors.teal, label: 'ACTIVE'),
        _Status.expired => (bg: context.inputBg, text: AppColors.textSecondary, label: 'EXPIRED'),
        _Status.cancelled => (bg: AppColors.red10, text: AppColors.red, label: 'CANCELLED'),
      };

  String _planLabel() => switch (conn.planType) {
        _PlanType.hourly => AppStrings.hourlyPlan,
        _PlanType.daily => AppStrings.dailyPlan,
        _PlanType.monthly => AppStrings.monthlyPlan,
      };

  String _dateLabel() {
    if (conn.expiresAt != null && conn.expiresAt!.isBefore(DateTime.now())) {
      return '${AppStrings.expiresOn} ${_fmt(conn.expiresAt!)}';
    }
    if (conn.nextBillingAt != null) {
      return '${AppStrings.nextBillingOn} ${_fmt(conn.nextBillingAt!)}';
    }
    return '${AppStrings.connectionStarted} ${_fmt(conn.startedAt)}';
  }

  String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusMeta(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: conn.categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                alignment: Alignment.center,
                child: Icon(_planIcon, size: 18, color: conn.categoryColor),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conn.proName,
                            style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status.bg,
                            borderRadius: AppBorderRadius.pill,
                          ),
                          child: Text(
                            status.label,
                            style: AppTypography.labelXs.copyWith(
                              color: status.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_planLabel()} · ₹${conn.amount} · ${_dateLabel()}',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    if (conn.ratingGiven != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 13, color: AppColors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '${conn.ratingGiven!.toStringAsFixed(1)} ${AppStrings.ratedLabel}',
                            style: AppTypography.labelXs.copyWith(color: AppColors.amber),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Action buttons
          if (conn.status == _Status.active) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: AppStrings.openChat,
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.teal,
                    filled: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: AppStrings.cancelRequest,
                  icon: Icons.cancel_outlined,
                  color: AppColors.textSecondary,
                  filled: false,
                  onTap: () => onCancel(conn.id),
                ),
              ],
            ),
          ],

          // Leave rating button (unrated, any status)
          if (conn.ratingGiven == null) ...[
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_outline_rounded, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.leaveRating,
                      style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: filled ? color : context.borderCol),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? context.bg : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.buttonSm.copyWith(color: filled ? context.bg : color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.overline.copyWith(color: AppColors.textHint, letterSpacing: 1.2),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 52, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            AppStrings.noConnectionsYet,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.browseProfessionals,
            style: AppTypography.bodySm.copyWith(color: AppColors.teal),
          ),
        ],
      ),
    );
  }
}
