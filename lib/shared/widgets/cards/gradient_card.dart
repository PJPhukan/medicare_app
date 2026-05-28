import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../utils/animated_tap.dart';

/// Card with a linear gradient background.
///
/// Text and icons inside should use light colours since the background is
/// typically vivid.
///
/// ```dart
/// AppGradientCard(
///   colors: [AppColors.teal, AppColors.blue],
///   child: HealthScoreBanner(),
/// )
/// ```
class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showBorder = false,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
  });

  final Widget child;

  /// Gradient stops. Defaults to teal → blue.
  final List<Color>? colors;

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  /// Adds a subtle border derived from the first gradient colour.
  final bool showBorder;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final gradColors = colors ?? [AppColors.teal, AppColors.blue];
    final br = borderRadius ?? AppBorderRadius.lgAll;

    Widget card = Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradColors, begin: begin, end: end),
        borderRadius: br,
        border: showBorder
            ? Border.all(color: gradColors.first.withValues(alpha: 0.3))
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    if (margin != null) card = Padding(padding: margin!, child: card);

    if (onTap != null || onLongPress != null) {
      return AnimatedTap(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: br,
        child: card,
      );
    }
    return card;
  }
}
