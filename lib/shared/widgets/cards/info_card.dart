import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_base_card.dart';

// ─── Info card style ──────────────────────────────────────────────────────────

enum AppInfoCardStyle { outline, glass, elevated }

// ─── Info card ────────────────────────────────────────────────────────────────

/// Card with a leading icon + title + subtitle and an optional trailing action.
///
/// ```dart
/// AppInfoCard(
///   icon: Icons.info_rounded,
///   title: 'Medication reminder',
///   subtitle: 'Take 2 tablets after meals.',
///   color: AppColors.teal,
///   action: AppGhostButton(label: 'Dismiss', onPressed: _dismiss),
/// )
/// ```
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconWidget,
    this.color,
    this.action,
    this.style = AppInfoCardStyle.outline,
    this.onTap,
    this.margin,
    this.padding,
  });

  final String title;
  final String? subtitle;

  /// Leading icon. Use [iconWidget] instead to pass a custom widget.
  final IconData? icon;
  final Widget? iconWidget;

  /// Accent colour for the icon badge. Defaults to [AppColors.teal].
  final Color? color;

  /// Optional widget rendered below the subtitle (e.g. a button).
  final Widget? action;

  final AppInfoCardStyle style;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c      = color ?? AppColors.teal;

    final (bgColor, borderColor) = switch (style) {
      AppInfoCardStyle.glass    => (
          c.withValues(alpha: 0.07),
          c.withValues(alpha: 0.18),
        ),
      AppInfoCardStyle.elevated => (
          context.cardBg,
          Colors.transparent,
        ),
      AppInfoCardStyle.outline  => (
          context.cardBg,
          context.borderCol,
        ),
    };

    final shadow = style == AppInfoCardStyle.elevated
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[];

    return AppBaseCard(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(14),
      color: bgColor,
      borderColor: borderColor,
      shadow: shadow,
      borderRadius: AppBorderRadius.lgAll,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          if (icon != null || iconWidget != null) ...[
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.mdAll,
              ),
              child: iconWidget ??
                  Icon(icon, size: 18, color: c),
            ),
            const SizedBox(width: 12),
          ],

          // Text + action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(color: context.primaryText),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: 10),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
