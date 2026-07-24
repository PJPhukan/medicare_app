import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

enum AppSnackbarType { success, error, warning, info }

abstract class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final (Color color, IconData icon) = switch (type) {
      AppSnackbarType.success => (AppColors.green, Icons.check_circle_rounded),
      AppSnackbarType.error   => (AppColors.error,  Icons.error_rounded),
      AppSnackbarType.warning => (AppColors.amber,  Icons.warning_amber_rounded),
      AppSnackbarType.info    => (AppColors.blue,   Icons.info_rounded),
    };

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        content: DecoratedBox(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(message,
                      style: AppTypography.bodyMd
                          .copyWith(color: context.primaryText)),
                ),
                if (actionLabel != null && onAction != null)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onAction();
                    },
                    child: Text(
                      actionLabel,
                      style: AppTypography.labelSm.copyWith(color: color),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.info);
}
