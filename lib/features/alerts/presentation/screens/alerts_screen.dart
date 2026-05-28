import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../../core/network/connectivity_monitor.dart';

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

// ─── Adapter: AppNotification → _Alert ───────────────────────────────────────

_Alert _notifToAlert(AppNotification n) {
  final type = n.type.toUpperCase();
  final severity = type.contains('CRITICAL') ||
          type.contains('BLOOD_PRESSURE') ||
          type.contains('SOS')
      ? _Severity.critical
      : type.contains('MISSED') ||
              type.contains('LOW_STOCK') ||
              type.contains('EXPIRY')
          ? _Severity.warning
          : _Severity.info;
  return _Alert(
    id: n.id,
    severity: severity,
    title: n.title,
    body: n.body,
    createdAt: n.createdAtDate,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final Set<String> _dismissed = {};

  void _dismiss(String id) {
    setState(() => _dismissed.add(id));
    ref.read(notificationsProvider.notifier).markRead(id);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Alerts', showAppBar: false);
    }
    final notifState = ref.watch(notificationsProvider);
    final alerts = notifState.notifications
        .where((n) => !_dismissed.contains(n.id))
        .map(_notifToAlert)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).load(),
          color: AppColors.teal,
          child: CustomScrollView(
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
                      AppText.h3(AppStrings.alerts),
                      if (notifState.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: AppBadge(
                            label: '${notifState.unreadCount}',
                            variant: AppBadgeVariant.red,
                            filled: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (notifState.isLoading)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverToBoxAdapter(
                    child: AppSkeletonList(count: 4, itemHeight: 120),
                  ),
                )
              else if (alerts.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.shield_outlined,
                    title: AppStrings.noActiveAlerts,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AlertCard(
                          alert: alerts[i],
                          onDismiss: () => _dismiss(alerts[i].id),
                        ),
                      ),
                      childCount: alerts.length,
                    ),
                  ),
                ),
            ],
          ),
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

  ({Color color, IconData icon, String label, AppBadgeVariant badgeVariant})
      get _meta => switch (alert.severity) {
        _Severity.critical => (
          color: AppColors.red,
          icon: Icons.warning_amber_rounded,
          label: AppStrings.criticalSeverity,
          badgeVariant: AppBadgeVariant.red,
        ),
        _Severity.warning => (
          color: AppColors.amber,
          icon: Icons.info_outline_rounded,
          label: AppStrings.warningSeverity,
          badgeVariant: AppBadgeVariant.amber,
        ),
        _Severity.info => (
          color: AppColors.blue,
          icon: Icons.notifications_outlined,
          label: AppStrings.infoSeverity,
          badgeVariant: AppBadgeVariant.blue,
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
    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: meta.color.withValues(alpha: 0.25),
      borderRadius: AppBorderRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity accent stripe
          AppContainer.flat(
            height: 4,
            color: meta.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.lg),
              topRight: Radius.circular(AppBorderRadius.lg),
            ),
            child: const SizedBox.shrink(),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    AppContainer.flat(
                      width: 32,
                      height: 32,
                      color: meta.color.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                      alignment: Alignment.center,
                      child: Icon(meta.icon, size: 16, color: meta.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText.labelMd(
                        alert.title,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(
                      label: meta.label,
                      variant: meta.badgeVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Body
                AppText.bodySm(alert.body),
                const SizedBox(height: 10),

                // Time + actions row
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    AppText.bodyXs(_timeAgo(alert.createdAt)),
                    const Spacer(),

                    AppButton.ghost(
                      label: AppStrings.viewDetails,
                      size: AppButtonSize.sm,
                      color: meta.color,
                      onPressed: () =>
                          AppSnackbar.info(context, AppStrings.comingSoon),
                    ),
                    const SizedBox(width: 4),

                    AppButton.ghost(
                      label: AppStrings.dismiss,
                      size: AppButtonSize.sm,
                      color: AppColors.textHint,
                      onPressed: onDismiss,
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
