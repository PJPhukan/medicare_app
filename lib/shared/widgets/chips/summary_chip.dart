import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// A soft-colored summary pill for displaying counts or state summaries.
///
/// Examples:
///   AppSummaryChip(label: '✓ 2 Taken',   color: AppColors.green)
///   AppSummaryChip(label: '⏳ 3 Pending', color: AppColors.amber)
///   AppSummaryChip(label: '✕ 1 Skipped', color: AppColors.error)
///
/// Optionally pass an [icon] to render a leading IconData instead of
/// embedding the symbol in [label].
class AppSummaryChip extends StatelessWidget {
  const AppSummaryChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.padding,
    this.fontSize,
  });

  final String label;
  final Color color;

  /// Optional leading icon rendered before the label.
  final IconData? icon;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:10, vertical:5)`.
  final EdgeInsetsGeometry? padding;

  /// Override font size. Defaults to AppTypography.labelXs font size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
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
