import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';

/// Wraps any widget with a press-scale animation and an optional tap callback.
class AnimatedTap extends StatefulWidget {
  const AnimatedTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = AppAnimations.pressScale,
    this.duration,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final Duration? duration;
  final BorderRadius? borderRadius;

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppAnimations.fast,
    );
    _scale = Tween<double>(begin: 1, end: widget.scale)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null && widget.onLongPress == null;
    return GestureDetector(
      onTapDown:   disabled ? null : (_) => _ctrl.forward(),
      onTapUp:     disabled ? null : (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: disabled ? null : () => _ctrl.reverse(),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
