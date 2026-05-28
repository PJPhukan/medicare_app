import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import 'app_base_card.dart';

/// Card with a drop shadow — use for primary content surfaces.
///
/// ```dart
/// AppElevatedCard(
///   child: ProfileSummary(),
/// )
/// ```
class AppElevatedCard extends StatelessWidget {
  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
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
      borderColor: Colors.transparent,
      borderRadius: borderRadius ?? AppBorderRadius.lgAll,
      shadow: AppShadows.card,
      onTap: onTap,
      onLongPress: onLongPress,
      width: width,
      height: height,
      child: child,
    );
  }
}
