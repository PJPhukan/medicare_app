import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for a form: stacked label + input field pairs + a submit button.
///
/// ```dart
/// AppFormSkeleton(fieldCount: 3)
/// AppFormSkeleton(fieldCount: 4, showButton: false)
/// ```
class AppFormSkeleton extends StatelessWidget {
  const AppFormSkeleton({
    super.key,
    this.fieldCount = 3,
    this.showButton = true,
    this.spacing = 20,
    this.padding,
  });

  final int fieldCount;
  final bool showButton;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(fieldCount, (i) => _FieldSkeleton(
              topPadding: i == 0 ? 0 : spacing,
            )),
            if (showButton) ...[
              SizedBox(height: spacing + 4),
              SkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton({this.topPadding = 0});
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          SkeletonBox(
            width: 90,
            height: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          // Input box
          SkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}

// ─── Search field skeleton ────────────────────────────────────────────────────

/// Skeleton for a pill-shaped search bar.
///
/// ```dart
/// AppSearchFieldSkeleton()
/// AppSearchFieldSkeleton(height: 44)
/// ```
class AppSearchFieldSkeleton extends StatelessWidget {
  const AppSearchFieldSkeleton({
    super.key,
    this.height = 48,
    this.padding,
  });

  final double height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SkeletonBox(
          width: double.infinity,
          height: height,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
