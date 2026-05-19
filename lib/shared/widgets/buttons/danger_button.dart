import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'app_base_button.dart';

/// Destructive action button in red.
///
/// Two variants:
/// - `filled` (default) — solid red background, white text
/// - `outline` — transparent background, red border + red text
///
/// ```dart
/// AppDangerButton(label: 'Delete Account', onPressed: _delete)
/// AppDangerButton.outline(label: 'Remove', onPressed: _remove)
/// ```
class AppDangerButton extends StatelessWidget {
  const AppDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.isFullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
  }) : _outline = false;

  const AppDangerButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.isFullWidth = false,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
  }) : _outline = true;

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final bool _outline;

  @override
  Widget build(BuildContext context) {
    return AppBaseButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      backgroundColor:
          _outline ? Colors.transparent : AppColors.error,
      foregroundColor:
          _outline ? AppColors.error : Colors.white,
      borderColor: _outline ? AppColors.error : null,
      borderWidth: 1.5,
      size: size,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      enabled: enabled,
      padding: padding,
      shadow: _outline ? const [] : AppShadows.buttonDanger,
    );
  }
}
