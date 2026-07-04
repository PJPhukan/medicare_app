part of 'app_button.dart';

/// Square or circular icon-only button with press-scale feedback.
///
/// ```dart
/// AppIconButton(icon: Icon(Icons.notifications_outlined), onPressed: _open)
/// AppIconButton(icon: Icon(Icons.close_rounded), circle: true, size: 36)
/// AppIconButton(icon: SvgPicture.asset('...'), badge: 3)
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.size           = 40,
    this.iconSize       = 18,
    this.borderRadius,
    this.circle         = false,
    this.hasBorder      = false,
    this.badge,
    this.badgeColor,
    this.tooltip,
    this.semanticLabel,
    this.shadow,
  });

  /// Any widget — Icon, SvgPicture, Image, etc.
  final Widget           icon;
  final VoidCallback?    onPressed;

  /// Icon colour passed via [IconTheme]. Defaults to [AppColors.textSecondary].
  final Color?           color;

  /// Container fill. Defaults to theme input background.
  final Color?           backgroundColor;

  /// Explicit border colour. Also enables the border when provided.
  final Color?           borderColor;

  /// Container size (width = height). Default 40.
  final double           size;

  /// Icon size hint passed via [IconTheme]. Default 18.
  final double           iconSize;

  /// Corner radius for rectangular shape. Ignored when [circle] is true.
  final BorderRadius?    borderRadius;

  /// Renders a circle container instead of a rounded rectangle.
  final bool             circle;

  /// Shows a border using [borderColor] or [context.borderCol].
  final bool             hasBorder;

  /// Badge count overlaid at top-right corner.
  final int?             badge;

  /// Badge overlay color — defaults to [AppColors.error].
  final Color?           badgeColor;

  final String?          tooltip;

  /// Accessibility label. Falls back to [tooltip] when not provided.
  final String?          semanticLabel;

  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.textSecondary;
    final bg = backgroundColor ?? context.inputBg;
    final br = circle ? null : (borderRadius ?? AppBorderRadius.mdAll);

    Border? border;
    if (hasBorder || borderColor != null) {
      border = Border.all(color: borderColor ?? context.borderCol);
    }

    Widget btn = _Pressable(
      onPressed: onPressed,
      child: AnimatedOpacity(
        duration: AppAnimations.fast,
        opacity:  onPressed == null ? 0.45 : 1.0,
        child: Container(
          width:  size,
          height: size,
          decoration: BoxDecoration(
            color:        bg,
            shape:        circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: br,
            border:       border,
            boxShadow:    shadow,
          ),
          child: Center(
            child: IconTheme(
              data:  IconThemeData(size: iconSize, color: fg),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (badge != null) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            top: -4, right: -4,
            child: _BadgeDot(
              count:     badge!,
              color:     badgeColor ?? AppColors.error,
              ringColor: context.bg,
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      label:  semanticLabel ?? tooltip,
      child: tooltip != null
          ? Tooltip(message: tooltip!, child: btn)
          : btn,
    );
  }
}

// ─── Badge dot ────────────────────────────────────────────────────────────────

class _BadgeDot extends StatelessWidget {
  const _BadgeDot({
    required this.count,
    required this.color,
    required this.ringColor,
  });

  final int   count;
  final Color color;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(99),
        border:       Border.all(color: ringColor, width: 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize:   9,
          fontWeight: FontWeight.w700,
          color:      Colors.white,
          height:     1,
        ),
      ),
    );
  }
}
