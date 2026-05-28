import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import 'app_base_card.dart';

/// Bordered card with no shadow — use for secondary or list-item surfaces.
///
/// ```dart
/// AppOutlineCard(
///   child: AppointmentRow(),
/// )
/// ```
class AppOutlineCard extends StatelessWidget {
  const AppOutlineCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      padding: padding,
      margin: margin,
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
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
