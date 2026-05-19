import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton for a single stat block: large value + unit + label.
///
/// ```dart
/// AppStatSkeleton()
/// AppStatSkeleton(size: AppStatSkeletonSize.xl)
/// ```
class AppStatSkeleton extends StatelessWidget {
  const AppStatSkeleton({
    super.key,
    this.size = AppStatSkeletonSize.md,
    this.showTrend = false,
    this.alignment = CrossAxisAlignment.start,
    this.padding,
  });

  final AppStatSkeletonSize size;
  final bool showTrend;
  final CrossAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final (valueH, valueW, labelW) = switch (size) {
      AppStatSkeletonSize.xl => (48.0, 120.0, 80.0),
      AppStatSkeletonSize.lg => (36.0, 100.0, 70.0),
      AppStatSkeletonSize.md => (28.0, 80.0,  60.0),
      AppStatSkeletonSize.sm => (20.0, 60.0,  50.0),
    };

    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Value + unit
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(
                  width: valueW,
                  height: valueH,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SkeletonBox(
                    width: 24,
                    height: valueH * 0.4,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Label
            SkeletonBox(
              width: labelW,
              height: 11,
              borderRadius: BorderRadius.circular(6),
            ),

            // Trend chip
            if (showTrend) ...[
              const SizedBox(height: 8),
              SkeletonBox(
                width: 56,
                height: 20,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum AppStatSkeletonSize { xl, lg, md, sm }

// ─── Stat row skeleton ────────────────────────────────────────────────────────

/// Row of evenly-spaced [AppStatSkeleton] blocks separated by vertical dividers.
///
/// ```dart
/// AppStatRowSkeleton(count: 3)
/// ```
class AppStatRowSkeleton extends StatelessWidget {
  const AppStatRowSkeleton({
    super.key,
    this.count = 3,
    this.size = AppStatSkeletonSize.md,
    this.padding,
  });

  final int count;
  final AppStatSkeletonSize size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? const Color(0xFF1F2D3F)
        : const Color(0xFFE2E8F0);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(count * 2 - 1, (i) {
            if (i.isOdd) {
              return VerticalDivider(width: 32, thickness: 1, color: dividerColor);
            }
            return Expanded(
              child: AppStatSkeleton(size: size),
            );
          }),
        ),
      ),
    );
  }
}
