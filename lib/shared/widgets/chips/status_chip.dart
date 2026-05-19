import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

enum AppStatusChipStyle {
  /// Colored filled circle dot + label. E.g. "● Active".
  dot,

  /// IconData leading widget + label. E.g. "⚠ Low Stock".
  icon,

  /// Label only, no leading decoration. E.g. "PRN".
  plain,
}

/// A status badge chip with soft colored background.
///
/// Used for medicine status (Active / Low Stock / PRN),
/// dose status (Taken / Skipped / Missed / Pending),
/// request status (Pending / Declined), etc.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.style = AppStatusChipStyle.plain,
    this.icon,
    this.padding,
    this.fontSize,
    this.showBorder = false,
  });

  final String label;
  final Color color;

  /// Visual style of the leading decoration.
  final AppStatusChipStyle style;

  /// Required when [style] is [AppStatusChipStyle.icon].
  final IconData? icon;

  /// Custom padding. Defaults to `EdgeInsets.symmetric(horizontal:8, vertical:4)`.
  final EdgeInsetsGeometry? padding;

  /// Override font size. Defaults to AppTypography.labelXs font size.
  final double? fontSize;

  /// When true, adds a subtle colored border around the chip.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    Widget? leading;

    switch (style) {
      case AppStatusChipStyle.dot:
        leading = Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case AppStatusChipStyle.icon:
        if (icon != null) {
          leading = Icon(icon, size: 11, color: color);
        }
      case AppStatusChipStyle.plain:
        break;
    }

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
        border: showBorder
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.labelXs.copyWith(
              color: color,
              letterSpacing: 0.3,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
