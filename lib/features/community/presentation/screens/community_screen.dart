import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/community_provider.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import '../../../../core/network/connectivity_monitor.dart';

const _kCategories = ['All', 'Diabetes', 'Hypertension', 'Mental Health', 'General', 'Nutrition'];

String _timeAgo(String iso) {
  try {
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  } catch (_) { return ''; }
}

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _activeCategory = 'All';

  void _toggleLike(PostEntity post) =>
      ref.read(communityProvider.notifier).likePost(post.id);

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Community', showAppBar: false);
    }
    final st = ref.watch(communityProvider);
    final posts = st.posts;
    final filtered = _activeCategory == 'All'
        ? posts
        : posts.where((p) => p.title == _activeCategory).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        floatingActionButton: AppFAB(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          ).then((created) {
            if (created == true) ref.read(communityProvider.notifier).load();
          }),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              floating: true,
              expandedHeight: 100,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: AppText.h2(AppStrings.community),
                background: Container(color: context.bg),
              ),
            ),
          ],
          body: CustomScrollView(
            slivers: [
              // Category filter
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _kCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _kCategories[i];
                      final sel = _activeCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _activeCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.teal.withValues(alpha: 0.12) : context.cardBg,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                            ),
                          ),
                          child: AppText.labelSm(
                            cat,
                            color: sel ? AppColors.teal : context.secondaryText,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (st.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.forum_outlined,
                    title: AppStrings.noPosts,
                    subtitle: 'Be the first to post in this category',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final post = filtered[i];
                        return _PostCard(
                          post: post,
                          onLike: () => _toggleLike(post),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                post: PostArgs(
                                  id: post.id,
                                  authorName: post.author.name,
                                  category: post.title,
                                  content: post.body,
                                  timeAgo: _timeAgo(post.createdAt),
                                  likes: post.likesCount,
                                  commentCount: post.commentsCount,
                                  liked: post.isLikedByMe,
                                ),
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
      ),
    );
  }
}

// ─── Post card ────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onLike, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: post.author.name, size: AppAvatarSize.sm),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySm(post.author.name, fontWeight: FontWeight.w600),
                    AppText.bodyXs(_timeAgo(post.createdAt), color: AppColors.textHint),
                  ],
                ),
              ),
              AppContainer.tinted(
                color: AppColors.teal,
                borderRadius: AppBorderRadius.pill,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: AppText.labelXs(post.title, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodySm(
            post.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: post.isLikedByMe ? AppColors.error : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    AppText.bodyXs(
                      '${post.likesCount}',
                      color: post.isLikedByMe ? AppColors.error : context.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  AppText.bodyXs(
                    '${post.commentsCount}',
                    color: context.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 16, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
