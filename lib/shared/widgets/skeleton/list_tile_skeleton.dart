import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for a list tile: leading shape + two text lines + optional trailing.
///
/// ```dart
/// AppListTileSkeleton()                         // avatar + title + subtitle
/// AppListTileSkeleton(leadingShape: BoxShape.rectangle, leadingSize: 44)
/// AppListTileSkeleton(showTrailing: true)       // adds a small trailing pill
/// AppListTileSkeleton.list(itemCount: 6)        // column of 6 tiles
/// ```
class AppListTileSkeleton extends StatelessWidget {
  const AppListTileSkeleton({
    super.key,
    this.leadingSize = 44,
    this.leadingShape = BoxShape.circle,
    this.showSubtitle = true,
    this.showTrailing = false,
    this.padding,
  });

  final double leadingSize;
  final BoxShape leadingShape;
  final bool showSubtitle;
  final bool showTrailing;
  final EdgeInsetsGeometry? padding;

  /// Convenience constructor: renders [itemCount] tiles in a column.
  static Widget list({
    int itemCount = 5,
    double leadingSize = 44,
    BoxShape leadingShape = BoxShape.circle,
    bool showSubtitle = true,
    bool showTrailing = false,
    EdgeInsetsGeometry? padding,
    double spacing = 0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (i) => AppListTileSkeleton(
          leadingSize: leadingSize,
          leadingShape: leadingShape,
          showSubtitle: showSubtitle,
          showTrailing: showTrailing,
          padding: padding,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Leading ───────────────────────────────────────────────────
            SkeletonBox(
              width: leadingSize,
              height: leadingSize,
              shape: leadingShape,
              borderRadius: leadingShape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(10),
            ),

            const SizedBox(width: 14),

            // ── Title + subtitle ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(
                    width: 160,
                    height: 13,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 7),
                    SkeletonBox(
                      width: 110,
                      height: 11,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ],
              ),
            ),

            // ── Trailing ──────────────────────────────────────────────────
            if (showTrailing) ...[
              const SizedBox(width: 12),
              SkeletonBox(
                width: 52,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
