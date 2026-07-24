import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/logger.dart';

class BecomeAProfessionalScreen extends ConsumerStatefulWidget {
  const BecomeAProfessionalScreen({super.key});

  @override
  ConsumerState<BecomeAProfessionalScreen> createState() =>
      _BecomeAProfessionalScreenState();
}

class _BecomeAProfessionalScreenState
    extends ConsumerState<BecomeAProfessionalScreen> {
  late PageController _storiesController;
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _storiesController = PageController();
  }

  @override
  void dispose() {
    _storiesController.dispose();
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
                title: 'Become a Professional',
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
                      // ── Header Badge ───────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'CAREDOSE PRO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Main Title ─────────────────────────────────────────
                      const Text(
                        'Grow Your Healthcare Practice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seamlessly manage patient consultations, secure records, and digital prescriptions on India\'s most trusted healthcare platform.',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Hero Image ─────────────────────────────────────────
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: AppBorderRadius.lgAll,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.teal.withValues(alpha: 0.15),
                              AppColors.blue.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 100,
                            color: AppColors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Monthly Earnings ───────────────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimated Monthly Earnings',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 18,
                                  color: AppColors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '₹35,000–₹90,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on 15-30 consultations weekly',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(
                                7,
                                (i) => Expanded(
                                  child: Container(
                                    height: 30,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withValues(
                                        alpha: 0.1 + (i * 0.1),
                                      ),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Professional Benefits ──────────────────────────────
                      const Text(
                        'Professional Benefits',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefit(
                        icon: Icons.verified_rounded,
                        title: 'Verified Badge',
                        description: 'Instant credibility with patient trust.',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit(
                        icon: Icons.videocam_rounded,
                        title: 'Video Consultations',
                        description: 'HD-quality encrypted tele-medicine tools.',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit(
                        icon: Icons.account_balance_rounded,
                        title: 'Instant Payouts',
                        description: 'Direct transfer to your bank account.',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit(
                        icon: Icons.bar_chart_rounded,
                        title: 'Practice Analytics',
                        description: 'Detailed insights into your reach.',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit(
                        icon: Icons.schedule_rounded,
                        title: 'Flexible Hours',
                        description: 'Manage your availability with ease.',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefit(
                        icon: Icons.description_rounded,
                        title: 'Digital Prescriptions',
                        description: 'Highly compliant & secure records.',
                      ),
                      const SizedBox(height: 28),

                      // ── Registration Checklist ─────────────────────────────
                      const Text(
                        'Registration Checklist',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            _buildChecklistItem(
                              '2/4 Steps Completed',
                              'Medical Degree',
                              true,
                              'Verified',
                            ),
                            const SizedBox(height: 12),
                            _buildChecklistItem(
                              '',
                              'Identity Proof (Aadhaar/PAN)',
                              true,
                              'Verified',
                            ),
                            const SizedBox(height: 12),
                            _buildChecklistItem(
                              '',
                              'Professional Registration (MCI/SMC)',
                              false,
                              'Pending',
                            ),
                            const SizedBox(height: 12),
                            _buildChecklistItem(
                              '',
                              'Clinic Address / Ownership Proof',
                              false,
                              'Required',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Application Progress ───────────────────────────────
                      const Text(
                        'Application Progress',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildProgressStep('1', 'Personal', true),
                          SizedBox(
                            width: 24,
                            height: 2,
                            child: Container(
                              color: AppColors.teal.withValues(alpha: 0.3),
                            ),
                          ),
                          _buildProgressStep('2', 'Verification', true),
                          SizedBox(
                            width: 24,
                            height: 2,
                            child: Container(
                              color: AppColors.textHint.withValues(alpha: 0.3),
                            ),
                          ),
                          _buildProgressStep('3', 'Approval', false),
                          SizedBox(
                            width: 24,
                            height: 2,
                            child: Container(
                              color: AppColors.textHint.withValues(alpha: 0.3),
                            ),
                          ),
                          _buildProgressStep('4', 'Dashboard', false),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Success Stories ────────────────────────────────────
                      const Text(
                        'Success Stories',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: PageView(
                          controller: _storiesController,
                          onPageChanged: (i) =>
                              setState(() => _currentStoryIndex = i),
                          children: [
                            _buildSuccessStory(
                              'Dr. Sarah Menon',
                              'Cardiologist, 12 yrs exp.',
                              '"CareDose transformed how I manage my practice. The consultation quality is unmatched."',
                            ),
                            _buildSuccessStory(
                              'Dr. Raj Kumar',
                              'General Physician, 8 yrs exp.',
                              '"Best platform for digital consultations. Highly recommend to all professionals."',
                            ),
                            _buildSuccessStory(
                              'Dr. Priya Singh',
                              'Dermatologist, 10 yrs exp.',
                              '"Secure, reliable, and patient-friendly. This is the future of healthcare."',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentStoryIndex == i
                                  ? AppColors.teal
                                  : AppColors.teal.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── FAQ Section ────────────────────────────────────────
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'How long does the verification process take?',
                        'Typically, our medical board reviews applications within 3-5 business days. Once your registration and degree are verified, your profile will be activated.',
                      ),
                      const SizedBox(height: 8),
                      _buildFAQItem(
                        'What are the platform commission fees?',
                        'We charge a competitive commission based on your consultation type and specialization. Detailed breakdown available during registration.',
                      ),
                      const SizedBox(height: 8),
                      _buildFAQItem(
                        'Can I manage multiple clinic locations?',
                        'Yes! You can add and manage multiple clinic addresses within your dashboard.',
                      ),
                      const SizedBox(height: 28),

                      // ── Start Application Button ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AppLogger.i('Starting professional application',
                                tag: 'Professional');
                            context.push(AppRoutes.proApplication);
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Start Application'),
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

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.mdAll,
          ),
          child: Icon(icon, size: 20, color: AppColors.teal),
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
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(
    String header,
    String title,
    bool completed,
    String status,
  ) {
    return Row(
      children: [
        if (header.isNotEmpty)
          Expanded(
            child: Text(
              header,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
              ),
            ),
          ),
        if (header.isEmpty) const SizedBox(width: 0),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? AppColors.green : AppColors.textHint,
            ),
            color: completed ? AppColors.green : Colors.transparent,
          ),
          child: completed
              ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: completed
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.textHint.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.pill,
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: completed ? AppColors.green : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStep(String number, String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed ? AppColors.teal : AppColors.textHint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStory(String name, String title, String quote) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_rounded,
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
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            quote,
            style: TextStyle(
              fontSize: 12,
              color: context.secondaryText,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12,
                color: context.secondaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
