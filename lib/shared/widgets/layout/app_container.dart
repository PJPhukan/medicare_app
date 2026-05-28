import 'package:flutter/material.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../utils/animated_tap.dart';

// ─── Variant ──────────────────────────────────────────────────────────────────

enum AppContainerVariant {
  /// Solid surface background with a subtle border. Default.
  filled,

  /// Transparent background with a visible border.
  outlined,

  /// Solid background tinted with [color] at low opacity.
  tinted,

  /// Solid background with a card shadow, no border.
  elevated,

  /// Solid background, no border, no shadow.
  flat,
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Universal themed container — the primitive surface used throughout the app.
///
/// Adapts background, border, and shadow to the active theme by default.
/// Every parameter is optional; pass only what you need to override.
///
/// ```dart
/// // Simple filled surface
/// AppContainer(child: MyContent())
///
/// // Outlined section
/// AppContainer.outlined(child: MyContent(), padding: EdgeInsets.all(12))
///
/// // Tinted accent block
/// AppContainer.tinted(color: AppColors.teal, child: MyContent())
///
/// // Gradient banner
/// AppContainer(
///   gradient: LinearGradient(colors: [AppColors.teal, AppColors.blue]),
///   child: MyContent(),
/// )
///
/// // Tappable surface with press animation
/// AppContainer(onTap: _onTap, child: MyContent())
/// ```
class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.variant = AppContainerVariant.filled,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.gradient,
    this.shadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.onLongPress,
  });

  // ── Named constructors ────────────────────────────────────────────────────────

  const AppContainer.outlined({
    Key? key,
    required Widget child,
    Color? color,
    Color? borderColor,
    double borderWidth = 1.0,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BoxConstraints? constraints,
    AlignmentGeometry? alignment,
    VoidCallback? onTap,
  }) : this(
          key: key,
          child: child,
          variant: AppContainerVariant.outlined,
          color: color,
          borderColor: borderColor,
          borderWidth: borderWidth,
          borderRadius: borderRadius,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          constraints: constraints,
          alignment: alignment,
          onTap: onTap,
        );

  const AppContainer.tinted({
    Key? key,
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BoxConstraints? constraints,
    AlignmentGeometry? alignment,
    VoidCallback? onTap,
  }) : this(
          key: key,
          child: child,
          variant: AppContainerVariant.tinted,
          color: color,
          borderRadius: borderRadius,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          constraints: constraints,
          alignment: alignment,
          onTap: onTap,
        );

  const AppContainer.elevated({
    Key? key,
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BoxConstraints? constraints,
    AlignmentGeometry? alignment,
    VoidCallback? onTap,
  }) : this(
          key: key,
          child: child,
          variant: AppContainerVariant.elevated,
          color: color,
          borderRadius: borderRadius,
          shadow: shadow,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          constraints: constraints,
          alignment: alignment,
          onTap: onTap,
        );

  const AppContainer.flat({
    Key? key,
    required Widget child,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    BoxConstraints? constraints,
    AlignmentGeometry? alignment,
    VoidCallback? onTap,
  }) : this(
          key: key,
          child: child,
          variant: AppContainerVariant.flat,
          color: color,
          borderRadius: borderRadius,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          constraints: constraints,
          alignment: alignment,
          onTap: onTap,
        );

  // ── Props ─────────────────────────────────────────────────────────────────────

  final Widget child;
  final AppContainerVariant variant;

  /// Override background color. For [tinted], this becomes the tint base.
  final Color? color;

  /// Border colour override. Ignored by [elevated] and [flat] variants.
  final Color? borderColor;
  final double borderWidth;

  /// Defaults to [AppBorderRadius.lgAll].
  final BorderRadius? borderRadius;

  /// Gradient painted over the background. Overrides [color] when set.
  final Gradient? gradient;

  /// Custom shadow list. Defaults per variant when null.
  final List<BoxShadow>? shadow;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? AppBorderRadius.lgAll;

    final bg    = _resolveBackground(context);
    final bd    = _resolveBorder(context);
    final sh    = _resolveShadow();

    Widget box = Container(
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient != null ? null : bg,
        gradient: gradient,
        borderRadius: br,
        border: bd,
        boxShadow: sh,
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (margin != null) box = Padding(padding: margin!, child: box);

    if (onTap != null || onLongPress != null) {
      return AnimatedTap(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: br,
        child: box,
      );
    }

    return box;
  }

  Color _resolveBackground(BuildContext context) {
    switch (variant) {
      case AppContainerVariant.filled:
      case AppContainerVariant.elevated:
        return color ?? context.cardBg;
      case AppContainerVariant.flat:
        return color ?? context.cardBg;
      case AppContainerVariant.outlined:
        return color ?? Colors.transparent;
      case AppContainerVariant.tinted:
        final base = color ?? AppColors.teal;
        return base.withValues(alpha: 0.10);
    }
  }

  Border? _resolveBorder(BuildContext context) {
    switch (variant) {
      case AppContainerVariant.elevated:
      case AppContainerVariant.flat:
        return null;
      case AppContainerVariant.tinted:
        final base = color ?? AppColors.teal;
        return Border.all(
          color: borderColor ?? base.withValues(alpha: 0.25),
          width: borderWidth,
        );
      case AppContainerVariant.filled:
      case AppContainerVariant.outlined:
        return Border.all(
          color: borderColor ?? context.borderCol,
          width: borderWidth,
        );
    }
  }

  List<BoxShadow>? _resolveShadow() {
    if (shadow != null) return shadow;
    if (variant == AppContainerVariant.elevated) return AppShadows.card;
    return null;
  }
}
