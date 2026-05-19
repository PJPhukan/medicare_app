import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'chat_screen.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum _ConnStatus { active, pending, declined }

class _Connection {
  final String id;
  final String name;
  final String specialty;
  final Color avatarColor;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
  final _ConnStatus status;

  const _Connection({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarColor,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
    this.status = _ConnStatus.active,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kActive = [
  _Connection(
    id: 'conn_1',
    name: 'Dr. Arjun Sharma',
    specialty: 'Cardiologist',
    avatarColor: AppColors.teal,
    lastMessage: 'Your blood pressure readings look elevated. Please rest and recheck.',
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 2,
  ),
  _Connection(
    id: 'conn_2',
    name: 'Dr. Priya Nair',
    specialty: 'Nutritionist',
    avatarColor: AppColors.green,
    lastMessage: 'Here is your personalised meal plan for the week.',
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
  ),
  _Connection(
    id: 'conn_3',
    name: 'Dr. Rahul Menon',
    specialty: 'Physiotherapist',
    avatarColor: AppColors.blue,
    lastMessage: 'Great progress! Keep doing the knee exercises twice daily.',
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    unreadCount: 1,
  ),
];

final _kSent = [
  _Connection(
    id: 'req_1',
    name: 'Dr. Kavya Rao',
    specialty: 'Psychologist',
    avatarColor: AppColors.purple,
    lastMessage: '',
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    status: _ConnStatus.pending,
  ),
  _Connection(
    id: 'req_2',
    name: 'Dr. Suresh Iyer',
    specialty: 'Dermatologist',
    avatarColor: AppColors.amber,
    lastMessage: '',
    updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    status: _ConnStatus.declined,
  ),
];

final _kIncoming = [
  _Connection(
    id: 'inc_1',
    name: 'Dr. Deepa Krishnan',
    specialty: 'Endocrinologist',
    avatarColor: AppColors.amber,
    lastMessage: 'Hi! I noticed your recent vitals and would like to help manage your condition.',
    updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Mutable local state for demo accept/decline
  final _incoming = List<_Connection>.from(_kIncoming);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Connection> get _filteredActive => _query.isEmpty
      ? _kActive
      : _kActive.where((c) => c.name.toLowerCase().contains(_query) || c.specialty.toLowerCase().contains(_query)).toList();

  List<_Connection> get _filteredSent => _query.isEmpty
      ? _kSent
      : _kSent.where((c) => c.name.toLowerCase().contains(_query)).toList();

  List<_Connection> get _filteredIncoming => _query.isEmpty
      ? _incoming
      : _incoming.where((c) => c.name.toLowerCase().contains(_query)).toList();

  void _openChat(_Connection conn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          connectionId: conn.id,
          professionalName: conn.name,
          professionalSpecialty: conn.specialty,
          avatarColor: conn.avatarColor,
        ),
      ),
    );
  }

  void _accept(_Connection conn) {
    setState(() => _incoming.remove(conn));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.connectionAccepted, style: AppTypography.bodySm),
        backgroundColor: context.inputBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      ),
    );
  }

  void _decline(_Connection conn) {
    setState(() => _incoming.remove(conn));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.requestDeclined, style: AppTypography.bodySm),
        backgroundColor: context.inputBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: openAppSidebar,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: Text(AppStrings.myConnections, style: AppTypography.h3),
              ),
            ),
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _SearchBar(controller: _searchCtrl),
              ),
            ),
            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppColors.teal,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.teal,
                  unselectedLabelColor: AppColors.textHint,
                  labelStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTypography.labelSm,
                  dividerColor: context.borderCol,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Active'),
                          if (_kActive.any((c) => c.unreadCount > 0)) ...[
                            const SizedBox(width: 5),
                            _TabBadge(count: _kActive.fold(0, (s, c) => s + c.unreadCount)),
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'Sent'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Requests'),
                          if (_incoming.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            _TabBadge(count: _incoming.length),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              // Active connections
              _ListTab(
                items: _filteredActive,
                emptyMessage: AppStrings.noConnectionsYet,
                emptyIcon: Icons.people_outline_rounded,
                itemBuilder: (conn) => _ActiveCard(conn: conn, onTap: () => _openChat(conn)),
              ),
              // Sent requests
              _ListTab(
                items: _filteredSent,
                emptyMessage: AppStrings.noRequestsYet,
                emptyIcon: Icons.send_outlined,
                itemBuilder: (conn) => _SentCard(conn: conn),
              ),
              // Incoming requests
              _ListTab(
                items: _filteredIncoming,
                emptyMessage: AppStrings.noRequestsYet,
                emptyIcon: Icons.inbox_outlined,
                itemBuilder: (conn) => _IncomingCard(
                  conn: conn,
                  onAccept: () => _accept(conn),
                  onDecline: () => _decline(conn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab badge ────────────────────────────────────────────────────────────────

class _TabBadge extends StatelessWidget {
  final int count;
  const _TabBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: AppTypography.labelXs.copyWith(color: context.bg, fontSize: 9, fontWeight: FontWeight.w800),
        ),
      );
}

// ─── Tab bar delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: context.bg, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

// ─── Generic list tab ─────────────────────────────────────────────────────────

class _ListTab extends StatelessWidget {
  final List<_Connection> items;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(_Connection) itemBuilder;

  const _ListTab({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 52, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(emptyMessage, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => itemBuilder(items[i]),
    );
  }
}

// ─── Active connection card ───────────────────────────────────────────────────

class _ActiveCard extends StatelessWidget {
  final _Connection conn;
  final VoidCallback onTap;
  const _ActiveCard({required this.conn, required this.onTap});

  String get _initials {
    final parts = conn.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conn.unreadCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: hasUnread ? conn.avatarColor.withValues(alpha: 0.25) : context.borderCol,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: conn.avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: conn.avatarColor.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: conn.avatarColor),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.bg, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${conn.unreadCount}',
                        style: AppTypography.labelXs.copyWith(color: context.bg, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(conn.name, style: AppTypography.labelMd.copyWith(fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600)),
                      Text(_fmtTime(conn.updatedAt), style: AppTypography.bodyXs.copyWith(color: hasUnread ? AppColors.teal : AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(conn.specialty, style: AppTypography.bodyXs.copyWith(color: conn.avatarColor)),
                  const SizedBox(height: 3),
                  Text(
                    conn.lastMessage,
                    style: AppTypography.bodySm.copyWith(
                      color: hasUnread ? AppColors.textSecondary : AppColors.textHint,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Sent request card ────────────────────────────────────────────────────────

class _SentCard extends StatelessWidget {
  final _Connection conn;
  const _SentCard({required this.conn});

  String get _initials {
    final parts = conn.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = conn.status == _ConnStatus.pending;
    final statusColor = isPending ? AppColors.amber : AppColors.red;
    final statusLabel = isPending ? AppStrings.pending : AppStrings.connectionDeclined;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: conn.avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: conn.avatarColor.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: conn.avatarColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conn.name, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(conn.specialty, style: AppTypography.bodyXs.copyWith(color: conn.avatarColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.pill,
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPending ? Icons.hourglass_top_rounded : Icons.cancel_outlined,
                  size: 12,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(statusLabel, style: AppTypography.labelXs.copyWith(color: statusColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Incoming request card ────────────────────────────────────────────────────

class _IncomingCard extends StatelessWidget {
  final _Connection conn;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingCard({required this.conn, required this.onAccept, required this.onDecline});

  String get _initials {
    final parts = conn.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: conn.avatarColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: conn.avatarColor.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: conn.avatarColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conn.name, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(conn.specialty, style: AppTypography.bodyXs.copyWith(color: conn.avatarColor)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Text('New', style: AppTypography.labelXs.copyWith(color: AppColors.teal, fontSize: 10)),
              ),
            ],
          ),
          if (conn.lastMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.mdAll,
              ),
              child: Text(
                conn.lastMessage,
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppStrings.declineRequest, style: AppTypography.buttonSm.copyWith(color: AppColors.red)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: AppBorderRadius.lgAll,
                    ),
                    alignment: Alignment.center,
                    child: Text(AppStrings.acceptRequest, style: AppTypography.buttonSm.copyWith(color: context.bg)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppColors.textHint, size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: AppStrings.searchConnections,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded, size: 16, color: AppColors.textHint),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
