import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart' hide AppShell;
import '../../../../core/utils/logger.dart';
import '../../../professional_profile/presentation/providers/pro_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

// ─── Tab definitions ──────────────────────────────────────────────────────────

enum _Tab { profile, notifications, appearance, security, account }

extension _TabLabel on _Tab {
  String get label => switch (this) {
        _Tab.profile       => AppStrings.profile,
        _Tab.notifications => AppStrings.notifications,
        _Tab.appearance    => AppStrings.appearance,
        _Tab.security      => AppStrings.security,
        _Tab.account       => AppStrings.account,
      };
}

// ─── Language data ────────────────────────────────────────────────────────────

const _kLanguages = [
  (code: 'en', label: 'English', native: 'English', available: true),
  (code: 'hi', label: 'Hindi', native: 'हिन्दी', available: false),
  (code: 'bn', label: 'Bengali', native: 'বাংলা', available: false),
  (code: 'ta', label: 'Tamil', native: 'தமிழ்', available: false),
  (code: 'te', label: 'Telugu', native: 'తెలుగు', available: false),
  (code: 'mr', label: 'Marathi', native: 'मराठी', available: false),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _Tab _activeTab = _Tab.profile;

  // Notification toggles
  bool _medicineReminders = true;
  bool _vitalAlerts = true;
  bool _connectionAlerts = false;
  bool _appointmentAlerts = true;
  bool _systemUpdates = false;

  // Appearance
  bool _darkMode = true;
  bool _compactMode = false;
  bool _showSeconds = false;

  // Security
  bool _biometricAuth = false;
  bool _autoLock = true;
  String _autoLockDuration = '5 minutes';

  // Device info
  final String _deviceName = 'My iPhone 15 Pro';
  final String _lastLogin = 'Today at 2:30 PM';

  // Language
  String _language = 'English';

  void _showSnack(String msg) => AppSnackbar.info(context, msg);

  void _confirmSignOut() {
    AppLogger.i('Sign-out dialog opened', tag: 'Settings');
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: AppText.h3(AppStrings.signOut),
        content: AppText.bodyMd(AppStrings.signOutConfirm, color: AppColors.textSecondary),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text(AppStrings.cancel,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              AppLogger.i('Sign-out confirmed', tag: 'Settings');
              ctx.pop();
              // logout() clears token + calls API; router redirect handles navigation
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(AppStrings.signOut,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    AppLogger.i('Delete account dialog opened', tag: 'Settings');
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: AppText.h3(AppStrings.deleteAccount, color: AppColors.red),
        content: AppText.bodyMd(AppStrings.deleteAccountConfirm, color: AppColors.textSecondary),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text(AppStrings.cancel,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(AppStrings.deleteAccount,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _openLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        selected: _language,
        onSelect: (lang) {
          setState(() => _language = lang);
          _showSnack(AppStrings.languageSaved);
        },
      ),
    );
  }

  void _openPlanSheet() => context.push(AppRoutes.settingsPremium);

  void _openExportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(
        onExport: (format) {
          context.pop();
          _showSnack(AppStrings.exportStarted);
        },
      ),
    );
  }

  void _openAutoLockPicker() {
    final options = ['1 minute', '5 minutes', '15 minutes', '30 minutes', '1 hour'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: AppStrings.autoLockDuration,
        options: options,
        selected: _autoLockDuration,
        onSelect: (v) => setState(() => _autoLockDuration = v),
      ),
    );
  }

  void _openAbout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AboutSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final isVerifiedPro = ref.watch(proProfileProvider.select((s) => s.profile?.isVerified ?? false));
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: AppText.h3(AppStrings.settings),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Profile card with enhanced design ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.profile),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AppAvatar(
                              name: displayName,
                              imageUrl: user?.avatarUrl,
                              isVerified: isVerifiedPro,
                              size: AppAvatarSize.lg,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  AppText.bodySm(email, color: AppColors.textSecondary),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.teal.withValues(alpha: 0.15),
                                          AppColors.teal.withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: AppBorderRadius.pill,
                                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                                    ),
                                    child: const Text(AppStrings.freePlan,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.teal)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.inputBg,
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tab bar with smooth animations ────────────────────────
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _Tab.values.map((t) {
                        final active = t == _activeTab;
                        return GestureDetector(
                          onTap: () => setState(() => _activeTab = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? AppColors.teal : context.inputBg,
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(
                                color: active ? AppColors.teal : context.borderCol,
                                width: active ? 1.5 : 1,
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: AppColors.teal.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                                letterSpacing: 0.3,
                                color: active ? context.bg : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tab content ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() => switch (_activeTab) {
        _Tab.profile       => _buildProfile(),
        _Tab.notifications => _buildNotifications(),
        _Tab.appearance    => _buildAppearance(),
        _Tab.security      => _buildSecurity(),
        _Tab.account       => _buildAccount(),
      };

  // ── Profile tab ─────────────────────────────────────────────────────────────

  Widget _buildProfile() {
    return Column(
      children: [
        // Account status card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.teal.withValues(alpha: 0.08),
                AppColors.teal.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: const Icon(Icons.verified_user_rounded, size: 20, color: AppColors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Verified', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    AppText.bodySm('Your account is verified and secure', color: AppColors.textSecondary),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, size: 24, color: AppColors.green),
            ],
          ),
        ),
        const SizedBox(height: 16),

        AppListSection(
          header: 'Personal',
          items: [
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.teal.withValues(alpha: 0.15), AppColors.teal.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.teal),
              ),
              title: AppStrings.editProfile,
              showChevron: true,
              onTap: () => context.push(AppRoutes.profile),
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blue.withValues(alpha: 0.15), AppColors.blue.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.medical_information_outlined, size: 18, color: AppColors.blue),
              ),
              title: AppStrings.healthProfileTitle,
              showChevron: true,
              onTap: () => context.push(AppRoutes.profile),
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.purple.withValues(alpha: 0.15), AppColors.purple.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.language_rounded, size: 18, color: AppColors.purple),
              ),
              title: AppStrings.language,
              trailing: AppText.bodySm(_language, color: AppColors.textHint),
              onTap: _openLanguagePicker,
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppListSection(
          header: 'Subscription',
          items: [
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.amber.withValues(alpha: 0.15), AppColors.amber.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.amber),
              ),
              title: AppStrings.subscriptionPlan,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.teal.withValues(alpha: 0.15), AppColors.teal.withValues(alpha: 0.1)]),
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                ),
                child: const Text(AppStrings.freePlan,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.teal)),
              ),
              onTap: _openPlanSheet,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Professional Profile ──────────────────────────────────────────────
        _buildProfessionalSection(),
      ],
    );
  }

  // ── Professional profile section ─────────────────────────────────────────────

  Widget _buildProfessionalSection() {
    final proState = ref.watch(proProfileProvider);
    final profile = proState.profile;
    final notApplied = proState.notFound || (profile == null && !proState.isLoading);

    // Loading shimmer-ish placeholder
    if (proState.isLoading && profile == null && !proState.notFound) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('PROFESSIONAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.textHint)),
          ),
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: const Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
              ),
            ),
          ),
        ],
      );
    }

    // ── Not applied: motivating call-to-action ──────────────────────────────────
    if (notApplied) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('PROFESSIONAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.textHint)),
          ),
          GestureDetector(
            onTap: _openBecomePro,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.teal.withValues(alpha: 0.16),
                    AppColors.blue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.teal, AppColors.blue],
                          ),
                          borderRadius: AppBorderRadius.mdAll,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Become a Professional',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            AppText.bodySm('Offer your services & earn on your terms',
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Benefit chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _BenefitChip(icon: Icons.payments_rounded, label: 'Set your own rates'),
                      _BenefitChip(icon: Icons.people_alt_rounded, label: 'Reach more patients'),
                      _BenefitChip(icon: Icons.verified_rounded, label: 'Verified badge'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.teal, AppColors.blue],
                      ),
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Get Started',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ── Has profile: verified or pending ────────────────────────────────────────
    final isVerified = profile!.isVerified;
    final statusColor = isVerified ? AppColors.green : AppColors.amber;
    final statusLabel = isVerified ? 'Verified' : 'Pending';
    final statusIcon = isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded;
    final subtitle = isVerified
        ? (profile.categoryLabel ?? 'Verified professional')
        : 'Verification in progress';

    return AppListSection(
      header: 'Professional',
      items: [
        AppListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.08)],
              ),
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: statusColor.withValues(alpha: 0.15)),
            ),
            child: Icon(statusIcon, size: 18, color: statusColor),
          ),
          title: AppStrings.professionalProfile,
          subtitle: subtitle,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.pill,
            ),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: statusColor)),
          ),
          onTap: _openProHub,
        ),
      ],
    );
  }

  void _openBecomePro() => context.push(AppRoutes.settingsPro);

  void _openProHub() => context.push(AppRoutes.settingsProHub);

  // ── Notifications tab ────────────────────────────────────────────────────────

  Widget _buildNotifications() {
    return Column(
      children: [
        AppListSection(
          header: 'Health Alerts',
          dividerIndent: 56,
          items: [
            _buildToggleListTile(
              icon: Icons.medication_outlined,
              label: AppStrings.medicineRemindersSetting,
              description: 'Remind me when it\'s time to take a dose',
              value: _medicineReminders,
              color: AppColors.teal,
              onChanged: (v) => setState(() => _medicineReminders = v),
            ),
            _buildToggleListTile(
              icon: Icons.favorite_outline_rounded,
              label: AppStrings.vitalAlerts,
              description: 'Notify me of abnormal vital readings',
              value: _vitalAlerts,
              color: AppColors.red,
              onChanged: (v) => setState(() => _vitalAlerts = v),
            ),
            _buildToggleListTile(
              icon: Icons.calendar_today_rounded,
              label: 'Appointment Reminders',
              description: 'Remind me 1 hour before appointments',
              value: _appointmentAlerts,
              color: AppColors.blue,
              onChanged: (v) => setState(() => _appointmentAlerts = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppListSection(
          header: 'Social',
          dividerIndent: 56,
          items: [
            _buildToggleListTile(
              icon: Icons.people_outline_rounded,
              label: AppStrings.connectionAlerts,
              description: 'Connection requests and messages',
              value: _connectionAlerts,
              color: AppColors.purple,
              onChanged: (v) => setState(() => _connectionAlerts = v),
            ),
            _buildToggleListTile(
              icon: Icons.campaign_outlined,
              label: 'System Updates',
              description: 'App updates and announcements',
              value: _systemUpdates,
              color: AppColors.textHint,
              onChanged: (v) => setState(() => _systemUpdates = v),
            ),
          ],
        ),
      ],
    );
  }

  AppListTile _buildToggleListTile({
    required IconData icon,
    required String label,
    required String? description,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
          ),
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: label,
      subtitle: description,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: context.bg,
        activeTrackColor: color,
        inactiveThumbColor: AppColors.textHint,
        inactiveTrackColor: context.borderCol,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  // ── Appearance tab ───────────────────────────────────────────────────────────

  Widget _buildAppearance() {
    return AppListSection(
      header: 'Display',
      dividerIndent: 56,
      items: [
        _buildToggleListTile(
          icon: Icons.dark_mode_outlined,
          label: AppStrings.darkMode,
          description: 'Use dark background throughout the app',
          value: _darkMode,
          color: AppColors.purple,
          onChanged: (v) {
            AppLogger.i('Dark mode → $v', tag: 'Settings');
            setState(() => _darkMode = v);
          },
        ),
        _buildToggleListTile(
          icon: Icons.view_compact_outlined,
          label: 'Compact Mode',
          description: 'Reduce spacing for more content on screen',
          value: _compactMode,
          color: AppColors.blue,
          onChanged: (v) => setState(() => _compactMode = v),
        ),
        _buildToggleListTile(
          icon: Icons.timer_outlined,
          label: 'Show Seconds',
          description: 'Show seconds in time displays',
          value: _showSeconds,
          color: AppColors.green,
          onChanged: (v) => setState(() => _showSeconds = v),
        ),
      ],
    );
  }

  // ── Security tab ─────────────────────────────────────────────────────────────

  Widget _buildSecurity() {
    final authItems = [
      _buildToggleListTile(
        icon: Icons.fingerprint_rounded,
        label: AppStrings.biometricAuth,
        description: AppStrings.biometricDesc,
        value: _biometricAuth,
        color: AppColors.teal,
        onChanged: (v) {
          AppLogger.i('Biometric auth setting → $v', tag: 'Settings');
          setState(() => _biometricAuth = v);
        },
      ),
      _buildToggleListTile(
        icon: Icons.lock_outline_rounded,
        label: AppStrings.autoLock,
        description: 'Lock app when inactive',
        value: _autoLock,
        color: AppColors.blue,
        onChanged: (v) => setState(() => _autoLock = v),
      ),
    ];

    return Column(
      children: [
        AppListSection(
          header: 'Authentication',
          dividerIndent: 56,
          items: authItems,
        ),
        if (_autoLock) ...[
          const SizedBox(height: 12),
          AppListSection(
            items: [
              AppListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.amber.withValues(alpha: 0.15), AppColors.amber.withValues(alpha: 0.08)],
                    ),
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.timer_outlined, size: 18, color: AppColors.amber),
                ),
                title: AppStrings.autoLockDuration,
                trailing: AppText.bodySm(_autoLockDuration, color: AppColors.textHint),
                onTap: _openAutoLockPicker,
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        AppListSection(
          header: 'Data',
          items: [
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.green.withValues(alpha: 0.15), AppColors.green.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.download_outlined, size: 18, color: AppColors.green),
              ),
              title: AppStrings.dataExport,
              showChevron: true,
              onTap: _openExportSheet,
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.amber.withValues(alpha: 0.15), AppColors.amber.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.cleaning_services_outlined, size: 18, color: AppColors.amber),
              ),
              title: AppStrings.clearCache,
              showChevron: true,
              onTap: () => _showSnack(AppStrings.cacheCleared),
            ),
          ],
        ),
      ],
    );
  }

  // ── Account tab ──────────────────────────────────────────────────────────────

  Widget _buildAccount() {
    return Column(
      children: [
        // Session & Device section
        AppListSection(
          header: 'Session & Device',
          items: [
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.green.withValues(alpha: 0.15), AppColors.green.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.smartphone_rounded, size: 18, color: AppColors.green),
              ),
              title: _deviceName,
              subtitle: 'Current device',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.pill,
                ),
                child: const Text('Active',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.green)),
              ),
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blue.withValues(alpha: 0.15), AppColors.blue.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.history_rounded, size: 18, color: AppColors.blue),
              ),
              title: 'Last Login',
              subtitle: _lastLogin,
            ),
          ],
        ),
        const SizedBox(height: 16),

        AppListSection(
          header: 'Support',
          items: [
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blue.withValues(alpha: 0.15), AppColors.blue.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.blue),
              ),
              title: AppStrings.helpCenter,
              showChevron: true,
              onTap: () => context.push(AppRoutes.support),
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.purple.withValues(alpha: 0.15), AppColors.purple.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.feedback_outlined, size: 18, color: AppColors.purple),
              ),
              title: 'Send Feedback',
              subtitle: 'Help us improve the app',
              showChevron: true,
              onTap: () => _showSnack('Thank you for your feedback!'),
            ),
            AppListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.textSecondary.withValues(alpha: 0.15), AppColors.textSecondary.withValues(alpha: 0.08)],
                  ),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
              ),
              title: AppStrings.aboutApp,
              trailing: AppText.bodySm('v1.0.0', color: AppColors.textHint),
              onTap: _openAbout,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sign out button
        GestureDetector(
          onTap: _confirmSignOut,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.textSecondary.withValues(alpha: 0.1), AppColors.textSecondary.withValues(alpha: 0.05)],
                    ),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                AppText.labelMd(AppStrings.signOut, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Delete account button
        GestureDetector(
          onTap: _confirmDeleteAccount,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: const Icon(Icons.delete_forever_outlined, size: 18, color: AppColors.red),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.labelMd(AppStrings.deleteAccount, color: AppColors.red),
                      const SizedBox(height: 2),
                      AppText.bodyXs(AppStrings.deleteAccountDesc, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// ─── Language sheet ───────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _LanguageSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          const Text(AppStrings.selectLanguage, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ..._kLanguages.map((lang) {
            final isSel = selected == lang.label;
            final isAvail = lang.available;
            return GestureDetector(
              onTap: isAvail
                  ? () {
                      context.pop();
                      onSelect(lang.label);
                    }
                  : null,
              child: Opacity(
                opacity: isAvail ? 1.0 : 0.45,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.teal.withValues(alpha: 0.1) : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(
                      color: isSel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.bodyMd(lang.label,
                                color: isSel ? AppColors.teal : context.primaryText,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                            AppText.bodyXs(lang.native, color: AppColors.textHint),
                          ],
                        ),
                      ),
                      if (!isAvail)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.borderCol,
                            borderRadius: AppBorderRadius.pill,
                          ),
                          child: const Text('Soon',
                              style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                        ),
                      if (isSel) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Export sheet ─────────────────────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  final void Function(String format) onExport;
  const _ExportSheet({required this.onExport});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          const Text(AppStrings.exportConfirmTitle, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(AppStrings.exportConfirmDesc,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          _ExportOption(
            icon: Icons.picture_as_pdf_rounded,
            label: AppStrings.exportAsPdf,
            color: AppColors.red,
            onTap: () => onExport('pdf'),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.code_rounded,
            label: AppStrings.exportAsJson,
            color: AppColors.blue,
            onTap: () => onExport('json'),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: const Text(AppStrings.cancel,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(child: AppText.bodyMd(label, color: context.primaryText)),
              Icon(Icons.download_rounded, color: color, size: 18),
            ],
          ),
        ),
      );
}

// ─── Auto-lock picker sheet ───────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final void Function(String) onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          ...options.map((opt) {
            final isSel = opt == selected;
            return GestureDetector(
              onTap: () {
                context.pop();
                onSelect(opt);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.teal.withValues(alpha: 0.1) : context.inputBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: isSel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText.bodyMd(opt,
                          color: isSel ? AppColors.teal : context.primaryText,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500),
                    ),
                    if (isSel) const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── About sheet ──────────────────────────────────────────────────────────────

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.lgAll,
            ),
            child: const Icon(Icons.medical_services_rounded, color: AppColors.teal, size: 34),
          ),
          const SizedBox(height: 14),
          const Text('MediForze', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          AppText.bodySm('Your Personal Health Companion', color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.pill,
            ),
            child: const Text('Version 1.0.0 (Build 42)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.textHint)),
          ),
          const SizedBox(height: 24),
          _AboutInfoRow(label: 'Developer', value: 'Hopes Technologies'),
          _AboutInfoRow(label: 'Contact', value: 'support@mediforze.com'),
          _AboutInfoRow(label: AppStrings.privacyPolicy, value: 'View Policy →'),
          _AboutInfoRow(label: AppStrings.termsOfService, value: 'View Terms →'),
          const SizedBox(height: 20),
          AppText.bodyXs('© 2026 MediForze. All rights reserved.', color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _AboutInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: AppText.bodySm(label, color: AppColors.textSecondary)),
            AppText.bodySm(value, color: context.primaryText, fontWeight: FontWeight.w600),
          ],
        ),
      );
}

// ─── Benefit chip (Become-a-Pro CTA) ─────────────────────────────────────────

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BenefitChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.6),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.teal),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ],
      ),
    );
  }
}
