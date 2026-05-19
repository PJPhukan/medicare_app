import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton placeholder for a button.
///
/// ```dart
/// AppButtonSkeleton()                          // full-width primary button
/// AppButtonSkeleton(width: 120, height: 36)    // compact button
/// AppButtonSkeleton(pill: true)                // pill-shaped
/// ```
class AppButtonSkeleton extends StatelessWidget {
  const AppButtonSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 48,
    this.radius = 12,
    this.pill = false,
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;

  /// Renders a fully rounded pill-shaped button.
  final bool pill;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: SkeletonBox(
          width: width,
          height: height,
          borderRadius: BorderRadius.circular(pill ? 999 : radius),
        ),
      ),
    );
  }
}

// ─── Icon button skeleton ─────────────────────────────────────────────────────

/// Skeleton for a square or circular icon button.
class AppIconButtonSkeleton extends StatelessWidget {
  const AppIconButtonSkeleton({
    super.key,
    this.size = 40,
    this.circle = false,
  });

  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: SkeletonBox(
        width: size,
        height: size,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(10),
      ),
    );
  }
}
