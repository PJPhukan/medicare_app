import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class SignOutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const SignOutDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      title: AppText.h3(AppStrings.signOut),
      content: AppText.bodyMd(AppStrings.signOutConfirm, color: AppColors.textSecondary),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            AppStrings.cancel,
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
            AppLogger.i('Sign-out confirmed', tag: 'Settings');
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            AppStrings.signOut,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppColors.red,
            ),
          ),
        ),
      ],
    );
  }
}
