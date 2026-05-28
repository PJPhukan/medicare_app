import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Args ─────────────────────────────────────────────────────────────────────

class PostArgs {
  final String id;
  final String authorName;
  final String category;
  final String content;
  final String timeAgo;
  final int likes;
  final int commentCount;
  final bool liked;

  const PostArgs({
    required this.id,
    required this.authorName,
    required this.category,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.commentCount,
    required this.liked,
  });
}

// ─── Comment model ────────────────────────────────────────────────────────────

class _Comment {
  final String id;
  final String authorName;
  final String content;
  final String timeAgo;

  const _Comment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timeAgo,
  });
}

final _kComments = [
  const _Comment(id: 'c1', authorName: 'Sita M.',
      content: 'This is so inspiring! I\'m also working on getting my HbA1c down. What does your daily diet look like?',
      timeAgo: '1h ago'),
  const _Comment(id: 'c2', authorName: 'Dr. Priya N.',
      content: 'Great results! Combining low-carb with regular walks can further improve insulin sensitivity.',
      timeAgo: '1.5h ago'),
  const _Comment(id: 'c3', authorName: 'Rahul K.',
      content: 'I tried something similar. Consistency is key — keep it up!',
      timeAgo: '2h ago'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostArgs post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late int _likes;
  late bool _liked;
  final _comments = List<_Comment>.from(_kComments);
  final _commentCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _liked = widget.post.liked;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleLike() => setState(() {
        if (_liked) { _likes--; _liked = false; }
        else { _likes++; _liked = true; }
      });

  void _submitComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, _Comment(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        authorName: 'You',
        content: text,
        timeAgo: 'just now',
      ));
    });
    _commentCtrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Community');
    }
    final post = widget.post;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: context.bg,
                    surfaceTintColor: Colors.transparent,
                    pinned: true,
                    leading: AppIconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: AppText.h3(AppStrings.community),
                    actions: [
                      AppIconButton(
                        icon: Icon(Icons.more_horiz_rounded, size: 22, color: context.primaryText),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Post header
                        Row(
                          children: [
                            AppAvatar(name: post.authorName, size: AppAvatarSize.md),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.bodyMd(post.authorName, fontWeight: FontWeight.w700),
                                  AppText.bodyXs(post.timeAgo, color: AppColors.textHint),
                                ],
                              ),
                            ),
                            AppContainer.tinted(
                              color: AppColors.teal,
                              borderRadius: AppBorderRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: AppText.labelXs(post.category, color: AppColors.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        AppText.bodyMd(post.content),
                        const SizedBox(height: 16),

                        // Like / comment row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleLike,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _liked ? AppColors.error.withValues(alpha: 0.08) : context.cardBg,
                                  borderRadius: AppBorderRadius.pill,
                                  border: Border.all(
                                    color: _liked ? AppColors.error.withValues(alpha: 0.3) : context.borderCol,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 16,
                                      color: _liked ? AppColors.error : AppColors.textHint,
                                    ),
                                    const SizedBox(width: 6),
                                    AppText.labelSm(
                                      '$_likes',
                                      color: _liked ? AppColors.error : context.secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AppContainer.outlined(
                              color: context.cardBg,
                              borderRadius: AppBorderRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              onTap: () => _focusNode.requestFocus(),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 6),
                                  AppText.labelSm('${_comments.length}', color: context.secondaryText),
                                ],
                              ),
                            ),
                            const Spacer(),
                            AppIconButton(
                              icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textHint),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        Divider(height: 28, color: context.borderCol),
                        AppText.labelXs('COMMENTS', color: AppColors.textHint, fontWeight: FontWeight.w600),
                        const SizedBox(height: 14),

                        if (_comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.textHint),
                                  const SizedBox(height: 10),
                                  AppText.bodySm(AppStrings.noMessages, color: context.secondaryText),
                                ],
                              ),
                            ),
                          )
                        else
                          ...List.generate(_comments.length, (i) => _CommentTile(comment: _comments[i])),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Comment input bar
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: BoxDecoration(
                color: context.cardBg,
                border: Border(top: BorderSide(color: context.borderCol)),
              ),
              child: Row(
                children: [
                  AppAvatar(name: 'Me', size: AppAvatarSize.xs),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      controller: _commentCtrl,
                      focusNode: _focusNode,
                      hint: 'Write a comment…',
                      borderRadius: AppBorderRadius.pill,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _commentCtrl,
                    builder: (_, val, __) => GestureDetector(
                      onTap: val.text.trim().isNotEmpty ? _submitComment : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: val.text.trim().isNotEmpty ? AppColors.teal : context.inputBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          size: 16,
                          color: val.text.trim().isNotEmpty ? Colors.white : AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(name: comment.authorName, size: AppAvatarSize.xs),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText.bodySm(comment.authorName, fontWeight: FontWeight.w700),
                      const Spacer(),
                      AppText.bodyXs(comment.timeAgo, color: AppColors.textHint),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText.bodySm(comment.content, color: context.secondaryText),
                ],
              ),
            ),
          ],
        ),
      );
}
