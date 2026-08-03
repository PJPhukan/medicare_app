import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_gradients.dart';
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
    this.effectColor,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    this.raised = false,
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

  /// Outer drop shadow. Defaults to none — depth comes from the corner-lit
  /// surface gradient instead, which keeps the card flush with the page.
  final List<BoxShadow>? shadow;

  /// Tints the lit corner — e.g. `AppColors.teal` for an accent card.
  /// Defaults to a neutral white sheen.
  final Color? effectColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  /// Deepen the corner lighting — for the one hero card on a screen.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg     = color ?? context.cardBg;
    final border = borderColor ?? context.cardEdge;
    final br     = borderRadius ?? AppBorderRadius.xlAll;

    Widget card = Container(
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        gradient: AppGradients.cardSheen(bg, isDark,
            color: effectColor, strong: raised),
        borderRadius: br,
        border: Border.all(color: border, width: borderWidth),
        boxShadow: shadow ?? const [],
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
