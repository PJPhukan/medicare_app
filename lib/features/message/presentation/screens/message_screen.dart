import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'thread_screen.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _Conv {
  final String id;
  final String name;
  final String role;
  final Color avatarColor;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const _Conv({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kConversations = [
  _Conv(
    id: 'c1',
    name: 'Dr. Arjun Sharma',
    role: 'Doctor',
    avatarColor: AppColors.teal,
    lastMessage: 'Your blood pressure readings look elevated this week. Please rest and recheck.',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    unreadCount: 2,
  ),
  _Conv(
    id: 'c2',
    name: 'Sunita Devi',
    role: 'Caregiver',
    avatarColor: AppColors.red,
    lastMessage: 'I have given the evening medicines and logged them.',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 4)),
    unreadCount: 0,
  ),
  _Conv(
    id: 'c3',
    name: 'Dr. Vikram Nair',
    role: 'Physiotherapist',
    avatarColor: AppColors.green,
    lastMessage: 'Great progress! Keep doing the knee exercises twice daily.',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
  ),
  _Conv(
    id: 'c4',
    name: 'Ravi Shankar',
    role: 'Dietitian',
    avatarColor: AppColors.amber,
    lastMessage: 'Here is your personalised meal plan for the week.',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 3)),
    unreadCount: 0,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Conv> get _filtered {
    if (_query.isEmpty) return _kConversations;
    return _kConversations.where((c) =>
      c.name.toLowerCase().contains(_query) ||
      c.lastMessage.toLowerCase().contains(_query),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
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
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: Text(AppStrings.messages, style: AppTypography.h3),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SearchBar(controller: _searchCtrl),
              ),
            ),

            // Conversation list
            filtered.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 52, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            _query.isNotEmpty
                                ? AppStrings.nothingFound
                                : AppStrings.noConversations,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ConvTile(
                            conv: filtered[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ThreadScreen(
                                  contactName: filtered[i].name,
                                  contactRole: filtered[i].role,
                                  avatarColor: filtered[i].avatarColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
          ],
        ),
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
                hintText: AppStrings.searchConversations,
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

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConvTile extends StatelessWidget {
  final _Conv conv;
  final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.onTap});

  String get _initials {
    final parts = conv.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.unreadCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: hasUnread ? conv.avatarColor.withValues(alpha: 0.2) : context.borderCol,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: conv.avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: conv.avatarColor.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: conv.avatarColor,
                    ),
                  ),
                ),
                // Unread dot
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
                        style: AppTypography.labelXs.copyWith(
                          color: context.bg,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
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
                      Text(
                        conv.name,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        _fmtTime(conv.lastMessageAt),
                        style: AppTypography.bodyXs.copyWith(
                          color: hasUnread ? AppColors.teal : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conv.role,
                    style: AppTypography.bodyXs.copyWith(color: conv.avatarColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conv.lastMessage,
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
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return AppStrings.yesterdayLabel;
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
