import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Floating action button — standard (icon only) or extended (icon + label).
///
/// ```dart
/// AppFabButton(icon: Icons.add, onPressed: _add)
/// AppFabButton.extended(icon: Icons.add, label: 'Add Medication', onPressed: _add)
/// AppFabButton(icon: Icons.add, mini: true)
/// ```
class AppFabButton extends StatelessWidget {
  const AppFabButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.color,
    this.foregroundColor,
    this.mini = false,
    this.gradient,
    this.shadow,
    this.heroTag,
  }) : _extended = false;

  const AppFabButton.extended({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.color,
    this.foregroundColor,
    this.mini = false,
    this.gradient,
    this.shadow,
    this.heroTag,
  }) : _extended = true;

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? color;
  final Color? foregroundColor;
  final bool mini;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;
  final Object? heroTag;
  final bool _extended;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.teal;
    final fg = foregroundColor ?? Colors.white;

    if (_extended && label != null) {
      return FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        icon: Icon(icon),
        label: Text(
          label!,
          style: AppTypography.buttonMd.copyWith(color: fg),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      );
    }

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: bg,
      foregroundColor: fg,
      mini: mini,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      child: Icon(icon),
    );
  }
}
