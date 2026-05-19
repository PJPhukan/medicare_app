import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── FAQ data ─────────────────────────────────────────────────────────────────

const _kFaqs = [
  (q: 'How do I add a medicine reminder?', a: 'Go to the Schedule tab or Reminders from the sidebar. Tap the + button to add a dose or reminder with your preferred time and repeat pattern.'),
  (q: 'Can I share my health data with my doctor?', a: 'Yes! Ask your doctor to connect with you via the Professionals tab. Once connected, you can grant them access to your reports and vitals.'),
  (q: 'How do I invite a caretaker?', a: 'Navigate to Caretakers from the sidebar, tap the person+ icon, and enter their email address. They\'ll receive an invite to create an account or link to yours.'),
  (q: 'Is my data secure?', a: 'All your health data is encrypted at rest and in transit. We comply with HIPAA and GDPR standards. You can export or delete your data at any time from Settings.'),
  (q: 'How do I cancel my subscription?', a: 'Open Settings → Subscription Plan → Manage Subscription. You can downgrade to the free plan at any time.'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _expandedFaq = -1;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: Text(AppStrings.support, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  color: context.bg,
                  child: TabBar(
                    controller: _tab,
                    indicatorColor: AppColors.teal,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.teal,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: AppTypography.labelSm,
                    tabs: const [
                      Tab(text: 'FAQ'),
                      Tab(text: 'Contact'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: [
              _FaqTab(expanded: _expandedFaq, onExpand: (i) => setState(() => _expandedFaq = _expandedFaq == i ? -1 : i)),
              const _ContactTab(),
              const _AboutTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FAQ tab ──────────────────────────────────────────────────────────────────

class _FaqTab extends StatelessWidget {
  final int expanded;
  final void Function(int) onExpand;

  const _FaqTab({required this.expanded, required this.onExpand});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            AppStrings.faq,
            style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          ...List.generate(_kFaqs.length, (i) {
            final faq = _kFaqs[i];
            final isOpen = expanded == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isOpen ? AppColors.teal.withValues(alpha: 0.06) : context.cardBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: isOpen ? AppColors.teal.withValues(alpha: 0.25) : context.borderCol),
              ),
              child: InkWell(
                onTap: () => onExpand(i),
                borderRadius: AppBorderRadius.lgAll,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.q,
                              style: AppTypography.bodySm.copyWith(
                                color: isOpen ? AppColors.teal : context.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isOpen ? AppColors.teal : AppColors.textHint,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 10),
                        Text(faq.a, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.6)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
}

// ─── Contact tab ──────────────────────────────────────────────────────────────

class _ContactTab extends StatefulWidget {
  const _ContactTab();

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = AppStrings.catBug;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) return;
    _subjectCtrl.clear();
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.ticketSubmitted, style: AppTypography.bodySm)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [AppStrings.catBug, AppStrings.catFeature, AppStrings.catAccount, AppStrings.catOtherTicket];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Quick links
        _QuickLink(icon: Icons.email_outlined, label: 'support@mediforze.com', color: AppColors.teal),
        const SizedBox(height: 8),
        _QuickLink(icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat (9 AM – 6 PM IST)', color: AppColors.blue),
        const SizedBox(height: 20),
        Text(AppStrings.submitTicket, style: AppTypography.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 14),

        // Category
        Text(AppStrings.ticketCategory, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: categories.map((c) {
            final sel = _category == c;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.teal.withValues(alpha: 0.15) : context.cardBg,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.5) : context.borderCol),
                ),
                child: Text(c, style: AppTypography.labelSm.copyWith(color: sel ? AppColors.teal : AppColors.textSecondary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        _SupportField(label: AppStrings.ticketSubject, controller: _subjectCtrl, hint: AppStrings.ticketSubjectHint),
        const SizedBox(height: 12),
        _SupportField(label: AppStrings.ticketMessage, controller: _messageCtrl, hint: AppStrings.ticketMessageHint, maxLines: 5),
        const SizedBox(height: 20),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _subjectCtrl,
          builder: (_, sv, __) => ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageCtrl,
            builder: (_, mv, __) {
              final canSubmit = sv.text.trim().isNotEmpty && mv.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: canSubmit ? _submit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: canSubmit ? AppColors.teal : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.submitTicketBtn,
                    style: AppTypography.buttonMd.copyWith(color: canSubmit ? context.bg : AppColors.textHint),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
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
            Text(label, style: AppTypography.bodySm.copyWith(color: context.primaryText)),
            const Spacer(),
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
          Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
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

// ─── About tab ────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // App card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.lgAll,
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: AppColors.teal, size: 34),
                ),
                const SizedBox(height: 12),
                Text('MediForze', style: AppTypography.h2.copyWith(fontSize: 22)),
                const SizedBox(height: 4),
                Text('Your Personal Health Companion', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _AboutRow(icon: Icons.star_rounded, label: AppStrings.rateApp, color: AppColors.amber),
          const SizedBox(height: 8),
          _AboutRow(icon: Icons.privacy_tip_outlined, label: AppStrings.privacyPolicy, color: AppColors.blue),
          const SizedBox(height: 8),
          _AboutRow(icon: Icons.description_outlined, label: AppStrings.termsOfService, color: AppColors.purple),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 MediForze. All rights reserved.',
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
            ),
          ),
        ],
      );
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AboutRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodySm.copyWith(color: context.primaryText))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      );
}
