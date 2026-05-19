import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_base_button.dart';

/// No background, no border — coloured label/icon only.
///
/// Use for low-emphasis actions like "Skip", "Dismiss", or inline row actions.
///
/// ```dart
/// AppGhostButton(label: 'Skip', onPressed: _skip)
/// AppGhostButton(label: 'View all', trailingIcon: Icons.arrow_forward_ios_rounded, size: AppButtonSize.sm)
/// ```
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.color,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.isFullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;

  /// Text/icon colour. Defaults to [AppColors.teal].
  final Color? color;

  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return AppBaseButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      leadingWidget: leadingWidget,
      trailingWidget: trailingWidget,
      backgroundColor: Colors.transparent,
      foregroundColor: c,
      size: size,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      enabled: enabled,
      padding: padding,
      shadow: const [],
    );
  }
}
