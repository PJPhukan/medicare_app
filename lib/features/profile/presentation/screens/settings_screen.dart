import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/screens/auth_flow.dart';
import '../../../shell/presentation/screens/app_shell.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../support/presentation/screens/support_screen.dart';

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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  // Language
  String _language = 'English';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.bodySm),
        backgroundColor: context.inputBg,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: Text(AppStrings.signOut, style: AppTypography.h3),
        content: Text(AppStrings.signOutConfirm,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel,
                style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => AuthFlow(
                    onAuthenticated: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AppShell()),
                    ),
                  ),
                ),
                (_) => false,
              );
            },
            child: Text(AppStrings.signOut,
                style: AppTypography.buttonMd.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: Text(AppStrings.deleteAccount,
            style: AppTypography.h3.copyWith(color: AppColors.red)),
        content: Text(AppStrings.deleteAccountConfirm,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel,
                style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.deleteAccount,
                style: AppTypography.buttonMd.copyWith(color: AppColors.red)),
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

  void _openPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(onUpgrade: () => _showSnack(AppStrings.comingSoon)),
    );
  }

  void _openExportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(
        onExport: (format) {
          Navigator.pop(context);
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
      builder: (_) => _AboutSheet(),
    );
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
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: Text(AppStrings.settings, style: AppTypography.h3),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Profile card ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'RK',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ramesh Kumar', style: AppTypography.labelLg),
                                  const SizedBox(height: 2),
                                  Text('ramesh.kumar@email.com', style: AppTypography.bodySm),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withValues(alpha: 0.12),
                                      borderRadius: AppBorderRadius.pill,
                                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(AppStrings.freePlan,
                                        style: AppTypography.labelXs.copyWith(color: AppColors.teal)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Tab bar ───────────────────────────────────────────────
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _Tab.values.map((t) {
                        final active = t == _activeTab;
                        return GestureDetector(
                          onTap: () => setState(() => _activeTab = t),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.teal : context.inputBg,
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(color: active ? AppColors.teal : context.borderCol),
                            ),
                            child: Text(
                              t.label,
                              style: AppTypography.labelSm.copyWith(
                                color: active ? context.bg : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

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
        _SettingsGroup(
          label: 'Personal',
          children: [
            _RowItem(
              icon: Icons.person_outline_rounded,
              label: AppStrings.editProfile,
              color: AppColors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            _RowItem(
              icon: Icons.medical_information_outlined,
              label: AppStrings.healthProfileTitle,
              color: AppColors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            _RowItem(
              icon: Icons.language_rounded,
              label: AppStrings.language,
              color: AppColors.purple,
              trailing: Text(_language,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textHint)),
              onTap: _openLanguagePicker,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsGroup(
          label: 'Subscription',
          children: [
            _RowItem(
              icon: Icons.workspace_premium_outlined,
              label: AppStrings.subscriptionPlan,
              color: AppColors.amber,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.pill,
                ),
                child: Text(AppStrings.freePlan,
                    style: AppTypography.labelXs.copyWith(color: AppColors.teal)),
              ),
              onTap: _openPlanSheet,
            ),
          ],
        ),
      ],
    );
  }

  // ── Notifications tab ────────────────────────────────────────────────────────

  Widget _buildNotifications() {
    return Column(
      children: [
        _SettingsGroup(
          label: 'Health Alerts',
          children: [
            _ToggleItem(
              icon: Icons.medication_outlined,
              label: AppStrings.medicineRemindersSetting,
              description: 'Remind me when it\'s time to take a dose',
              value: _medicineReminders,
              color: AppColors.teal,
              onChanged: (v) => setState(() => _medicineReminders = v),
            ),
            _ToggleItem(
              icon: Icons.favorite_outline_rounded,
              label: AppStrings.vitalAlerts,
              description: 'Notify me of abnormal vital readings',
              value: _vitalAlerts,
              color: AppColors.red,
              onChanged: (v) => setState(() => _vitalAlerts = v),
            ),
            _ToggleItem(
              icon: Icons.calendar_today_rounded,
              label: 'Appointment Reminders',
              description: 'Remind me 1 hour before appointments',
              value: _appointmentAlerts,
              color: AppColors.blue,
              onChanged: (v) => setState(() => _appointmentAlerts = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsGroup(
          label: 'Social',
          children: [
            _ToggleItem(
              icon: Icons.people_outline_rounded,
              label: AppStrings.connectionAlerts,
              description: 'Connection requests and messages',
              value: _connectionAlerts,
              color: AppColors.purple,
              onChanged: (v) => setState(() => _connectionAlerts = v),
            ),
            _ToggleItem(
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

  // ── Appearance tab ───────────────────────────────────────────────────────────

  Widget _buildAppearance() {
    return _SettingsGroup(
      label: 'Display',
      children: [
        _ToggleItem(
          icon: Icons.dark_mode_outlined,
          label: AppStrings.darkMode,
          description: 'Use dark background throughout the app',
          value: _darkMode,
          color: AppColors.purple,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
        _ToggleItem(
          icon: Icons.view_compact_outlined,
          label: 'Compact Mode',
          description: 'Reduce spacing for more content on screen',
          value: _compactMode,
          color: AppColors.blue,
          onChanged: (v) => setState(() => _compactMode = v),
        ),
        _ToggleItem(
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
    return Column(
      children: [
        _SettingsGroup(
          label: 'Authentication',
          children: [
            _ToggleItem(
              icon: Icons.fingerprint_rounded,
              label: AppStrings.biometricAuth,
              description: AppStrings.biometricDesc,
              value: _biometricAuth,
              color: AppColors.teal,
              onChanged: (v) => setState(() => _biometricAuth = v),
            ),
            _ToggleItem(
              icon: Icons.lock_outline_rounded,
              label: AppStrings.autoLock,
              description: 'Lock app when inactive',
              value: _autoLock,
              color: AppColors.blue,
              onChanged: (v) => setState(() => _autoLock = v),
            ),
            if (_autoLock)
              _RowItem(
                icon: Icons.timer_outlined,
                label: AppStrings.autoLockDuration,
                color: AppColors.amber,
                trailing: Text(_autoLockDuration,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textHint)),
                onTap: _openAutoLockPicker,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsGroup(
          label: 'Data',
          children: [
            _RowItem(
              icon: Icons.download_outlined,
              label: AppStrings.dataExport,
              color: AppColors.green,
              onTap: _openExportSheet,
            ),
            _RowItem(
              icon: Icons.cleaning_services_outlined,
              label: AppStrings.clearCache,
              color: AppColors.amber,
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
        _SettingsGroup(
          label: 'Support',
          children: [
            _RowItem(
              icon: Icons.help_outline_rounded,
              label: AppStrings.helpCenter,
              color: AppColors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              ),
            ),
            _RowItem(
              icon: Icons.info_outline_rounded,
              label: AppStrings.aboutApp,
              color: AppColors.textSecondary,
              trailing: Text('v1.0.0',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textHint)),
              onTap: _openAbout,
            ),
          ],
        ),
        SizedBox(height: 12),

        // Sign out button
        GestureDetector(
          onTap: _confirmSignOut,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(AppStrings.signOut,
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Delete account button
        GestureDetector(
          onTap: _confirmDeleteAccount,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_forever_outlined, size: 18, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.deleteAccount,
                          style: AppTypography.labelMd.copyWith(color: AppColors.red)),
                      const SizedBox(height: 2),
                      Text(AppStrings.deleteAccountDesc, style: AppTypography.bodyXs),
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

// ─── Settings group (card container) ─────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;
  _SettingsGroup({required this.children, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!.toUpperCase(),
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Container(height: 1, margin: EdgeInsets.only(left: 46), color: context.borderCol),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Row item ─────────────────────────────────────────────────────────────────

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;
  final VoidCallback onTap;

  const _RowItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.smAll,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodyMd)),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle item ──────────────────────────────────────────────────────────────

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.smAll,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyMd),
                if (description != null)
                  Text(description!, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.bg,
            activeTrackColor: AppColors.teal,
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: context.borderCol,
          ),
        ],
      ),
    );
  }
}

// ─── Language sheet ───────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  _LanguageSheet({required this.selected, required this.onSelect});

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
          Text(AppStrings.selectLanguage, style: AppTypography.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 16),
          ..._kLanguages.map((lang) {
            final isSel = selected == lang.label;
            final isAvail = lang.available;
            return GestureDetector(
              onTap: isAvail
                  ? () {
                      Navigator.pop(context);
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
                            Text(lang.label,
                                style: AppTypography.bodyMd.copyWith(
                                  color: isSel ? AppColors.teal : context.primaryText,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                )),
                            Text(lang.native,
                                style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
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
                          child: Text('Soon',
                              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
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

// ─── Plan sheet ───────────────────────────────────────────────────────────────

class _PlanSheet extends StatelessWidget {
  final VoidCallback onUpgrade;
  _PlanSheet({required this.onUpgrade});

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
          Text(AppStrings.choosePlan, style: AppTypography.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(AppStrings.planSubtitle,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Free plan card (current)
          _PlanCard(
            name: AppStrings.planBasicName,
            badge: AppStrings.planFreeBadge,
            price: AppStrings.planFreePrice,
            badgeColor: AppColors.teal,
            features: [AppStrings.planBasicFeature1, AppStrings.planBasicFeature2, AppStrings.planBasicFeature3],
            isCurrent: true,
            onTap: null,
          ),
          const SizedBox(height: 10),

          // Premium plan card
          _PlanCard(
            name: AppStrings.planPremiumName,
            badge: AppStrings.planPremiumBadge,
            price: '${AppStrings.planPremiumPrice} ${AppStrings.planPeriodMonth}',
            badgeColor: AppColors.amber,
            features: [
              AppStrings.planPremiumFeature1,
              AppStrings.planPremiumFeature2,
              AppStrings.planPremiumFeature3,
              AppStrings.planPremiumFeature4,
              AppStrings.planPremiumFeature5,
            ],
            isCurrent: false,
            onTap: () {
              Navigator.pop(context);
              onUpgrade();
            },
          ),
          const SizedBox(height: 8),
          Text(AppStrings.noCreditCard,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String badge;
  final String price;
  final Color badgeColor;
  final List<String> features;
  final bool isCurrent;
  final VoidCallback? onTap;

  _PlanCard({
    required this.name,
    required this.badge,
    required this.price,
    required this.badgeColor,
    required this.features,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent ? context.inputBg : badgeColor.withValues(alpha: 0.06),
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: isCurrent ? context.borderCol : badgeColor.withValues(alpha: 0.4),
            width: isCurrent ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: AppTypography.labelLg.copyWith(color: context.primaryText)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.pill,
                  ),
                  child: Text(badge,
                      style: AppTypography.labelXs.copyWith(color: badgeColor, fontWeight: FontWeight.w800)),
                ),
                const Spacer(),
                Text(price,
                    style: AppTypography.labelMd.copyWith(
                      color: isCurrent ? AppColors.textHint : badgeColor,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_rounded, size: 14,
                          color: isCurrent ? AppColors.textHint : badgeColor),
                      SizedBox(width: 8),
                      Text(f, style: AppTypography.bodyXs.copyWith(
                          color: isCurrent ? AppColors.textSecondary : context.primaryText)),
                    ],
                  ),
                )),
            if (!isCurrent) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: AppBorderRadius.mdAll,
                ),
                alignment: Alignment.center,
                child: Text(AppStrings.upgradeNow,
                    style: AppTypography.buttonMd.copyWith(color: context.bg)),
              ),
            ],
            if (isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 14),
                    const SizedBox(width: 6),
                    Text(AppStrings.currentPlan,
                        style: AppTypography.labelSm.copyWith(color: AppColors.teal, fontSize: 11)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Export sheet ─────────────────────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  final void Function(String format) onExport;
  _ExportSheet({required this.onExport});

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
          Text(AppStrings.exportConfirmTitle, style: AppTypography.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 8),
          Text(AppStrings.exportConfirmDesc,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5)),
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
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(color: context.borderCol),
              ),
              child: Text(AppStrings.cancel,
                  style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
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
              Expanded(child: Text(label, style: AppTypography.bodyMd.copyWith(color: context.primaryText))),
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

  _PickerSheet({
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
          Text(title, style: AppTypography.h3.copyWith(fontSize: 17)),
          SizedBox(height: 16),
          ...options.map((opt) {
            final isSel = opt == selected;
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
                      child: Text(opt,
                          style: AppTypography.bodyMd.copyWith(
                            color: isSel ? AppColors.teal : context.primaryText,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          )),
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
  _AboutSheet();

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
          Text('MediForze', style: AppTypography.h2.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text('Your Personal Health Companion',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.pill,
            ),
            child: Text('Version 1.0.0 (Build 42)',
                style: AppTypography.labelSm.copyWith(color: AppColors.textHint, fontSize: 11)),
          ),
          const SizedBox(height: 24),
          _AboutInfoRow(label: 'Developer', value: 'Hopes Technologies'),
          _AboutInfoRow(label: 'Contact', value: 'support@mediforze.com'),
          _AboutInfoRow(label: AppStrings.privacyPolicy, value: 'View Policy →'),
          _AboutInfoRow(label: AppStrings.termsOfService, value: 'View Terms →'),
          const SizedBox(height: 20),
          Text('© 2026 MediForze. All rights reserved.',
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
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
            Expanded(child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
            Text(value, style: AppTypography.bodySm.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
