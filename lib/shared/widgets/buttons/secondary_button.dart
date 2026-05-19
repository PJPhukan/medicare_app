import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_base_button.dart';

/// Muted filled button used for secondary actions alongside a primary CTA.
///
/// Adapts its background to the current theme (dark: dark700, light: light200).
///
/// ```dart
/// AppSecondaryButton(label: 'Cancel', onPressed: Navigator.of(context).pop)
/// ```
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
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
  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBaseButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      leadingWidget: leadingWidget,
      trailingWidget: trailingWidget,
      backgroundColor: isDark ? AppColors.dark700 : AppColors.light200,
      foregroundColor: context.primaryText,
      size: size,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      enabled: enabled,
      padding: padding,
    );
  }
}
