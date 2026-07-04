import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_strings.dart';

// ─── Public helper ────────────────────────────────────────────────────────────

Future<void> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FeedbackSheet(),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

const _kCategories = [
  (label: 'App Experience', icon: Icons.phone_android_rounded),
  (label: 'Features',       icon: Icons.star_outline_rounded),
  (label: 'Performance',    icon: Icons.speed_rounded),
  (label: 'Bug Report',     icon: Icons.bug_report_outlined),
  (label: 'Suggestion',     icon: Icons.lightbulb_outline_rounded),
];

const _kEmojis = ['😞', '😕', '😐', '🙂', '😍'];
const _kEmojiLabels = ['Poor', 'Fair', 'Okay', 'Good', 'Excellent'];

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  int _rating = -1;
  String _category = 'App Experience';
  final _ctrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating < 0) return;
    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),

          if (_submitted)
            _SuccessState()
          else ...[
            // Header
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: const Icon(Icons.rate_review_rounded, color: AppColors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.feedbackTitle, style: AppTypography.h3.copyWith(fontSize: 18)),
                    Text('Help us improve MediForze',
                        style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emoji rating row
            Text('How would you rate your experience?',
                style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final sel = _rating == i;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: sel
                              ? _ratingColor(i).withValues(alpha: 0.15)
                              : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(
                            color: sel ? _ratingColor(i).withValues(alpha: 0.5) : context.borderCol,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _kEmojis[i],
                          style: TextStyle(fontSize: sel ? 26 : 22),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _kEmojiLabels[i],
                        style: AppTypography.bodyXs.copyWith(
                          color: sel ? _ratingColor(i) : AppColors.textHint,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Category chips
            Text('What are you giving feedback on?',
                style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _kCategories[i];
                  final sel = _category == cat.label;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.teal.withValues(alpha: 0.12) : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 13,
                              color: sel ? AppColors.teal : AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(cat.label,
                              style: AppTypography.labelXs.copyWith(
                                color: sel ? AppColors.teal : AppColors.textSecondary,
                                letterSpacing: 0,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Message field
            Container(
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 4,
                style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: AppStrings.feedbackHint,
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
            const SizedBox(height: 20),

            // Submit button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrl,
              builder: (_, val, __) {
                final canSubmit = _rating >= 0;
                return GestureDetector(
                  onTap: canSubmit ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: canSubmit ? AppColors.green : context.borderCol,
                      borderRadius: AppBorderRadius.lgAll,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                            'Send Feedback',
                            style: AppTypography.buttonMd.copyWith(
                              color: canSubmit ? Colors.white : AppColors.textHint,
                            ),
                          ),
                  ),
                );
              },
            ),
            if (_rating < 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text('Select a rating to continue',
                    style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

Color _ratingColor(int i) => switch (i) {
      0 => AppColors.error,
      1 => AppColors.amber,
      2 => AppColors.amber,
      3 => AppColors.green,
      4 => AppColors.teal,
      _ => AppColors.teal,
    };

// ─── Success state ────────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.green, size: 36),
            ),
            const SizedBox(height: 16),
            Text(AppStrings.feedbackSubmitted,
                style: AppTypography.h3.copyWith(fontSize: 18, color: AppColors.green)),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us build a better app for everyone.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
