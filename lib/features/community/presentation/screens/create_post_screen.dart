import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/community_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/utils/logger.dart';

const _kCategories = [
  'General',
  'Diabetes',
  'Hypertension',
  'Mental Health',
  'Nutrition',
  'Fitness'
];

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
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
    AppLogger.i('Post create → category:$_category', tag: 'Community');
    setState(() => _posting = true);
    try {
      await ref.read(createPostProvider).call(
            title: _category,
            body: _contentCtrl.text.trim(),
          );
      AppLogger.i('Post created ✓', tag: 'Community');
      if (!mounted) return;
      context.pop(true);
    } on Exception catch (e) {
      AppLogger.e('Post create failed', tag: 'Community', error: e);
      if (!mounted) return;
      setState(() => _posting = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Community');
    }
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
              leading: AppIconButton(
                icon: Icon(Icons.close_rounded,
                    color: context.primaryText, size: 22),
                onPressed: () => context.pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _contentCtrl,
                    builder: (_, val, __) {
                      final canPost = val.text.trim().isNotEmpty && !_posting;
                      return AppButton(
                        variant: AppButtonVariant.primary,
                        label: AppStrings.createPost,
                        size: AppButtonSize.sm,
                        isLoading: _posting,
                        onPressed: canPost ? _post : null,
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: AppText.h2(AppStrings.createPost),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Author row
                  Builder(builder: (context) {
                    final user = ref.read(authProvider).user;
                    final name = user?.name ?? '';
                    return Row(
                      children: [
                        AppAvatar(name: name, size: AppAvatarSize.sm),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.bodyMd(name, fontWeight: FontWeight.w600),
                            AppText.bodyXs('Posting to Community',
                                color: context.secondaryText),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: _contentCtrl,
                    hint: AppStrings.whatsOnYourMind,
                    autofocus: true,
                    maxLines: 20,
                    minLines: 8,
                  ),
                  const SizedBox(height: 24),

                  AppText.labelXs('CATEGORY',
                      color: AppColors.textHint, fontWeight: FontWeight.w600),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.teal.withValues(alpha: 0.12)
                                : context.cardBg,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: sel
                                  ? AppColors.teal.withValues(alpha: 0.4)
                                  : context.borderCol,
                            ),
                          ),
                          child: AppText.labelSm(
                            c,
                            color: sel ? AppColors.teal : context.secondaryText,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Community guidelines
                  AppContainer.tinted(
                    color: AppColors.blue,
                    borderRadius: AppBorderRadius.lgAll,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 14, color: AppColors.blue),
                            const SizedBox(width: 6),
                            AppText.labelSm('Community Guidelines',
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppText.bodyXs(
                          '• Be respectful and supportive of others\n'
                          '• This is not a replacement for professional medical advice\n'
                          '• Do not share personal medical information of others',
                          color: AppColors.blue,
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
