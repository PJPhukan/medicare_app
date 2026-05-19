import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for the top-of-screen page header.
///
/// Mirrors [AppPageHeaderText]: optional greeting → large title → subtitle,
/// with an optional trailing avatar circle.
///
/// ```dart
/// AppPageHeaderSkeleton()
/// AppPageHeaderSkeleton(showTrailing: true)   // with avatar on the right
/// AppPageHeaderSkeleton(showGreeting: false)  // no greeting line
/// ```
class AppPageHeaderSkeleton extends StatelessWidget {
  const AppPageHeaderSkeleton({
    super.key,
    this.showGreeting = true,
    this.showSubtitle = true,
    this.showTrailing = false,
    this.trailingSize = 44,
    this.padding,
  });

  final bool showGreeting;
  final bool showSubtitle;
  final bool showTrailing;
  final double trailingSize;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Text column ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Greeting
                  if (showGreeting) ...[
                    SkeletonBox(
                      width: 110,
                      height: 13,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Title (h1 — tall and wide)
                  SkeletonBox(
                    width: 200,
                    height: 28,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  // Subtitle
                  if (showSubtitle) ...[
                    const SizedBox(height: 10),
                    SkeletonBox(
                      width: 240,
                      height: 13,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ],
              ),
            ),

            // ── Trailing avatar ───────────────────────────────────────────
            if (showTrailing) ...[
              const SizedBox(width: 12),
              SkeletonBox(
                width: trailingSize,
                height: trailingSize,
                shape: BoxShape.circle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
