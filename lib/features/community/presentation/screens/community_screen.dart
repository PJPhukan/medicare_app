import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Post {
  final String id;
  final String authorName;
  final Color authorColor;
  final String category;
  final String content;
  final String timeAgo;
  int likes;
  final int commentCount;
  bool liked;

  _Post({
    required this.id,
    required this.authorName,
    required this.authorColor,
    required this.category,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.commentCount,
    this.liked = false,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kPosts = [
  _Post(
    id: 'p1',
    authorName: 'Rohit S.',
    authorColor: AppColors.teal,
    category: 'Diabetes',
    content: 'Anyone else managing Type 2 with diet alone? Managed to bring my HbA1c from 8.2 to 6.8 in 6 months purely through low-carb eating. Happy to share what worked for me!',
    timeAgo: '2h ago',
    likes: 34,
    commentCount: 12,
  ),
  _Post(
    id: 'p2',
    authorName: 'Meena K.',
    authorColor: AppColors.pink,
    category: 'Hypertension',
    content: 'My cardiologist recommended DASH diet for blood pressure management. Week 3 in and already seeing consistent readings under 130/85. Feeling more in control.',
    timeAgo: '5h ago',
    likes: 21,
    commentCount: 7,
    liked: true,
  ),
  _Post(
    id: 'p3',
    authorName: 'Arjun P.',
    authorColor: AppColors.blue,
    category: 'General',
    content: 'Tip: Setting medicine reminders 15 minutes early gives you buffer time. No more missed doses since I started doing this!',
    timeAgo: '1d ago',
    likes: 58,
    commentCount: 19,
  ),
  _Post(
    id: 'p4',
    authorName: 'Divya R.',
    authorColor: AppColors.purple,
    category: 'Mental Health',
    content: 'Struggling with medication fatigue — taking 6 pills a day is exhausting. Would love to hear how others stay motivated to stick to their regimen.',
    timeAgo: '2d ago',
    likes: 45,
    commentCount: 28,
  ),
];

const _kCategories = ['All', 'Diabetes', 'Hypertension', 'Mental Health', 'General', 'Nutrition'];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _posts = _kPosts.map((p) => _Post(
    id: p.id, authorName: p.authorName, authorColor: p.authorColor,
    category: p.category, content: p.content, timeAgo: p.timeAgo,
    likes: p.likes, commentCount: p.commentCount, liked: p.liked,
  )).toList();
  String _activeCategory = 'All';

  List<_Post> get _filtered => _activeCategory == 'All'
      ? _posts
      : _posts.where((p) => p.category == _activeCategory).toList();

  void _toggleLike(_Post post) => setState(() {
        if (post.liked) { post.likes--; post.liked = false; }
        else { post.likes++; post.liked = true; }
      });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.teal,
          onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          ).then((created) {
            if (created == true) setState(() {});
          }),
          child: const Icon(Icons.edit_rounded, color: Colors.white),
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
                title: Text(AppStrings.community, style: AppTypography.h2.copyWith(fontSize: 22)),
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
                            border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol),
                          ),
                          child: Text(
                            cat,
                            style: AppTypography.labelSm.copyWith(
                              color: sel ? AppColors.teal : AppColors.textSecondary,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (_filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.forum_outlined, size: 52, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(AppStrings.noPosts, style: AppTypography.h3.copyWith(fontSize: 17)),
                        const SizedBox(height: 8),
                        Text('Be the first to post in this category',
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final post = _filtered[i];
                        return _PostCard(
                          post: post,
                          onLike: () => _toggleLike(post),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PostDetailScreen(post: PostArgs(
                              id: post.id,
                              authorName: post.authorName,
                              authorColor: post.authorColor,
                              category: post.category,
                              content: post.content,
                              timeAgo: post.timeAgo,
                              likes: post.likes,
                              commentCount: post.commentCount,
                              liked: post.liked,
                            ))),
                          ),
                        );
                      },
                      childCount: _filtered.length,
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
  final _Post post;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onLike, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.xlAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: post.authorColor.withValues(alpha: 0.15),
                    child: Text(post.authorName[0],
                        style: AppTypography.labelSm.copyWith(color: post.authorColor, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName,
                            style: AppTypography.bodySm.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
                        Text(post.timeAgo, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                    ),
                    child: Text(post.category, style: AppTypography.labelXs.copyWith(color: AppColors.teal)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content,
                  style: AppTypography.bodySm.copyWith(color: context.primaryText, height: 1.6),
                  maxLines: 4, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      children: [
                        Icon(
                          post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: post.liked ? AppColors.error : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likes}',
                            style: AppTypography.bodyXs.copyWith(
                              color: post.liked ? AppColors.error : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}',
                          style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined, size: 16, color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      );
}
