import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../utils/animated_tap.dart';

// ─── Base card ────────────────────────────────────────────────────────────────

/// Fully-configurable card shell used by every card widget.
///
/// Prefer the named subclasses ([AppElevatedCard], [AppOutlineCard], etc.)
/// for common patterns. Use [AppBaseCard] when you need full control.
///
/// ```dart
/// AppBaseCard(
///   onTap: _onTap,
///   child: MyContent(),
/// )
/// ```
class AppBaseCard extends StatelessWidget {
  const AppBaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Card background. Defaults to adaptive surface colour.
  final Color? color;

  /// Border colour. Pass [Colors.transparent] to remove border.
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;

  /// Box shadows. Pass an empty list `[]` to remove all shadow.
  final List<BoxShadow>? shadow;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bg        = color ?? context.cardBg;
    final border    = borderColor ?? context.borderCol;
    final br        = borderRadius ?? AppBorderRadius.lgAll;

    Widget card = Container(
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: br,
        border: Border.all(color: border, width: borderWidth),
        boxShadow: shadow,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
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
