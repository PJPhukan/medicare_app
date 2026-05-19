import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import 'animated_tap.dart';

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.height,
    this.width,
    this.showBorder = true,
  });

  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final gradColors = colors ?? [AppColors.teal, AppColors.blue];
    final br = borderRadius ?? AppBorderRadius.xlAll;

    Widget card = Container(
      width: width,
      height: height,
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

    if (onTap != null) {
      return AnimatedTap(onTap: onTap, borderRadius: br, child: card);
    }
    return card;
  }
}

// ─── Glass card ───────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final br = borderRadius ?? AppBorderRadius.xlAll;

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: br,
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return AnimatedTap(onTap: onTap, borderRadius: br, child: card);
    }
    return card;
  }
}
