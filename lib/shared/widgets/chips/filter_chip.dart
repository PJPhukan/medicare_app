import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// A selectable filter chip.
///
/// [outlined] = false (default):
///   selected  → [color] filled background, white label
///   unselected → transparent bg, soft border, secondary label
///
/// [outlined] = true:
///   selected  → soft [color] tinted bg + [color] border, [color] label
///   unselected → transparent bg, soft border, secondary label
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.leadingIcon,
    this.outlined = false,
    this.padding,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Accent color. Defaults to [AppColors.teal].
  final Color? color;

  /// Optional icon shown to the left of the label.
  final IconData? leadingIcon;

  /// When true the chip uses a tinted-outline style instead of solid fill.
  final bool outlined;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:14, vertical:8)`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c      = color ?? AppColors.teal;

    final bgColor = selected
        ? (outlined ? c.withValues(alpha: 0.12) : c)
        : Colors.transparent;

    final borderColor = selected
        ? (outlined ? c : c)
        : (isDark ? context.borderCol : const Color(0xFFE2E8F0));

    final labelColor = selected
        ? (outlined ? c : Colors.white)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 13, color: labelColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: labelColor,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
