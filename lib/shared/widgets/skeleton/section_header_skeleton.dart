import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for a section header row: accent bar + title + optional "See all" link.
///
/// ```dart
/// AppSectionHeaderSkeleton()
/// AppSectionHeaderSkeleton(showAccentBar: false, showAction: false)
/// ```
class AppSectionHeaderSkeleton extends StatelessWidget {
  const AppSectionHeaderSkeleton({
    super.key,
    this.showAccentBar = true,
    this.showSubtitle = false,
    this.showAction = true,
    this.padding,
  });

  final bool showAccentBar;
  final bool showSubtitle;
  final bool showAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Accent bar
            if (showAccentBar) ...[
              SkeletonBox(
                width: 3,
                height: showSubtitle ? 34 : 20,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(width: 10),
            ],

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(
                    width: 130,
                    height: 14,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 5),
                    SkeletonBox(
                      width: 90,
                      height: 11,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ],
              ),
            ),

            // "See all" action
            if (showAction)
              SkeletonBox(
                width: 52,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
          ],
        ),
      ),
    );
  }
}
