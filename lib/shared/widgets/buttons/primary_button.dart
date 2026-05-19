import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'app_base_button.dart';

/// Solid filled button — the primary call-to-action.
///
/// ```dart
/// AppPrimaryButton(label: 'Save', onPressed: _save)
/// AppPrimaryButton(label: 'Add Medication', leadingIcon: Icons.add, isFullWidth: true)
/// ```
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.color,
    this.foregroundColor,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.isFullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
    this.shadow,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;

  /// Accent colour. Defaults to [AppColors.teal].
  final Color? color;

  /// Text/icon colour. Defaults to [AppColors.textInverse] (dark on light bg).
  final Color? foregroundColor;

  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.teal;
    return AppBaseButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      leadingWidget: leadingWidget,
      trailingWidget: trailingWidget,
      backgroundColor: bg,
      foregroundColor: foregroundColor ?? AppColors.textInverse,
      size: size,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      enabled: enabled,
      padding: padding,
      shadow: shadow ?? AppShadows.button,
    );
  }
}
