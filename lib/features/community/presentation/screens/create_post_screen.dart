import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

const _kCategories = ['General', 'Diabetes', 'Hypertension', 'Mental Health', 'Nutrition', 'Fitness'];

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  String _category = 'General';
  bool _posting = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_contentCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _posting = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              leading: IconButton(
                icon: Icon(Icons.close_rounded, color: context.primaryText, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _contentCtrl,
                    builder: (_, val, __) {
                      final canPost = val.text.trim().isNotEmpty && !_posting;
                      return GestureDetector(
                        onTap: canPost ? _post : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: canPost ? AppColors.teal : context.inputBg,
                            borderRadius: AppBorderRadius.lgAll,
                          ),
                          child: _posting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                                )
                              : Text(
                                  AppStrings.createPost,
                                  style: AppTypography.buttonSm.copyWith(
                                    color: canPost ? AppColors.textInverse : AppColors.textHint,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: Text(AppStrings.createPost, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Author row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                        child: Text('AK', style: AppTypography.labelSm.copyWith(color: AppColors.teal, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arjun Kumar', style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
                          Text('Posting to Community', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Content input
                  Container(
                    constraints: const BoxConstraints(minHeight: 180),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      autofocus: true,
                      style: AppTypography.bodyMd.copyWith(color: context.primaryText, height: 1.6),
                      decoration: InputDecoration(
                        hintText: AppStrings.whatsOnYourMind,
                        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'CATEGORY',
                    style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kCategories.map((c) {
                      final sel = _category == c;
                      return GestureDetector(
                        onTap: () => setState(() => _category = c),
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
                          child: Text(
                            c,
                            style: AppTypography.labelSm.copyWith(
                              color: sel ? AppColors.teal : AppColors.textSecondary,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Guidelines
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.06),
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(color: AppColors.blue.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.blue),
                            const SizedBox(width: 6),
                            Text('Community Guidelines',
                                style: AppTypography.labelSm.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Be respectful and supportive of others\n'
                          '• This is not a replacement for professional medical advice\n'
                          '• Do not share personal medical information of others',
                          style: AppTypography.bodyXs.copyWith(color: AppColors.blue, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
