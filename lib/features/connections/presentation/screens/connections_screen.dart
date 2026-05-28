import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/entities/connection_request_entity.dart';
import '../providers/connections_provider.dart';
import 'chat_screen.dart';
import '../../../../core/network/connectivity_monitor.dart';

String _fmtTime(String? isoStr) {
  if (isoStr == null) return '';
  final dt = DateTime.tryParse(isoStr);
  if (dt == null) return '';
  final now = DateTime.now();
  final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
  if (isToday) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${dt.day} ${months[dt.month - 1]}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

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

  void _openChat(ConnectionEntity conn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          connectionId: conn.id,
          professionalName: conn.connectedUser.name,
          professionalSpecialty: '',
        ),
      ),
    );
  }

  Future<void> _accept(String requestId) async {
    await ref.read(connectionsProvider.notifier).acceptRequest(requestId);
    if (!mounted) return;
    AppSnackbar.success(context, AppStrings.connectionAccepted);
  }

  Future<void> _decline(String requestId) async {
    await ref.read(connectionsProvider.notifier).declineRequest(requestId);
    if (!mounted) return;
    AppSnackbar.info(context, AppStrings.requestDeclined);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Connections', showAppBar: false);
    }
    final st = ref.watch(connectionsProvider);

    final filteredActive = _query.isEmpty
        ? st.connections
        : st.connections
            .where((c) => c.connectedUser.name.toLowerCase().contains(_query))
            .toList();

    final filteredIncoming = _query.isEmpty
        ? st.incomingRequests
        : st.incomingRequests
            .where((r) => r.sender.name.toLowerCase().contains(_query))
            .toList();

    final incomingCount = st.incomingRequests.length;

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
              leading: AppIconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: openAppSidebar,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: AppText.h3(AppStrings.myConnections),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: AppSearchField(
                  controller: _searchCtrl,
                  hint: AppStrings.searchConnections,
                  onClear: _searchCtrl.clear,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppColors.teal,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.teal,
                  unselectedLabelColor: AppColors.textHint,
                  dividerColor: context.borderCol,
                  tabs: [
                    const Tab(text: 'Active'),
                    const Tab(text: 'Sent'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Requests'),
                          if (incomingCount > 0) ...[
                            const SizedBox(width: 5),
                            _TabBadge(count: incomingCount),
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
              _ListTab<ConnectionEntity>(
                items: filteredActive,
                isLoading: st.isLoading,
                emptyMessage: AppStrings.noConnectionsYet,
                emptyIcon: Icons.people_outline_rounded,
                itemBuilder: (conn) => _ActiveCard(conn: conn, onTap: () => _openChat(conn)),
              ),
              _ListTab<Never>(
                items: const [],
                isLoading: false,
                emptyMessage: AppStrings.noRequestsYet,
                emptyIcon: Icons.send_outlined,
                itemBuilder: (_) => const SizedBox.shrink(),
              ),
              _ListTab<ConnectionRequestEntity>(
                items: filteredIncoming,
                isLoading: st.isLoading,
                emptyMessage: AppStrings.noRequestsYet,
                emptyIcon: Icons.inbox_outlined,
                itemBuilder: (req) => _IncomingCard(
                  req: req,
                  onAccept: () => _accept(req.id),
                  onDecline: () => _decline(req.id),
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
          style: TextStyle(
            color: context.bg,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
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

class _ListTab<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(T) itemBuilder;

  const _ListTab({
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: AppEmptyState(icon: emptyIcon, title: emptyMessage),
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
  final ConnectionEntity conn;
  final VoidCallback onTap;
  const _ActiveCard({required this.conn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = conn.connectedUser.name;
    final timeStr = _fmtTime(conn.lastMessageAt ?? conn.createdAt);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppAvatar(name: name, size: AppAvatarSize.md),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.labelMd(name, fontWeight: FontWeight.w600),
                    if (timeStr.isNotEmpty)
                      AppText.bodyXs(timeStr, color: AppColors.textHint),
                  ],
                ),
                const SizedBox(height: 2),
                AppText.bodySm(AppStrings.connected, color: AppColors.teal),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }
}

// ─── Incoming request card ────────────────────────────────────────────────────

class _IncomingCard extends StatelessWidget {
  final ConnectionRequestEntity req;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingCard({required this.req, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final name = req.sender.name;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: name, size: AppAvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: AppText.labelMd(name, fontWeight: FontWeight.w600),
              ),
              AppContainer.tinted(
                color: AppColors.teal,
                borderRadius: AppBorderRadius.pill,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: AppText.labelXs('New', color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  label: AppStrings.declineRequest,
                  color: AppColors.error,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.primary(
                  label: AppStrings.acceptRequest,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
