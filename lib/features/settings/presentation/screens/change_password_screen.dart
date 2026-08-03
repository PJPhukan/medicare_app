import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/client.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late TextEditingController _currentPasswordCtrl;
  late TextEditingController _newPasswordCtrl;
  late TextEditingController _confirmPasswordCtrl;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordCtrl = TextEditingController();
    _newPasswordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordCtrl.text.length >= 8;
  bool get _hasNumber => _newPasswordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar =>
      _newPasswordCtrl.text.contains(RegExp(r'[!@#$%&*]'));
  bool get _passwordsMatch =>
      _newPasswordCtrl.text == _confirmPasswordCtrl.text &&
      _newPasswordCtrl.text.isNotEmpty;

  bool get _allRequirementsMet =>
      _hasMinLength && _hasNumber && _hasSpecialChar && _passwordsMatch;

  Future<void> _updatePassword() async {
    if (!_allRequirementsMet) {
      AppSnackbar.error(context, 'Please meet all password requirements');
      return;
    }

    if (_currentPasswordCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Current password is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/auth/change-password',
        data: {
          'currentPassword': _currentPasswordCtrl.text,
          'newPassword': _newPasswordCtrl.text,
        },
      );

      AppLogger.i('Password updated successfully', tag: 'Security');
      if (!mounted) return;
      AppSnackbar.success(context, 'Password updated successfully');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) context.pop();
      });
    } on Exception catch (e) {
      AppLogger.e('Password update failed', tag: 'Security', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = 'Failed to update password. Try again.';
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map<String, dynamic> && resData['message'] is String) {
          msg = resData['message'] as String;
        }
      }
      AppSnackbar.error(context, msg);
    }
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
                title: 'Change Password',
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
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header Section ────────────────────────────────────
                      const Text(
                        'Secure Your Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose a strong, unique password to ensure your sensitive medical data remains private and protected.',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.secondaryText,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Password Fields ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Column(
                          children: [
                            _buildPasswordField(
                              label: 'Current Password',
                              controller: _currentPasswordCtrl,
                              isVisible: _showCurrentPassword,
                              onVisibilityToggle: () => setState(
                                () => _showCurrentPassword =
                                    !_showCurrentPassword,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              label: 'New Password',
                              controller: _newPasswordCtrl,
                              isVisible: _showNewPassword,
                              onVisibilityToggle: () => setState(
                                () => _showNewPassword = !_showNewPassword,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              label: 'Confirm New Password',
                              controller: _confirmPasswordCtrl,
                              isVisible: _showConfirmPassword,
                              onVisibilityToggle: () => setState(
                                () => _showConfirmPassword =
                                    !_showConfirmPassword,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Password Requirements ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password Requirements',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildRequirementItem(
                              'At least 8 characters',
                              _hasMinLength,
                            ),
                            const SizedBox(height: 10),
                            _buildRequirementItem(
                              'Contains at least one number',
                              _hasNumber,
                            ),
                            const SizedBox(height: 10),
                            _buildRequirementItem(
                              'One special character (!@#\$% &*)',
                              _hasSpecialChar,
                            ),
                            const SizedBox(height: 10),
                            _buildRequirementItem(
                              'Passwords must match',
                              _passwordsMatch,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Info Section ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.08),
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.info_outlined,
                                  size: 14,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Avoid using common words or personal information like birth dates. Use a password manager for better security.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.secondaryText,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Action Buttons ────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _updatePassword,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.lock_rounded, size: 18),
                          label: Text(
                            _isLoading ? 'Updating...' : 'Update Password',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            disabledBackgroundColor:
                                AppColors.teal.withValues(alpha: 0.5),
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
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.borderCol,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.primaryText,
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            obscureText: !isVisible,
            style: TextStyle(
              fontSize: 14,
              color: context.primaryText,
            ),
            decoration: InputDecoration(
              hintText: label,
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
              suffixIcon: GestureDetector(
                onTap: onVisibilityToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isMet
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.textHint.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 12,
              color: isMet ? AppColors.green : AppColors.textHint,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? context.primaryText : AppColors.textHint,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
