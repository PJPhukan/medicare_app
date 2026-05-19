import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

// ─── Theme-aware shimmer wrapper ──────────────────────────────────────────────

/// Wraps [child] in a shimmer animation that adapts to light and dark mode.
///
/// All skeleton widgets in this folder use this internally.
/// Wrap multiple skeletons in a single [AppSkeleton] for a single animation
/// that stays in sync.
///
/// ```dart
/// AppSkeleton(
///   child: Column(children: [
///     SkeletonBox(height: 20, width: double.infinity),
///     SizedBox(height: 8),
///     SkeletonBox(height: 20, width: 160),
///   ]),
/// )
/// ```
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:      isDark ? AppColors.dark700 : AppColors.light300,
      highlightColor: isDark ? AppColors.dark500 : AppColors.light100,
      child: child,
    );
  }
}

// ─── Primitive skeleton block ─────────────────────────────────────────────────

/// A solid-filled block used as the building block for all skeleton shapes.
///
/// Extend [shape] to [BoxShape.circle] for avatars, or set [borderRadius]
/// for rounded rectangles.  [width] and [height] accept null to expand.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.dark700 : AppColors.light300;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(6)),
        shape: shape,
      ),
    );
  }
}
