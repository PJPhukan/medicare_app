import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/conversation_entity.dart';
import '../providers/message_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/network/connectivity_monitor.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Messages', showAppBar: false);
    }
    final st = ref.watch(messageProvider);
    final currentUserId = ref.read(authProvider).user?.id;

    final allConvs = st.conversations;
    final filtered = _query.isEmpty
        ? allConvs
        : allConvs.where((c) {
            final name = _contactName(c, currentUserId).toLowerCase();
            return name.contains(_query) ||
                (c.lastMessage ?? '').toLowerCase().contains(_query);
          }).toList();

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
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: openAppSidebar,
                tooltip: 'Menu',
                style: IconButton.styleFrom(backgroundColor: Colors.transparent),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: AppText.h3(AppStrings.messages),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: AppSearchTextInput(
                  hint: AppStrings.searchConversations,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
            ),

            if (st.isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: const SliverToBoxAdapter(
                  child: AppSkeletonList(count: 6, itemHeight: 78),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: _query.isNotEmpty
                      ? AppStrings.nothingFound
                      : AppStrings.noConversations,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final conv = filtered[i];
                      final name = _contactName(conv, currentUserId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ConvTile(
                          conv: conv,
                          contactName: name,
                          onTap: () => context.push(
                            AppRoutes.thread,
                            extra: ThreadArgs(
                              conversationId: conv.id,
                              contactName: name,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _contactName(ConversationEntity conv, String? currentUserId) {
    if (conv.participants.isEmpty) return 'Unknown';
    final other = conv.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => conv.participants.first,
    );
    return other.name;
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConvTile extends StatelessWidget {
  final ConversationEntity conv;
  final String contactName;
  final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.contactName, required this.onTap});

  String _fmtTime(String? isoStr) {
    if (isoStr == null) return '';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      if (isToday) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return AppStrings.yesterdayLabel;
      }
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.hasUnread;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: hasUnread
          ? AppColors.teal.withValues(alpha: 0.2)
          : null,
      child: Row(
        children: [
          // Avatar with optional unread badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(
                name: contactName,
                size: AppAvatarSize.md,
                borderWidth: 1,
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
                      '${conv.unreadCount}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: context.bg,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.labelMd(
                      contactName,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                    AppText.bodyXs(
                      _fmtTime(conv.lastMessageAt),
                      color: hasUnread ? AppColors.teal : AppColors.textHint,
                    ),
                  ],
                ),
                if (conv.lastMessage != null) ...[
                  const SizedBox(height: 3),
                  AppText.bodySm(
                    conv.lastMessage!,
                    color: hasUnread ? AppColors.textSecondary : AppColors.textHint,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
