import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  late TextEditingController _searchCtrl;
  final List<bool> _expandedFaqs = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: 'Help Center',
                leading: AppBarLeading.back,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Search Bar ─────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(fontSize: 14, color: context.primaryText),
                          decoration: InputDecoration(
                            hintText: 'How can we help you today?',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Quick Actions ──────────────────────────────────────
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildQuickActionCard(
                            icon: Icons.help_outline_rounded,
                            title: 'FAQs',
                            onTap: () =>
                                AppSnackbar.info(context, 'Opening FAQs...'),
                          ),
                          _buildQuickActionCard(
                            icon: Icons.headset_mic_rounded,
                            title: 'Support',
                            onTap: () =>
                                AppSnackbar.info(context, 'Opening Support...'),
                          ),
                          _buildQuickActionCard(
                            icon: Icons.error_outline_rounded,
                            title: 'Report Bug',
                            onTap: () =>
                                AppSnackbar.info(context, 'Opening Bug Report...'),
                          ),
                          _buildQuickActionCard(
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'Request Feature',
                            onTap: () =>
                                AppSnackbar.info(context, 'Opening Feature Request...'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Contact Options ───────────────────────────────────
                      const Text(
                        'Contact Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildContactOption(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Live Chat',
                              subtitle: 'Average wait: 2 mins',
                              statusBadge: 'ONLINE',
                              isOnline: true,
                            ),
                            Divider(
                              height: 1,
                              color: context.borderCol,
                            ),
                            _buildContactOption(
                              icon: Icons.mail_outline_rounded,
                              title: 'Email Support',
                              subtitle: 'Response within 24h',
                            ),
                            Divider(
                              height: 1,
                              color: context.borderCol,
                            ),
                            _buildContactOption(
                              icon: Icons.phone_in_talk_outlined,
                              title: 'Phone Call',
                              subtitle: 'Mon-Fri, 9am-6pm',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Frequent Questions ─────────────────────────────────
                      const Text(
                        'Frequent Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFaqItem(
                        0,
                        'How to set medicine reminders?',
                        'Navigate to the Health tab, select your medicines, and set custom reminder times. You can choose multiple reminders per day.',
                      ),
                      const SizedBox(height: 12),
                      _buildFaqItem(
                        1,
                        'Restoring your data backup',
                        'Go to Settings > Privacy & Security > Backup & Restore. Select your backup file and follow the on-screen instructions.',
                      ),
                      const SizedBox(height: 12),
                      _buildFaqItem(
                        2,
                        'Subscription & Billing',
                        'View and manage your subscription in Settings > Subscription. You can upgrade, downgrade, or cancel anytime.',
                      ),
                      const SizedBox(height: 12),
                      _buildFaqItem(
                        3,
                        'Privacy & Data Security',
                        'We use end-to-end encryption for all data. Your medical information is protected with bank-level security.',
                      ),
                      const SizedBox(height: 28),

                      // ── Resources ──────────────────────────────────────────
                      const Text(
                        'Resources',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildResourceCard(
                              icon: Icons.menu_book_rounded,
                              title: 'User Guide',
                              subtitle: 'Comprehensive manual for all features.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildResourceCard(
                              icon: Icons.play_circle_outline_rounded,
                              title: 'Video Tutorials',
                              subtitle: 'Quick visual guides for setup.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Feedback Section ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Love CareDose?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your feedback helps us provide better care for everyone in our community.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => AppSnackbar.success(
                                        context,
                                        'Thank you for rating!',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                      ),
                                      child: const Text(
                                        'Rate App',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: OutlinedButton(
                                      onPressed: () => AppSnackbar.success(
                                        context,
                                        'Thank you for your feedback!',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.white,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                      ),
                                      child: const Text(
                                        'Send Feedback',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Contact Support Button ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              AppSnackbar.info(context, 'Contacting support...'),
                          icon: const Icon(Icons.support_agent_rounded, size: 18),
                          label: const Text('Contact Support'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.mdAll,
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    String? statusBadge,
    bool isOnline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.secondaryText,
                        ),
                      ),
                    ),
                    if (statusBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusBadge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: context.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        onExpansionChanged: (val) => setState(() => _expandedFaqs[index] = val),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12,
                color: context.secondaryText,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: context.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
