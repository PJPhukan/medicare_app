import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class SecurityLoginScreen extends ConsumerStatefulWidget {
  const SecurityLoginScreen({super.key});

  @override
  ConsumerState<SecurityLoginScreen> createState() =>
      _SecurityLoginScreenState();
}

class _SecurityLoginScreenState extends ConsumerState<SecurityLoginScreen> {
  bool _fingerprintEnabled = true;
  bool _faceUnlockEnabled = false;
  bool _pinEnabled = false;
  final String _autoLockTime = '30 Seconds';

  void _save() {
    AppLogger.i('Security settings saved', tag: 'Settings');
    AppSnackbar.success(context, 'Security settings saved successfully');
  }

  void _signOutAll() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        title: AppText.h3('Sign Out From All Devices'),
        content: AppText.bodyMd(
          'This will sign you out from all devices. You\'ll need to log in again.',
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppLogger.i('Signed out from all devices', tag: 'Security');
              AppSnackbar.success(context, 'Signed out from all devices');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      ),
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
            AppSliverAppBar(
              config: AppBarConfig(
                title: 'Security & Login',
                leading: AppBarLeading.back,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () =>
                            AppSnackbar.info(context, 'Search coming soon'),
                        child: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.teal),
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
                      // ── Account Security Status ────────────────────────────
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        hasShadow: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.green
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.shield_rounded,
                                          size: 16,
                                          color: AppColors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Your account is\nsecure',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.pill,
                                          border: Border.all(
                                            color: AppColors.teal
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          'Biometric Enabled',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.teal,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.green
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.pill,
                                          border: Border.all(
                                            color: AppColors.green
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          'Strong Password',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.green,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.blue
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.pill,
                                          border: Border.all(
                                            color: AppColors.blue
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          '2 Devices Logged In',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.blue,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: 0.92,
                                        strokeWidth: 5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.teal,
                                        ),
                                        backgroundColor: AppColors.teal
                                            .withValues(alpha: 0.1),
                                      ),
                                      const Text(
                                        '92%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.teal,
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
                      const SizedBox(height: 28),

                      // ── Password Section ───────────────────────────────────
                      const Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Change Password',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Last changed 30 days ago',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
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
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Password Strength',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Your current password is very\nsecure',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.green.withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.pill,
                                      border: Border.all(
                                        color: AppColors.green
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'Strong',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Login Methods ──────────────────────────────────────
                      const Text(
                        'LOGIN METHODS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.fingerprint_rounded,
                                          size: 20,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Fingerprint',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: _fingerprintEnabled,
                                      onChanged: (val) =>
                                          setState(() =>
                                              _fingerprintEnabled = val),
                                      activeThumbColor: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.face_rounded,
                                          size: 20,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Face Unlock',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: _faceUnlockEnabled,
                                      onChanged: (val) =>
                                          setState(() =>
                                              _faceUnlockEnabled = val),
                                      activeThumbColor: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.dialpad_rounded,
                                          size: 20,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'PIN',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: _pinEnabled,
                                      onChanged: (val) =>
                                          setState(() => _pinEnabled = val),
                                      activeThumbColor: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Auto Lock After Inactivity',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _autoLockTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                    color: context.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Two-Factor Auth ────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TWO-FACTOR AUTH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHint,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(
                                color: AppColors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'Enabled',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Authenticator App',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Google Authenticator',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.green,
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.backup_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Recovery Codes',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '8 codes available',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Trusted Devices ───────────────────────────────────
                      const Text(
                        'TRUSTED DEVICES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.phone_android_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pixel 9 Pro',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'London, UK • Active now',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.green
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                AppBorderRadius.pill,
                                            border: Border.all(
                                              color: AppColors.green
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'Current',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.tablet_rounded,
                                          size: 20,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Galaxy Tab S10',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'London, UK • Active yesterday',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => AppSnackbar.info(
                                      context,
                                      'Device removed',
                                    ),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              AppBorderRadius.mdAll,
                                        ),
                                        child: const Icon(
                                          Icons.desktop_windows_rounded,
                                          size: 20,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Windows PC',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Unknown Location • 2 Days Ago',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => AppSnackbar.info(
                                      context,
                                      'Device removed',
                                    ),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Emergency Recovery ─────────────────────────────────
                      const Text(
                        'EMERGENCY RECOVERY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.mail_outline_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Recovery Email',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'j.adams@recovery.com',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: context.borderCol),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.mdAll,
                                    ),
                                    child: const Icon(
                                      Icons.phone_rounded,
                                      size: 20,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Phone Verification',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '+44 ••• •••892',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Action Buttons ────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Save Security Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _signOutAll,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign Out From All Devices'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.red.withValues(alpha: 0.5),
                            ),
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
}
