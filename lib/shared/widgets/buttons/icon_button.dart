import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';

/// Square or circular icon-only button with press-scale feedback.
///
/// ```dart
/// AppIconBtn(icon: Icons.notifications_outlined, onPressed: _open)
/// AppIconBtn(icon: Icons.close_rounded, circle: true, size: 36)
/// AppIconBtn(icon: Icons.add, color: AppColors.teal, backgroundColor: AppColors.teal10)
/// ```
class AppIconBtn extends StatefulWidget {
  const AppIconBtn({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.size = 40,
    this.iconSize,
    this.borderRadius,
    this.circle = false,
    this.badge,
    this.tooltip,
    this.enabled = true,
    this.shadow,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Icon colour. Defaults to [AppColors.textSecondary].
  final Color? color;

  /// Container fill. Defaults to theme input background.
  final Color? backgroundColor;

  final Color? borderColor;

  /// Container size (width = height). Default 40.
  final double size;

  /// Icon size. Defaults to [size] × 0.45.
  final double? iconSize;

  /// Corner radius. Ignored when [circle] is true.
  final BorderRadius? borderRadius;

  /// Renders a circle container instead of rounded rectangle.
  final bool circle;

  /// Optional notification badge overlaid top-right.
  final Widget? badge;

  final String? tooltip;
  final bool enabled;
  final List<BoxShadow>? shadow;

  @override
  State<AppIconBtn> createState() => _AppIconBtnState();
}

class _AppIconBtnState extends State<AppIconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => !widget.enabled || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg  = widget.color ?? AppColors.textSecondary;
    final bg  = widget.backgroundColor ??
        (isDark ? AppColors.dark700 : AppColors.light200);
    final br  = widget.circle
        ? null
        : (widget.borderRadius ?? AppBorderRadius.mdAll);
    final iSize = widget.iconSize ?? widget.size * 0.45;

    Widget btn = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: AnimatedOpacity(
        duration: AppAnimations.fast,
        opacity: _disabled ? 0.45 : 1.0,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: br,
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!)
                : null,
            boxShadow: widget.shadow,
          ),
          child: Icon(widget.icon, size: iSize, color: fg),
        ),
      ),
    );

    if (widget.badge != null) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            top: -4,
            right: -4,
            child: widget.badge!,
          ),
        ],
      );
    }

    btn = GestureDetector(
      onTapDown: _disabled ? null : (_) => _ctrl.forward(),
      onTapUp: _disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onPressed!();
            },
      onTapCancel: _disabled ? null : () => _ctrl.reverse(),
      child: btn,
    );

    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: btn)
        : btn;
  }
}
