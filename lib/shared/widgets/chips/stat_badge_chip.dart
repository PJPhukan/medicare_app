import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// A compact trend / stat badge chip used in dashboard stat cards.
///
/// Examples:
///   AppStatBadgeChip(label: '12% vs last week', color: AppColors.green,  icon: Icons.arrow_upward_rounded)
///   AppStatBadgeChip(label: 'Appointments',      color: AppColors.purple)
///   AppStatBadgeChip(label: 'View details',      color: AppColors.amber)
///
/// Uses [Flexible] on the label so it ellipsizes gracefully inside tight
/// grid columns without overflowing.
class AppStatBadgeChip extends StatelessWidget {
  const AppStatBadgeChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.padding,
    this.fontSize,
  });

  final String label;
  final Color color;

  /// Optional leading icon (e.g. up/down arrow for trends).
  final IconData? icon;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:7, vertical:4)`.
  final EdgeInsetsGeometry? padding;

  /// Override font size. Defaults to 9.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelXs.copyWith(
                color: color,
                fontSize: fontSize ?? 9,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
