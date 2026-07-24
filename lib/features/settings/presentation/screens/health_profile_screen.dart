import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';

class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
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
                title: 'Health Profile',
                leading: AppBarLeading.back,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, size: 22),
                    onPressed: () => AppSnackbar.info(context, 'Search coming soon'),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PERSONAL INFO SECTION
                      _buildSectionHeader('PERSONAL INFO', Icons.person_outline_rounded),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          children: [
                            _buildInfoRow('Blood Group', 'O Positive'),
                            Divider(height: 1, color: context.borderCol),
                            _buildInfoRow('Height', '178 cm'),
                            Divider(height: 1, color: context.borderCol),
                            _buildInfoRow('Weight', '74 kg'),
                            Divider(height: 1, color: context.borderCol),
                            _buildInfoRow('Age', '29 yrs'),
                            Divider(height: 1, color: context.borderCol),
                            _buildInfoRowWithBadge('BMI', '23.4', 'NORMAL'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // MEDICAL INFO SECTION
                      _buildSectionHeader('MEDICAL INFO', Icons.favorite_outline_rounded),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubSection('ALLERGIES', 'Peanuts, Penicillin, Pollen'),
                            const SizedBox(height: 20),
                            _buildSubSection('CURRENT MEDICATION', 'Vitamin D3 Supplement (Weekly), Cetirizine\n10mg (As needed)'),
                            const SizedBox(height: 20),
                            _buildSubSection('CHRONIC DISEASES', 'None'),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => AppSnackbar.info(context, 'Coming soon'),
                                icon: const Icon(Icons.expand_more_rounded, size: 18),
                                label: const Text('View Past Surgeries & Notes'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdAll),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // LIFESTYLE SECTION
                      _buildSectionHeader('LIFESTYLE', Icons.self_improvement_outlined),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildLifestyleChip('Non-smoker', Icons.smoke_free_rounded),
                            _buildLifestyleChip('Occasional Alcohol', Icons.local_bar_outlined),
                            _buildLifestyleChip('3x Week', Icons.fitness_center_rounded),
                            _buildLifestyleChip('7-8 Hours', Icons.bedtime_outlined),
                            _buildLifestyleChip('2.5L Daily', Icons.water_drop_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // EMERGENCY CONTACT SECTION
                      _buildSectionHeader('EMERGENCY CONTACT', Icons.phone_in_talk_outlined),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                              ),
                                child: const Icon(Icons.person_outlined, color: AppColors.teal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sarah Williams', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    AppText.bodyXs('Spouse • +1 234-567-890', color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.call_rounded, color: AppColors.teal, size: 20),
                                onPressed: () => AppSnackbar.info(context, 'Call coming soon'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // HEALTH GOALS SECTION
                      _buildSectionHeader('HEALTH GOALS', Icons.favorite_rounded),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0, bottom: 12, top: 8),
                          child: TextButton(
                            onPressed: () => AppSnackbar.info(context, 'Coming soon'),
                            child: const Text('MONTHLY PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 0.5)),
                          ),
                        ),
                      ),
                      AppCard(
                        child: Column(
                          children: [
                            // Overall progress circle
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 0.75,
                                          strokeWidth: 8,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                                          backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('75%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.teal)),
                                            AppText.bodyXs('OVERALL', color: AppColors.textSecondary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Progress items
                                  _buildProgressItem('WATER', '80%'),
                                  const SizedBox(height: 16),
                                  _buildProgressItem('STEPS', '62%'),
                                  const SizedBox(height: 16),
                                  _buildProgressItem('ADHERENCE', '95%'),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText.bodyXs('Weight Goal', color: AppColors.textSecondary),
                                        const SizedBox(height: 4),
                                        const Text('70.0 kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText.bodyXs('Daily Water', color: AppColors.textSecondary),
                                        const SizedBox(height: 4),
                                        const Text('3.0 Liters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // UPDATE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => AppSnackbar.info(context, 'Coming soon'),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Update Health Profile'),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: Icon(icon, size: 14, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithBadge(String label, String value, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.pill,
            ),
            child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyXs(title, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
      ],
    );
  }

  Widget _buildLifestyleChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: AppColors.textSecondary)),
            Text(percentage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppBorderRadius.pill,
          child: LinearProgressIndicator(
            value: double.parse(percentage.replaceAll('%', '')) / 100,
            minHeight: 6,
            backgroundColor: AppColors.teal.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
          ),
        ),
      ],
    );
  }
}
