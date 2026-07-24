import 'package:app_medicare/shared/widgets/texts/section_header_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart' hide AppShell;
import '../../../professionals/presentation/providers/pro_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import 'about_application.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String _language = 'English (India)';
  late Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: 18, color: AppColors.teal),
    );
  }

  Widget _buildProfileCard(
    String displayName,
    String email,
    String? imageUrl,
    bool isVerifiedPro,
  ) {
    return AppCard(
      onTap: () => context.push(AppRoutes.settingsEdit),
      hasShadow: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: displayName,
                imageUrl: imageUrl,
                isVerified: isVerifiedPro,
                size: AppAvatarSize.lg,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMd(displayName, fontWeight: FontWeight.w800),
                    const SizedBox(height: 2),
                    AppText.bodySm(email, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isVerifiedPro)
                          const AppBadge(
                            label: 'Verified',
                            variant: AppBadgeVariant.green,
                            leadingIcon: Icon(Icons.verified_rounded),
                          ),
                        if (isVerifiedPro)
                          const SizedBox(width: 8),
                        const AppBadge(
                          label: 'Biometric Enabled',
                          variant: AppBadgeVariant.teal,
                          size: AppBadgeSize.md,
                          leadingIcon: Icon(Icons.fingerprint_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<AppListTile> items,
  }) {
    return Column(
      children: [
        AppSectionHeaderText(
          title: title,
          accentColor: AppColors.teal,
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.md,
          ),
        ),
        AppListSection(items: items),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final isVerifiedPro = ref.watch(
        proProfileProvider.select((s) => s.profile?.isVerified ?? false));
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: AppStrings.settings,
                subtitle: AppStrings.settingsSubtitle,
              ),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildProfileCard(displayName, email, user?.avatarUrl, isVerifiedPro),
                    _buildSettingsSection(
                      title: AppStrings.accountTitle,
                      items: [
                        AppListTile(
                          leading: _buildIconContainer(Icons.person_outline_rounded),
                          title: AppStrings.editProfile,
                          showChevron: true,
                          onTap: () => context.push(AppRoutes.settingsEdit),
                        ),
                        AppListTile(
                          leading: _buildIconContainer(Icons.favorite_outline_rounded),
                          title: AppStrings.healthProfile,
                          showChevron: true,
                          onTap: () => context.push(AppRoutes.healthProfile),
                        ),
                        AppListTile(
                          leading: _buildIconContainer(Icons.workspace_premium_outlined),
                          title: AppStrings.subscription,
                          trailing: const AppBadge(
                            label: 'PRO',
                            variant: AppBadgeVariant.teal,
                            size: AppBadgeSize.md,
                          ),
                          showChevron: true,
                          onTap: () => context.push(AppRoutes.settingsPremium),
                        ),
                        if (!isVerifiedPro)
                          AppListTile(
                            leading: _buildIconContainer(Icons.workspace_premium_outlined),
                            title: AppStrings.becomeProfessional,
                            showChevron: true,
                            onTap: () => context.push(AppRoutes.settingsPro),
                          ),
                      ],
                    ),
                    _buildSettingsSection(
                      title: AppStrings.preferencesTitle,
                      items: [
                        AppListTile(
                          leading: _buildIconContainer(Icons.palette_outlined),
                          title: AppStrings.appearance,
                          showChevron: true,
                          onTap: () => context.push(AppRoutes.settingsAppearance),
                        ),
                        AppListTile(
                          leading: _buildIconContainer(Icons.language_rounded),
                          title: AppStrings.language,
                          subtitle: _language,
                          showChevron: true,
                          onTap: () =>
                              context.push(AppRoutes.settingsLanguageRegion),
                        ),
                        AppListTile(
                          leading: _buildIconContainer(Icons.notifications_outlined),
                          title: AppStrings.reminderNotifications,
                          showChevron: true,
                          onTap: () =>
                              context.push(AppRoutes.notificationSettings),
                        ),
                      ],
                    ),
                    _buildSettingsSection(
                      title: AppStrings.securityTitle,
                      items: [
                        AppListTile(
                          leading: _buildIconContainer(Icons.lock_outline_rounded),
                          title: AppStrings.passwordLogin,
                          showChevron: true,
                          onTap: () =>
                              context.push(AppRoutes.settingsSecurityLogin),
                        )
                      ],
                    ),
                    _buildSettingsSection(
                      title: AppStrings.supportTitle,
                      items: [
                        AppListTile(
                          leading: _buildIconContainer(Icons.help_outline_rounded),
                          title: AppStrings.helpCenter,
                          showChevron: true,
                          onTap: () => context.push(AppRoutes.support),
                        ),
                        AppListTile(
                          leading: _buildIconContainer(Icons.info_outline_rounded),
                          title: AppStrings.aboutCareDose,
                          showChevron: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: FutureBuilder<PackageInfo>(
                        future: _packageInfo,
                        builder: (context, snapshot) {
                          final version = snapshot.data?.version ?? '?.?.?';
                          return AppText.bodySm(
                            'v$version',
                            color: AppColors.textSecondary,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom +
                          AppSpacing.x5l,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
