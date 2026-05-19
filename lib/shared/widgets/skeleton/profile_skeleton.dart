import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for a profile block: circle avatar + name + subtitle lines.
///
/// ```dart
/// // Horizontal (list-style)
/// AppProfileSkeleton()
///
/// // Centered column (profile page header)
/// AppProfileSkeleton(direction: Axis.vertical, avatarSize: 80)
/// ```
class AppProfileSkeleton extends StatelessWidget {
  const AppProfileSkeleton({
    super.key,
    this.avatarSize = 48,
    this.direction = Axis.horizontal,
    this.showSubtitle = true,
    this.showThirdLine = false,
    this.padding,
  });

  final double avatarSize;

  /// [Axis.horizontal] — avatar left, lines right (list tile style).
  /// [Axis.vertical]   — avatar top-centered, lines below (profile page style).
  final Axis direction;

  final bool showSubtitle;
  final bool showThirdLine;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final avatar = SkeletonBox(
      width: avatarSize,
      height: avatarSize,
      shape: BoxShape.circle,
    );

    final lines = Column(
      crossAxisAlignment: direction == Axis.vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name line
        SkeletonBox(
          width: 140,
          height: 14,
          borderRadius: BorderRadius.circular(6),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 7),
          SkeletonBox(
            width: 100,
            height: 11,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
        if (showThirdLine) ...[
          const SizedBox(height: 7),
          SkeletonBox(
            width: 80,
            height: 10,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ],
    );

    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: direction == Axis.horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 14),
                  lines,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(height: 14),
                  lines,
                ],
              ),
      ),
    );
  }
}
