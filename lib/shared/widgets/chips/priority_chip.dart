import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A fixed priority indicator chip: High / Medium / Low / Critical.
///
/// ```dart
/// AppPriorityChip(priority: AppPriority.high)
/// AppPriorityChip(priority: AppPriority.critical, showIcon: false)
/// ```
class AppPriorityChip extends StatelessWidget {
  const AppPriorityChip({
    super.key,
    required this.priority,
    this.showIcon = true,
    this.padding,
    this.fontSize,
  });

  final AppPriority priority;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (priority) {
      AppPriority.critical => ('Critical', AppColors.error,   Icons.warning_rounded),
      AppPriority.high     => ('High',     AppColors.red,     Icons.arrow_upward_rounded),
      AppPriority.medium   => ('Medium',   AppColors.amber,   Icons.remove_rounded),
      AppPriority.low      => ('Low',      AppColors.success, Icons.arrow_downward_rounded),
    };

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelXs.copyWith(
              color: color,
              letterSpacing: 0,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppPriority { critical, high, medium, low }
