import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Circular skeleton for an avatar or profile picture.
///
/// ```dart
/// AppAvatarSkeleton()          // 40 px default
/// AppAvatarSkeleton(size: 72)  // large
/// AppAvatarSkeleton(size: 24)  // small / inline
/// ```
class AppAvatarSkeleton extends StatelessWidget {
  const AppAvatarSkeleton({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: SkeletonBox(
        width: size,
        height: size,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Avatar row skeleton ──────────────────────────────────────────────────────

/// Row of overlapping circle skeletons, like a grouped-avatar stack.
///
/// ```dart
/// AppAvatarStackSkeleton(count: 4)
/// ```
class AppAvatarStackSkeleton extends StatelessWidget {
  const AppAvatarStackSkeleton({
    super.key,
    this.count = 3,
    this.size = 36,
    this.overlap = 12,
  });

  final int count;
  final double size;

  /// How much each avatar overlaps the previous one.
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: SizedBox(
        height: size,
        width: size + (count - 1) * (size - overlap),
        child: Stack(
          children: List.generate(count, (i) {
            return Positioned(
              left: i * (size - overlap),
              child: SkeletonBox(
                width: size,
                height: size,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}
