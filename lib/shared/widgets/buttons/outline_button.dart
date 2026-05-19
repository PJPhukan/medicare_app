import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_base_button.dart';

/// Transparent background button with a coloured border.
///
/// ```dart
/// AppOutlineButton(label: 'Learn More', onPressed: _open)
/// AppOutlineButton(label: 'Export', leadingIcon: Icons.upload_rounded, color: AppColors.blue)
/// ```
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
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
    this.borderWidth = 1.5,
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

  /// Border and text colour. Defaults to [AppColors.teal].
  final Color? color;

  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final double borderWidth;
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
      borderColor: c,
      borderWidth: borderWidth,
      size: size,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      enabled: enabled,
      padding: padding,
    );
  }
}
