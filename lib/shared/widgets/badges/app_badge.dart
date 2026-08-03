import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';

enum AppBadgeVariant { teal, blue, purple, amber, red, green, neutral }
enum AppBadgeSize { sm, md, lg }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.teal,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppBadgeSize.sm,
    this.dot = false,
    this.filled = false,
  });

  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final AppBadgeSize size;
  final bool dot;
  final bool filled;

  // Takes context because `neutral` is the one variant backed by a semantic
  // (theme-adapting) colour rather than a fixed brand one — teal/blue/etc.
  // are deliberately the same in both themes, but AppColors.textHint is the
  // dark-theme value and needs context.hintText to read correctly as this
  // badge's TEXT colour (not just a background tint) in light mode.
  static Color _color(BuildContext context, AppBadgeVariant v) => switch (v) {
    AppBadgeVariant.teal    => AppColors.teal,
    AppBadgeVariant.blue    => AppColors.blue,
    AppBadgeVariant.purple  => AppColors.purple,
    AppBadgeVariant.amber   => AppColors.amber,
    AppBadgeVariant.red     => AppColors.red,
    AppBadgeVariant.green   => AppColors.green,
    AppBadgeVariant.neutral => context.hintText,
  };

  EdgeInsets _getPadding() => switch (size) {
    AppBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    AppBadgeSize.md => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    AppBadgeSize.lg => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  };

  double _getFontSize() => switch (size) {
    AppBadgeSize.sm => 11,
    AppBadgeSize.md => 12,
    AppBadgeSize.lg => 13,
  };

  double _getIconSize() => switch (size) {
    AppBadgeSize.sm => 11,
    AppBadgeSize.md => 12,
    AppBadgeSize.lg => 14,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color(context, variant);
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();
    final padding = _getPadding();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: filled ? null : Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot)
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
            if (leadingIcon != null) ...[
              IconTheme(data: IconThemeData(size: iconSize, color: filled ? AppColors.textInverse : c), child: leadingIcon!),
              const SizedBox(width: 4),
            ],
            if (icon != null && leadingIcon == null) ...[
              IconTheme(data: IconThemeData(size: iconSize, color: filled ? AppColors.textInverse : c), child: icon!),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: filled ? AppColors.textInverse : c,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              IconTheme(data: IconThemeData(size: iconSize, color: filled ? AppColors.textInverse : c), child: trailingIcon!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Notification dot ─────────────────────────────────────────────────────────

class AppNotificationDot extends StatelessWidget {
  const AppNotificationDot({
    super.key,
    required this.child,
    this.count = 0,
    this.color,
    this.show = true,
  });

  final Widget child;
  final int count;
  final Color? color;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show && count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show || count > 0)
          Positioned(
            top: -4, right: -4,
            child: AnimatedScale(
              scale: (show || count > 0) ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color ?? AppColors.red,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: context.bg, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count > 0 ? '$count' : '',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
