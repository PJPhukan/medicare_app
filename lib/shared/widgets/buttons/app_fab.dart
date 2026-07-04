import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Floating action button — icon-only or extended (icon + label).
///
/// ```dart
/// AppFAB(icon: Icon(Icons.add), onPressed: _open)
/// AppFAB(icon: Icon(Icons.add), label: 'Add Dose', onPressed: _open)
/// ```
class AppFAB extends StatelessWidget {
  const AppFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.color,
  });

  final Widget       icon;
  final VoidCallback onPressed;

  /// Optional label — renders as extended FAB when provided.
  final String?      label;

  /// Background color — defaults to [AppColors.teal].
  final Color?       color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed:       onPressed,
        backgroundColor: c,
        foregroundColor: AppColors.textInverse,
        elevation:       0,
        icon:            icon,
        label: Text(
          label!,
          style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      );
    }
    return FloatingActionButton(
      onPressed:       onPressed,
      backgroundColor: c,
      foregroundColor: AppColors.textInverse,
      elevation:       0,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      child: icon,
    );
  }
}
