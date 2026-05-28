import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Icon button with an animated notification badge (dot or count).
///
/// ```dart
/// AppBadgeIconButton(
///   icon: Icons.notifications_outlined,
///   count: 3,
///   onPressed: _openNotifications,
/// )
/// AppBadgeIconButton(
///   icon: Icons.shopping_bag_outlined,
///   showDot: true,
///   onPressed: _openCart,
/// )
/// ```
class AppBadgeIconButton extends StatefulWidget {
  const AppBadgeIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.count,
    this.showDot = false,
    this.color,
    this.badgeColor,
    this.backgroundColor,
    this.size = 40,
    this.iconSize,
    this.circle = false,
    this.tooltip,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Numeric badge count. Values > 99 display as "99+".
  final int? count;

  /// Show a small dot badge (ignores [count]).
  final bool showDot;

  /// Icon colour.
  final Color? color;

  /// Badge background colour. Defaults to [AppColors.error].
  final Color? badgeColor;

  /// Container background. Defaults to theme input bg.
  final Color? backgroundColor;

  final double size;
  final double? iconSize;
  final bool circle;
  final String? tooltip;
  final bool enabled;

  @override
  State<AppBadgeIconButton> createState() => _AppBadgeIconButtonState();
}

class _AppBadgeIconButtonState extends State<AppBadgeIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => !widget.enabled || widget.onPressed == null;

  String? get _badgeLabel {
    if (widget.showDot) return null;
    final c = widget.count;
    if (c == null || c <= 0) return null;
    return c > 99 ? '99+' : '$c';
  }

  bool get _hasBadge =>
      widget.showDot || (widget.count != null && widget.count! > 0);

  @override
  Widget build(BuildContext context) {
    final fg     = widget.color ?? AppColors.textSecondary;
    final bg     = widget.backgroundColor ?? context.inputBg;
    final badge  = widget.badgeColor ?? AppColors.error;
    final iSize  = widget.iconSize ?? widget.size * 0.45;
    final br     = widget.circle ? null : AppBorderRadius.mdAll;

    Widget btn = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: AnimatedOpacity(
        duration: AppAnimations.fast,
        opacity: _disabled ? 0.45 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Button surface
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: bg,
                shape:
                    widget.circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: br,
              ),
              child: Icon(widget.icon, size: iSize, color: fg),
            ),

            // Badge
            if (_hasBadge)
              Positioned(
                top: -4,
                right: -4,
                child: _Badge(
                  label: _badgeLabel,
                  color: badge,
                ),
              ),
          ],
        ),
      ),
    );

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

class _Badge extends StatelessWidget {
  const _Badge({this.label, required this.color});
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDot = label == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: BoxConstraints(
        minWidth: isDot ? 8 : 16,
        minHeight: isDot ? 8 : 16,
      ),
      padding: isDot
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        shape: isDot ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isDot ? null : AppBorderRadius.pill,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: isDot
          ? null
          : Text(
              label!,
              style: AppTypography.labelXs.copyWith(
                color: Colors.white,
                fontSize: 9,
                letterSpacing: 0,
              ),
            ),
    );
  }
}
