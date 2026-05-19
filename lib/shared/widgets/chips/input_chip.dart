import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// A removable input chip for tag fields and multi-select inputs.
///
/// Displays a label with a colored × button. Tapping the × calls [onRemove].
///
/// Example:
///   AppInputChip(label: 'Hypertension', onRemove: () => removeTag('Hypertension'))
class AppInputChip extends StatelessWidget {
  const AppInputChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.color,
    this.leadingIcon,
    this.padding,
    this.fontSize,
  });

  final String label;
  final VoidCallback onRemove;

  /// Accent color. Defaults to [AppColors.teal].
  final Color? color;

  /// Optional leading icon shown before the label.
  final IconData? leadingIcon;

  /// Custom padding. Defaults to `EdgeInsets.only(left:12, right:6, top:5, bottom:5)`.
  final EdgeInsetsGeometry? padding;

  /// Override font size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;

    return Container(
      padding: padding ??
          const EdgeInsets.only(left: 12, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: c,
              letterSpacing: 0,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: c),
          ),
        ],
      ),
    );
  }
}
