import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// A display tag chip — static or optionally removable.
///
/// Used for report tags, document labels, allergy/condition tags,
/// profile attributes, and any non-filter label display.
///
/// Pass [onRemove] to make the chip removable (shows an × button).
class AppTagChip extends StatelessWidget {
  const AppTagChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.onRemove,
    this.padding,
    this.fontSize,
  });

  final String label;

  /// Tag accent color. Defaults to [AppColors.teal].
  final Color? color;

  /// Optional leading icon.
  final IconData? icon;

  /// When provided, an × button is shown and tapping it calls [onRemove].
  final VoidCallback? onRemove;

  /// Custom padding. Auto-adjusts right padding when removable.
  final EdgeInsetsGeometry? padding;

  /// Override font size. Defaults to AppTypography.labelXs font size.
  final double? fontSize;

  bool get _removable => onRemove != null;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;

    return Container(
      padding: padding ??
          EdgeInsets.only(
            left: 10,
            right: _removable ? 6 : 10,
            top: 5,
            bottom: 5,
          ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelXs.copyWith(
              color: c,
              letterSpacing: 0,
              fontSize: fontSize,
            ),
          ),
          if (_removable) ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 12, color: c),
            ),
          ],
        ],
      ),
    );
  }
}
