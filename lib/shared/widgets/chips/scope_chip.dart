import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// A sharing / ownership scope badge.
///
/// Used to indicate whether a medicine, record, or item is personally owned,
/// shared with others, or managed by a caretaker.
///
/// Examples:
///   AppScopeChip(label: 'Shared',   color: AppColors.teal,   icon: Icons.share_rounded)
///   AppScopeChip(label: 'Caretaker',color: AppColors.blue,   icon: Icons.person_add_rounded)
///   AppScopeChip(label: 'Assigned', color: AppColors.purple, icon: Icons.assignment_ind_rounded)
class AppScopeChip extends StatelessWidget {
  const AppScopeChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.padding,
    this.fontSize,
  });

  final String label;
  final Color color;

  /// Optional leading icon.
  final IconData? icon;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:7, vertical:4)`.
  final EdgeInsetsGeometry? padding;

  /// Override font size.
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
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelXs.copyWith(
              color: color,
              letterSpacing: 0.2,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
