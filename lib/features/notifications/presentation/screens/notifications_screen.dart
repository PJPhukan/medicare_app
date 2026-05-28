import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';

// ─── Type helpers ─────────────────────────────────────────────────────────────

enum _NotifType { medicine, vitals, connection, system }

_NotifType _parseType(String type) => switch (type.toLowerCase()) {
      'medicine' || 'medication' || 'dose' || 'reminder' => _NotifType.medicine,
      'vitals' || 'vital' || 'health' || 'alert' => _NotifType.vitals,
      'connection' || 'social' || 'request' => _NotifType.connection,
      _ => _NotifType.system,
    };

({Color color, IconData icon}) _typeMeta(_NotifType t) => switch (t) {
      _NotifType.medicine => (color: AppColors.teal, icon: Icons.medication_rounded),
      _NotifType.vitals => (color: AppColors.red, icon: Icons.favorite_rounded),
      _NotifType.connection => (color: AppColors.blue, icon: Icons.people_rounded),
      _NotifType.system => (color: AppColors.purple, icon: Icons.info_rounded),
    };

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _markRead(String id) =>
      ref.read(notificationsProvider.notifier).markRead(id);

  Future<void> _markAllRead() =>
      ref.read(notificationsProvider.notifier).markAllRead();

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Notifications', showAppBar: false);
    }
    final state = ref.watch(notificationsProvider);
    final notifications = state.notifications;
    final unreadCount = state.unreadCount;

    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () => ref.read(notificationsProvider.notifier).load(),
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
                      AppText.h3(AppStrings.notifications),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: AppBorderRadius.pill,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: context.bg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.done_all_rounded,
                                size: 14, color: AppColors.teal),
                            const SizedBox(width: 5),
                            AppText.labelSm(AppStrings.markAllRead, color: AppColors.teal),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              if (state.isLoading && notifications.isEmpty)
                const SliverFillRemaining(child: _LoadingSkeleton())
              else if (notifications.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (unread.isNotEmpty) ...[
                        _SectionLabel(AppStrings.notifNew),
                        const SizedBox(height: 8),
                        ...unread.map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _NotifTile(
                                  notif: n, onTap: () => _markRead(n.id)),
                            )),
                        const SizedBox(height: 8),
                      ],
                      if (read.isNotEmpty) ...[
                        _SectionLabel(AppStrings.notifEarlier),
                        const SizedBox(height: 8),
                        ...read.map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _NotifTile(notif: n, onTap: null),
                            )),
                      ],
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback? onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = _typeMeta(_parseType(notif.type));
    final isUnread = !notif.isRead;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? meta.color.withValues(alpha: 0.05)
              : context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: isUnread
                ? meta.color.withValues(alpha: 0.2)
                : context.borderCol,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: meta.color.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Icon(meta.icon, size: 16, color: meta.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText.labelMd(
                          notif.title,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: isUnread ? context.primaryText : AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnread ? AppColors.textSecondary : AppColors.textHint,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      AppText.bodyXs(_timeAgo(notif.createdAtDate), color: AppColors.textHint),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => SkeletonBox(
              height: 80,
              borderRadius: BorderRadius.circular(12),
            ),
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: AppStrings.allCaughtUp,
        subtitle: AppStrings.noNotifications,
      );
}
