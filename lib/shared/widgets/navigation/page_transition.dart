import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';

// ─── Fade + slide up ──────────────────────────────────────────────────────────

class FadeSlideTransition extends StatelessWidget {
  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.animation,
    this.beginOffset = const Offset(0, 0.05),
  });

  final Widget child;
  final Animation<double> animation;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AppAnimations.decelerate),
      child: SlideTransition(
        position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: AppAnimations.decelerate)),
        child: child,
      ),
    );
  }
}

// ─── Page route builders ─────────────────────────────────────────────────────

Route<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, __) => page,
    transitionDuration: AppAnimations.pageTransition,
    reverseTransitionDuration: AppAnimations.fast,
    transitionsBuilder: (_, animation, __, child) =>
        FadeSlideTransition(animation: animation, child: child),
  );
}

Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, __) => page,
    transitionDuration: AppAnimations.normal,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppAnimations.decelerate),
          child: child,
        ),
  );
}

// ─── Staggered list item ──────────────────────────────────────────────────────

class StaggeredItem extends StatelessWidget {
  const StaggeredItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 60),
  });

  final int index;
  final Widget child;
  final Duration baseDelay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppAnimations.medium,
      curve: AppAnimations.decelerate,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
