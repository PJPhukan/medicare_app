import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'app_base_button.dart';

/// Gradient-filled button — attention-grabbing hero CTA.
///
/// Defaults to the teal→blue brand gradient.
/// Pass [colors] to use any custom gradient stop list.
///
/// ```dart
/// AppGradientButton(label: 'Get Started', onPressed: _start)
/// AppGradientButton(
///   label: 'Upgrade',
///   colors: [AppColors.purple, AppColors.pink],
///   leadingIcon: Icons.star_rounded,
/// )
/// ```
class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
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

  /// Gradient stops. Defaults to [AppColors.teal, AppColors.blue].
  final List<Color>? colors;

  final Alignment begin;
  final Alignment end;
  final AppButtonSize size;
  final BorderRadius? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final stops = colors ?? [AppColors.teal, AppColors.blue];
    return AppBaseButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      leadingWidget: leadingWidget,
      trailingWidget: trailingWidget,
      foregroundColor: Colors.white,
      gradient: LinearGradient(colors: stops, begin: begin, end: end),
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
