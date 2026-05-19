import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Generic skeleton placeholder for any rectangular, circular, or pill-shaped block.
///
/// ```dart
/// // Rectangle card placeholder
/// AppBoxSkeleton(height: 120, width: double.infinity, radius: 16)
///
/// // Circle
/// AppBoxSkeleton(height: 48, width: 48, shape: BoxShape.circle)
///
/// // Pill / tag chip
/// AppBoxSkeleton(height: 28, width: 72, shape: BoxShape.rectangle, pill: true)
/// ```
class AppBoxSkeleton extends StatelessWidget {
  const AppBoxSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.shape = BoxShape.rectangle,
    this.pill = false,
    this.margin,
  });

  final double? width;
  final double? height;

  /// Corner radius for rectangles. Ignored when [pill] or [shape] == circle.
  final double? radius;

  final BoxShape shape;

  /// Shorthand for maximum corner radius (pill shape).
  final bool pill;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final br = pill
        ? BorderRadius.circular(999)
        : (radius != null ? BorderRadius.circular(radius!) : null);

    return AppSkeleton(
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: SkeletonBox(
          width: width,
          height: height,
          borderRadius: br,
          shape: shape,
        ),
      ),
    );
  }
}
