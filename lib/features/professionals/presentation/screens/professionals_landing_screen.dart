import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';

class ProfessionalsLandingScreen extends ConsumerStatefulWidget {
  const ProfessionalsLandingScreen({super.key});

  @override
  ConsumerState<ProfessionalsLandingScreen> createState() =>
      _ProfessionalsLandingScreenState();
}

class _ProfessionalsLandingScreenState
    extends ConsumerState<ProfessionalsLandingScreen> {
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
                title: 'Healthcare Professionals',
                leading: AppBarLeading.back,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header Section ────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'CAREDOSE PROFESSIONALS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connect with Expert Healthcare Professionals',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get personalized consultations from verified doctors, nurses, therapists, and healthcare specialists on India\'s most trusted platform.',
                        style: TextStyle(fontSize: 14, color: context.secondaryText, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // ── Hero Image ────────────────────────────────────────
                      Container(
                        height: 220,
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
                          border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.people_alt_rounded,
                            size: 80,
                            color: AppColors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Why Choose Section ────────────────────────────────
                      const Text(
                        'Why Choose Our Professionals',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        icon: Icons.verified_rounded,
                        title: 'Verified & Certified',
                        description: 'All professionals are verified medical experts',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.star_rounded,
                        title: 'Highly Rated',
                        description: 'Average 4.8+ rating from thousands of patients',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.schedule_rounded,
                        title: 'Flexible Scheduling',
                        description: 'Book appointments at your convenience',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.security_rounded,
                        title: 'Secure & Private',
                        description: 'End-to-end encrypted consultations',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.speed_rounded,
                        title: 'Instant Access',
                        description: 'Connect with professionals within minutes',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.payment_rounded,
                        title: 'Affordable Rates',
                        description: 'Transparent pricing with no hidden charges',
                      ),
                      const SizedBox(height: 28),

                      // ── Professional Categories ────────────────────────────
                      const Text(
                        'Available Specialties',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildCategoryChip('General Practitioners', AppColors.teal),
                          _buildCategoryChip('Cardiologists', AppColors.red),
                          _buildCategoryChip('Dermatologists', AppColors.blue),
                          _buildCategoryChip('Pediatricians', AppColors.green),
                          _buildCategoryChip('Psychologists', AppColors.purple),
                          _buildCategoryChip('Therapists', AppColors.amber),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Statistics Section ────────────────────────────────
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('5000+', 'Professionals'),
                                _buildStatItem('100K+', 'Happy Patients'),
                                _buildStatItem('50K+', 'Consultations'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── How It Works ───────────────────────────────────────
                      const Text(
                        'How It Works',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildStep('1', 'Search & Browse', 'Find professionals by specialty and location'),
                      const SizedBox(height: 12),
                      _buildStep('2', 'Check Profiles', 'Review qualifications, experience, and ratings'),
                      const SizedBox(height: 12),
                      _buildStep('3', 'Book Appointment', 'Schedule at a time that works for you'),
                      const SizedBox(height: 12),
                      _buildStep('4', 'Get Consultation', 'Video, audio, or text consultation'),
                      const SizedBox(height: 28),

                      // ── Testimonials ───────────────────────────────────────
                      const Text(
                        'Patient Testimonials',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person_rounded, color: AppColors.teal),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Rajesh Kumar',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '"Excellent experience! The doctor was very knowledgeable and took time to understand my concerns. Highly recommended!"',
                              style: TextStyle(fontSize: 12, color: context.secondaryText, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Browse Professionals Button ────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.search_rounded, size: 18),
                          label: const Text('Browse Professionals'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdAll),
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

  Widget _buildBenefitItem({
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
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: context.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.secondaryText),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.teal,
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: context.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
