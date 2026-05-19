import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _Severity { critical, warning, info }

class _Alert {
  final String id;
  final _Severity severity;
  final String title;
  final String body;
  final DateTime createdAt;

  const _Alert({
    required this.id,
    required this.severity,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kAlerts = [
  _Alert(
    id: 'a1',
    severity: _Severity.critical,
    title: 'Blood Pressure Critical',
    body: 'Your systolic reading of 162 mmHg is dangerously high. Rest immediately and contact your doctor or call emergency services.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  _Alert(
    id: 'a2',
    severity: _Severity.warning,
    title: 'Missed Evening Dose',
    body: 'You missed your Amlodipine 5mg dose scheduled for 8:00 PM. Take it now if within 4 hours, otherwise skip and continue tomorrow.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  _Alert(
    id: 'a3',
    severity: _Severity.warning,
    title: 'Low Stock: Metformin',
    body: 'Only 4 tablets of Metformin 500mg remaining. Restock before you run out to avoid missing doses.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  _Alert(
    id: 'a4',
    severity: _Severity.info,
    title: 'Upcoming Appointment',
    body: 'You have an appointment with Dr. Arjun Sharma tomorrow at 10:30 AM. Bring your recent BP log and medicine list.',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  _Alert(
    id: 'a5',
    severity: _Severity.info,
    title: 'Weekly Adherence Summary',
    body: 'You took 87% of your scheduled doses this week. Your average was good — keep it up! Afternoon doses had the highest miss rate.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<_Alert> _alerts = List.from(_kAlerts);

  void _dismiss(String id) => setState(() => _alerts.removeWhere((a) => a.id == id));

  @override
  Widget build(BuildContext context) {
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
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppStrings.alerts, style: AppTypography.h3),
                    if (_alerts.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: AppBorderRadius.pill,
                          ),
                          child: Text(
                            '${_alerts.length}',
                            style: AppTypography.labelXs.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            _alerts.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 52, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noActiveAlerts,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AlertCard(
                            alert: _alerts[i],
                            onDismiss: () => _dismiss(_alerts[i].id),
                          ),
                        ),
                        childCount: _alerts.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Alert card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final _Alert alert;
  final VoidCallback onDismiss;

  const _AlertCard({required this.alert, required this.onDismiss});

  ({Color color, IconData icon, String label}) get _meta => switch (alert.severity) {
    _Severity.critical => (
        color: AppColors.red,
        icon: Icons.warning_amber_rounded,
        label: AppStrings.criticalSeverity,
      ),
    _Severity.warning => (
        color: AppColors.amber,
        icon: Icons.info_outline_rounded,
        label: AppStrings.warningSeverity,
      ),
    _Severity.info => (
        color: AppColors.blue,
        icon: Icons.notifications_outlined,
        label: AppStrings.infoSeverity,
      ),
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: meta.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity accent stripe
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: meta.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.lg),
                topRight: Radius.circular(AppBorderRadius.lg),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.mdAll,
                      ),
                      alignment: Alignment.center,
                      child: Icon(meta.icon, size: 16, color: meta.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: meta.color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        meta.label,
                        style: AppTypography.labelXs.copyWith(color: meta.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Body
                Text(
                  alert.body,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Time row
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      _timeAgo(alert.createdAt),
                      style: AppTypography.bodyXs,
                    ),
                    const Spacer(),

                    // View Details button
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.comingSoon,
                              style: AppTypography.bodySm),
                          backgroundColor: context.inputBg,
                          duration: const Duration(seconds: 1),
                        ),
                      ),
                      child: Text(
                        AppStrings.viewDetails,
                        style: AppTypography.labelSm.copyWith(
                          color: meta.color,
                          decoration: TextDecoration.underline,
                          decorationColor: meta.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Dismiss button
                    GestureDetector(
                      onTap: onDismiss,
                      child: Text(
                        AppStrings.dismiss,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
