part of 'app_button.dart';

class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    this.onPressed,
  });

  final Widget        child;
  final VoidCallback? onPressed;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: AppAnimations.pressScale).animate(
        CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => widget.onPressed == null;

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   _disabled ? null : _onTapDown,
      onTapUp:     _disabled ? null : _onTapUp,
      onTapCancel: _disabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder:   (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
