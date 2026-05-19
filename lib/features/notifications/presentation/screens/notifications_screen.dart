import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _NotifType { medicine, vitals, connection, system }

class _Notif {
  final String id;
  final _NotifType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kNotifications = [
  _Notif(
    id: 'n1',
    type: _NotifType.medicine,
    title: 'Medicine Reminder',
    body: 'Time to take Metformin 500mg — 1 tablet after food.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  _Notif(
    id: 'n2',
    type: _NotifType.vitals,
    title: 'Blood Pressure Alert',
    body: 'Your systolic reading of 148 mmHg is above the normal range. Consider resting and rechecking.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
  ),
  _Notif(
    id: 'n3',
    type: _NotifType.connection,
    title: 'Connection Accepted',
    body: 'Dr. Arjun Sharma accepted your connection request. You can now message them directly.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
  ),
  _Notif(
    id: 'n4',
    type: _NotifType.medicine,
    title: 'Low Stock Warning',
    body: 'Amlodipine 5mg is running low — only 3 tablets remaining. Time to restock.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: true,
  ),
  _Notif(
    id: 'n5',
    type: _NotifType.system,
    title: 'Welcome to MediForze',
    body: 'Your account is fully set up. Start by adding your medicines and tracking your vitals.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    isRead: true,
  ),
  _Notif(
    id: 'n6',
    type: _NotifType.connection,
    title: 'New Connection Request',
    body: 'Meena Patel (Nurse) sent you a connection request. View their profile to accept or decline.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
  _Notif(
    id: 'n7',
    type: _NotifType.vitals,
    title: 'Weekly Vitals Summary',
    body: 'You logged 5 vitals this week. Your average blood sugar was 108 mg/dL — within normal range.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _items = List.from(_kNotifications);

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  void _markRead(String id) {
    setState(() {
      final i = _items.indexWhere((n) => n.id == id);
      if (i != -1) _items[i].isRead = true;
    });
  }

  void _markAllRead() => setState(() {
        for (final n in _items) {
          n.isRead = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.isRead).toList();
    final read = _items.where((n) => n.isRead).toList();

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
                    Text(AppStrings.notifications, style: AppTypography.h3),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: AppBorderRadius.pill,
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: AppTypography.labelXs.copyWith(
                              color: context.bg,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.done_all_rounded, size: 14, color: AppColors.teal),
                          const SizedBox(width: 5),
                          Text(
                            AppStrings.markAllRead,
                            style: AppTypography.labelSm.copyWith(color: AppColors.teal),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            if (_items.isEmpty)
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
                            child: _NotifTile(notif: n, onTap: () => _markRead(n.id)),
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
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback? onTap;
  const _NotifTile({required this.notif, required this.onTap});

  ({Color color, IconData icon}) get _meta => switch (notif.type) {
        _NotifType.medicine => (color: AppColors.teal, icon: Icons.medication_rounded),
        _NotifType.vitals => (color: AppColors.red, icon: Icons.favorite_rounded),
        _NotifType.connection => (color: AppColors.blue, icon: Icons.people_rounded),
        _NotifType.system => (color: AppColors.purple, icon: Icons.info_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    final isUnread = !notif.isRead;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? meta.color.withValues(alpha: 0.05) : context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: isUnread ? meta.color.withValues(alpha: 0.2) : context.borderCol,
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
                        child: Text(
                          notif.title,
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: isUnread ? context.primaryText : AppColors.textSecondary,
                          ),
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
                    style: AppTypography.bodySm.copyWith(
                      color: isUnread ? AppColors.textSecondary : AppColors.textHint,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(notif.createdAt),
                        style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                      ),
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTypography.overline.copyWith(color: AppColors.textHint, letterSpacing: 1.2),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 52, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              AppStrings.allCaughtUp,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.noNotifications,
              style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
}
