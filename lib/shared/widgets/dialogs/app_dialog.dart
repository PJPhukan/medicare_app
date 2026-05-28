import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../buttons/app_button.dart';

// ─── Base dialog ─────────────────────────────────────────────────────────────

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
  });

  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.xxlAll),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.teal).withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.lgAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, color: iconColor ?? AppColors.teal, size: 24),
                  ),
                ),
              ),
            if (title != null) ...[
              Text(title!, style: AppTypography.h3),
              const SizedBox(height: 8),
            ],
            content,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: actions!
                    .map((a) => Expanded(child: a))
                    .toList()
                    .expand((w) => [w, const SizedBox(width: 12)])
                    .toList()
                  ..removeLast(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Confirm dialog helper ─────────────────────────────────────────────────

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        icon: isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
        iconColor: isDanger ? AppColors.error : AppColors.amber,
        title: title,
        content: Text(message, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          AppButton.secondary(
            label: cancelLabel ?? AppStrings.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          isDanger
              ? AppButton.danger(
                  label: confirmLabel ?? AppStrings.confirm,
                  onPressed: () => Navigator.of(context).pop(true),
                )
              : AppButton.primary(
                  label: confirmLabel ?? AppStrings.confirm,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
        ],
      ),
    );
  }

  // ─── Alert dialog helper ───────────────────────────────────────────────────

  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String? okLabel,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AppDialog(
        icon: icon ?? Icons.info_outline_rounded,
        iconColor: iconColor ?? AppColors.blue,
        title: title,
        content: Text(message, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          AppButton.primary(
            label: okLabel ?? AppStrings.ok,
            onPressed: () => Navigator.of(context).pop(),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
