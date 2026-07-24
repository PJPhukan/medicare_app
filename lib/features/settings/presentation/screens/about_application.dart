import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'About CareDose',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── App Icon ────────────────────────────────────────────
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.lgAll,
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.teal,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── App Name & Tagline ──────────────────────────────────
                  const Text(
                    'CareDose',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Healthcare. Simplified.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ── Version Badge ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'v2.1.0 Stable',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Stats ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '500K+',
                            label: 'Downloads',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '4.9',
                            label: 'Rating',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '120K',
                            label: 'Active Users',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── About Section ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('About'),
                        const SizedBox(height: 12),
                        Text(
                          'CareDose is a next-generation healthcare platform designed to bridge the gap between patients and precision medicine. We utilize advanced data analytics and biometric monitoring to provide a seamless health management experience that prioritizes user privacy and medical accuracy.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Information Section ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Information'),
                        const SizedBox(height: 12),
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                                onTap: () {},
                              ),
                              _buildInfoTile(
                                icon: Icons.description_outlined,
                                title: 'Terms of Service',
                                onTap: () {},
                              ),
                              _buildInfoTile(
                                icon: Icons.code_rounded,
                                title: 'Open Source Licenses',
                                onTap: () {},
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── What's New Section ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("What's New in v2.1.0"),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.sync_rounded,
                          title: 'Enhanced Biometric Sync',
                          description:
                              'Real-time synchronization with smart rings and high-performance wearables.',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.security_rounded,
                          title: 'Privacy Vault',
                          description:
                              'New end-to-end encrypted medical record storage and sharing protocols.',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.speed_rounded,
                          title: 'Performance Tuning',
                          description:
                              '40% faster dashboard load times and optimized battery consumption.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Community Section ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Community'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCommunityIcon(Icons.language_rounded, 'Website'),
                            const SizedBox(width: 32),
                            _buildCommunityIcon(Icons.favorite_rounded, 'Like'),
                            const SizedBox(width: 32),
                            _buildCommunityIcon(Icons.star_rounded, 'Rate'),
                            const SizedBox(width: 32),
                            _buildCommunityIcon(Icons.settings_rounded, 'Settings'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Developer Section ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.1),
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.teal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Developed by Alex Rivers',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Premium Member & Lead Architect',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mail_outline_rounded),
                            onPressed: () {},
                            color: AppColors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Action Buttons ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Rate CareDose',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: AppBorderRadius.mdAll,
                                border: Border.all(
                                  color: AppColors.teal,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.share_rounded,
                                    color: AppColors.teal,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Share',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.teal,
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
                  const SizedBox(height: 12),

                  // ── Check for Updates ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Check for Updates',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Copyright ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          '© 2024 CareDose Healthcare Systems Inc.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All Rights Reserved. Made with Clinical Precision.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.teal, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Divider(height: 1, color: const Color(0xFF333333)),
          ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.smAll,
            ),
            child: Icon(icon, color: AppColors.teal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Icon(icon, color: AppColors.teal, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
