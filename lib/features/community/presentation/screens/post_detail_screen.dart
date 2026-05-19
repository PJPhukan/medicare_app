import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Args ─────────────────────────────────────────────────────────────────────

class PostArgs {
  final String id;
  final String authorName;
  final Color authorColor;
  final String category;
  final String content;
  final String timeAgo;
  final int likes;
  final int commentCount;
  final bool liked;

  const PostArgs({
    required this.id,
    required this.authorName,
    required this.authorColor,
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
  final Color authorColor;
  final String content;
  final String timeAgo;

  const _Comment({
    required this.id,
    required this.authorName,
    required this.authorColor,
    required this.content,
    required this.timeAgo,
  });
}

final _kComments = [
  _Comment(id: 'c1', authorName: 'Sita M.', authorColor: AppColors.green,
      content: 'This is so inspiring! I\'m also working on getting my HbA1c down. What does your daily diet look like?',
      timeAgo: '1h ago'),
  _Comment(id: 'c2', authorName: 'Dr. Priya N.', authorColor: AppColors.teal,
      content: 'Great results! Combining low-carb with regular walks can further improve insulin sensitivity.',
      timeAgo: '1.5h ago'),
  _Comment(id: 'c3', authorName: 'Rahul K.', authorColor: AppColors.blue,
      content: 'I tried something similar. Consistency is key — keep it up!',
      timeAgo: '2h ago'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PostDetailScreen extends StatefulWidget {
  final PostArgs post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
        authorColor: AppColors.teal,
        content: text,
        timeAgo: 'just now',
      ));
    });
    _commentCtrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(AppStrings.community, style: AppTypography.h3.copyWith(fontSize: 17)),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, size: 22),
                        color: context.primaryText,
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
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: post.authorColor.withValues(alpha: 0.15),
                              child: Text(post.authorName[0],
                                  style: AppTypography.h3.copyWith(color: post.authorColor, fontSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName,
                                      style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700)),
                                  Text(post.timeAgo, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.08),
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                              ),
                              child: Text(post.category, style: AppTypography.labelXs.copyWith(color: AppColors.teal)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Post content
                        Text(post.content,
                            style: AppTypography.bodyMd.copyWith(color: context.primaryText, height: 1.7)),
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
                                    Text('$_likes',
                                        style: AppTypography.labelSm.copyWith(
                                          color: _liked ? AppColors.error : AppColors.textSecondary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _focusNode.requestFocus(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  borderRadius: AppBorderRadius.pill,
                                  border: Border.all(color: context.borderCol),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textHint),
                                    const SizedBox(width: 6),
                                    Text('${_comments.length}',
                                        style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textHint),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        Divider(height: 28, color: context.borderCol),
                        Text(
                          'COMMENTS',
                          style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1),
                        ),
                        const SizedBox(height: 14),
                        if (_comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.textHint),
                                  const SizedBox(height: 10),
                                  Text(AppStrings.noMessages, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                    child: Text('AK', style: AppTypography.labelXs.copyWith(color: AppColors.teal, fontSize: 9)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        focusNode: _focusNode,
                        style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                        decoration: InputDecoration(
                          hintText: 'Write a comment…',
                          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
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
            CircleAvatar(
              radius: 16,
              backgroundColor: comment.authorColor.withValues(alpha: 0.15),
              child: Text(comment.authorName[0],
                  style: AppTypography.labelXs.copyWith(color: comment.authorColor, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.authorName,
                          style: AppTypography.bodySm.copyWith(color: context.primaryText, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(comment.timeAgo, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content,
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );
}
