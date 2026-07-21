import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RippleAnimation extends StatefulWidget {
  const RippleAnimation({super.key});

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _ripple1Ctrl;
  late final AnimationController _ripple2Ctrl;
  late final AnimationController _ripple3Ctrl;

  late final Animation<double> _ripple1Scale;
  late final Animation<double> _ripple1Opacity;
  late final Animation<double> _ripple2Scale;
  late final Animation<double> _ripple2Opacity;
  late final Animation<double> _ripple3Scale;
  late final Animation<double> _ripple3Opacity;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _startSequence();
  }

  void _setupControllers() {
    _ripple1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripple2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripple3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  void _setupAnimations() {
    _ripple1Scale = Tween<double>(begin: 1, end: 2.6)
        .animate(CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut));
    _ripple1Opacity = Tween<double>(begin: 0.5, end: 0)
        .animate(CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut));
    _ripple2Scale = Tween<double>(begin: 1, end: 2.6)
        .animate(CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut));
    _ripple2Opacity = Tween<double>(begin: 0.35, end: 0)
        .animate(CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut));
    _ripple3Scale = Tween<double>(begin: 1, end: 2.6)
        .animate(CurvedAnimation(parent: _ripple3Ctrl, curve: Curves.easeOut));
    _ripple3Opacity = Tween<double>(begin: 0.2, end: 0)
        .animate(CurvedAnimation(parent: _ripple3Ctrl, curve: Curves.easeOut));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _ripple1Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple2Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple3Ctrl.forward();
  }

  @override
  void dispose() {
    _ripple1Ctrl.dispose();
    _ripple2Ctrl.dispose();
    _ripple3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _RippleRing(
          scaleAnim: _ripple3Scale,
          opacityAnim: _ripple3Opacity,
          size: 88,
          color: AppColors.teal,
        ),
        _RippleRing(
          scaleAnim: _ripple2Scale,
          opacityAnim: _ripple2Opacity,
          size: 88,
          color: AppColors.teal,
        ),
        _RippleRing(
          scaleAnim: _ripple1Scale,
          opacityAnim: _ripple1Opacity,
          size: 88,
          color: AppColors.teal,
        ),
      ],
    );
  }
}

class _RippleRing extends StatelessWidget {
  const _RippleRing({
    required this.scaleAnim,
    required this.opacityAnim,
    required this.size,
    required this.color,
  });

  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnim, opacityAnim]),
      builder: (_, __) => Transform.scale(
        scale: scaleAnim.value,
        child: Opacity(
          opacity: opacityAnim.value.clamp(0.0, 1.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
