import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_base_card.dart';

/// Tinted glass-effect card — use for accent/highlighted surfaces.
///
/// Background and border are derived from [color] with reduced opacity.
///
/// ```dart
/// AppGlassCard(
///   color: AppColors.teal,
///   child: AlertBanner(),
/// )
/// ```
class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.backgroundOpacity = 0.08,
    this.borderOpacity = 0.20,
  });

  final Widget child;

  /// Accent colour. Defaults to [AppColors.teal].
  final Color? color;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  /// Background tint opacity (0–1). Default 0.08.
  final double backgroundOpacity;

  /// Border opacity (0–1). Default 0.20.
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return AppBaseCard(
      padding: padding,
      margin: margin,
      color: c.withValues(alpha: backgroundOpacity),
      borderColor: c.withValues(alpha: borderOpacity),
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      shadow: const [],
      onTap: onTap,
      onLongPress: onLongPress,
      width: width,
      height: height,
      child: child,
    );
  }
}
