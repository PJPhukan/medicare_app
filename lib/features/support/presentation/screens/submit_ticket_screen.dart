import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../providers/support_provider.dart';

class SubmitTicketScreen extends ConsumerStatefulWidget {
  const SubmitTicketScreen({super.key});

  @override
  ConsumerState<SubmitTicketScreen> createState() => _SubmitTicketScreenState();
}

class _SubmitTicketScreenState extends ConsumerState<SubmitTicketScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = AppStrings.catBug;
  bool _submitting = false;

  static const _categories = [
    AppStrings.catBug,
    AppStrings.catFeature,
    AppStrings.catAccount,
    AppStrings.catOtherTicket,
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) return;
    AppLogger.i('Ticket submit → category:$_category', tag: 'Support');
    setState(() => _submitting = true);
    try {
      await ref.read(submitTicketProvider).call(
        subject: _subjectCtrl.text.trim(),
        body: _messageCtrl.text.trim(),
        category: _category,
      );
      AppLogger.i('Ticket submitted ✓', tag: 'Support');
      if (!mounted) return;
      _subjectCtrl.clear();
      _messageCtrl.clear();
      AppSnackbar.success(context, AppStrings.ticketSubmitted);
      context.pop();
    } on Exception catch (e) {
      AppLogger.e('Ticket submit failed', tag: 'Support', error: e);
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackbar.error(context, e.toString());
    }
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
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: AppText.h2(AppStrings.submitTicket),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick contact links
                  _QuickLink(icon: Icons.email_outlined, label: 'support@mediforze.com', color: AppColors.teal),
                  const SizedBox(height: 8),
                  _QuickLink(icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat (9 AM – 6 PM IST)', color: AppColors.blue),
                  const SizedBox(height: 24),
                  _SectionLabel('CATEGORY'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((c) {
                      final sel = _category == c;
                      return GestureDetector(
                        onTap: () => setState(() => _category = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.teal.withValues(alpha: 0.12) : context.cardBg,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              letterSpacing: 0.5,
                              color: sel ? AppColors.teal : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('YOUR MESSAGE'),
                  const SizedBox(height: 10),
                  _SupportField(
                    label: AppStrings.ticketSubject,
                    controller: _subjectCtrl,
                    hint: AppStrings.ticketSubjectHint,
                  ),
                  const SizedBox(height: 10),
                  _SupportField(
                    label: AppStrings.ticketMessage,
                    controller: _messageCtrl,
                    hint: AppStrings.ticketMessageHint,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 8),
                  AppText.bodyXs(
                    'We typically respond within 24 hours on business days.',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 28),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _subjectCtrl,
                    builder: (_, sv, __) => ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _messageCtrl,
                      builder: (_, mv, __) {
                        final canSubmit = sv.text.trim().isNotEmpty && mv.text.trim().isNotEmpty && !_submitting;
                        return GestureDetector(
                          onTap: canSubmit ? _submit : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: canSubmit ? AppColors.teal : context.inputBg,
                              borderRadius: AppBorderRadius.lgAll,
                            ),
                            alignment: Alignment.center,
                            child: _submitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                                : Text(
                                    AppStrings.submitTicketBtn,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      color: canSubmit ? AppColors.textInverse : AppColors.textHint,
                                    ),
                                  ),
                          ),
                        );
                      },
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 1),
      );
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickLink({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(child: AppText.bodySm(label, color: context.primaryText)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      );
}

class _SupportField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _SupportField({required this.label, required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyXs(label, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(fontSize: 14, color: context.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      );
}
