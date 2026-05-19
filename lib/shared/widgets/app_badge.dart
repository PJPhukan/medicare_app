import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';

enum AppBadgeVariant { teal, blue, purple, amber, red, green, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.teal,
    this.icon,
    this.dot = false,
    this.filled = false,
  });

  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;
  final bool dot;
  final bool filled;

  static Color _color(AppBadgeVariant v) => switch (v) {
    AppBadgeVariant.teal    => AppColors.teal,
    AppBadgeVariant.blue    => AppColors.blue,
    AppBadgeVariant.purple  => AppColors.purple,
    AppBadgeVariant.amber   => AppColors.amber,
    AppBadgeVariant.red     => AppColors.red,
    AppBadgeVariant.green   => AppColors.green,
    AppBadgeVariant.neutral => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color(variant);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: filled ? null : Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot)
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
            if (icon != null) ...[
              IconTheme(data: IconThemeData(size: 11, color: filled ? AppColors.textInverse : c), child: icon!),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: filled ? AppColors.textInverse : c,
              ),
            ),
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
                  border: Border.all(color: AppColors.dark800, width: 1.5),
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
