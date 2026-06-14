import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// A selectable category chip with an optional leading icon.
///
/// Used in feedback sheets, create-post screens, community category filters,
/// and anywhere a category/topic needs to be chosen from a set.
///
/// Selected state: soft [color] tinted background + [color] border + [color] label.
/// Unselected state: input-bg background + subtle border + secondary label.
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
    this.padding,
    this.solidSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional leading icon.
  final IconData? icon;

  /// Accent color. Defaults to [AppColors.teal].
  final Color? color;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:12, vertical:7)`.
  final EdgeInsetsGeometry? padding;

  /// When true, the selected state is a solid [color] fill with white content
  /// and the unselected state is a soft [color] tint with [color] content
  /// (matches the filter-popup chip palette). Works in light and dark mode.
  final bool solidSelected;

  @override
  Widget build(BuildContext context) {
    final c      = color ?? AppColors.teal;

    final bg = solidSelected
        ? (selected ? c : c.withValues(alpha: 0.12))
        : (selected ? c.withValues(alpha: 0.12) : context.inputBg);

    final borderColor = solidSelected
        ? (selected ? c : c.withValues(alpha: 0.45))
        : (selected ? c.withValues(alpha: 0.4) : context.borderCol);

    final contentColor = solidSelected
        ? (selected ? Colors.white : c)
        : (selected ? c : AppColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: contentColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.labelXs.copyWith(
                color: contentColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
