import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../buttons/app_button.dart';

// ─── Empty state ──────────────────────────────────────────────────────────────

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // context.hintText: a raw Icon never adapts AppColors.textHint
            // (the dark-theme value), so every empty-state icon on this
            // widget — used across the medicine detail tabs, no-internet
            // states, etc. — rendered washed out in light mode.
            if (icon != null) Icon(icon, size: 48, color: context.hintText),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.labelLg.copyWith(color: context.primaryText),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTypography.bodySm.copyWith(color: context.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              AppButton(
                  variant: AppButtonVariant.outline,
                  label: actionLabel!,
                  onPressed: action),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.somethingWentWrong,
              style: AppTypography.labelLg.copyWith(color: context.primaryText),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  style: AppTypography.bodySm.copyWith(color: context.secondaryText),
                  textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                  variant: AppButtonVariant.primary,
                  label: AppStrings.retry,
                  onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── No internet state ────────────────────────────────────────────────────────

class AppNoInternetState extends StatelessWidget {
  const AppNoInternetState({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.wifi_off_rounded,
      title: AppStrings.noInternetConnection,
      subtitle: AppStrings.offlineDesc,
      action: onRetry,
      actionLabel: AppStrings.retry,
    );
  }
}
