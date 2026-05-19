import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// A single skeleton line mimicking a text string.
///
/// ```dart
/// AppTextSkeleton(width: 180)          // heading-length line
/// AppTextSkeleton(widthFactor: 0.7)    // 70 % of parent width
/// ```
class AppTextSkeleton extends StatelessWidget {
  const AppTextSkeleton({
    super.key,
    this.width,
    this.widthFactor,
    this.height = 14,
    this.radius = 6,
  });

  /// Fixed width. If null, [widthFactor] or full expansion is used.
  final double? width;

  /// Fraction of parent width (0.0–1.0). Ignored when [width] is set.
  final double? widthFactor;

  /// Line height — matches your typography scale (body ≈ 14, heading ≈ 18–22).
  final double height;

  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget box = SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
    );

    if (width == null && widthFactor != null) {
      box = FractionallySizedBox(widthFactor: widthFactor, child: box);
    }

    return AppSkeleton(child: box);
  }
}

// ─── Paragraph skeleton ───────────────────────────────────────────────────────

/// Multiple skeleton lines that simulate a paragraph of body text.
///
/// The last line is narrower by default so it looks like a real paragraph tail.
///
/// ```dart
/// AppParagraphSkeleton(lines: 3)
/// AppParagraphSkeleton(lines: 4, lastLineFactor: 0.5)
/// ```
class AppParagraphSkeleton extends StatelessWidget {
  const AppParagraphSkeleton({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
    this.lastLineFactor = 0.6,
    this.padding,
  });

  final int lines;
  final double lineHeight;
  final double spacing;

  /// Width fraction of the final line relative to parent (0.0–1.0).
  final double lastLineFactor;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(lines, (i) {
            final isLast = i == lines - 1;
            Widget line = SkeletonBox(
              height: lineHeight,
              borderRadius: BorderRadius.circular(6),
            );
            if (isLast) {
              line = FractionallySizedBox(widthFactor: lastLineFactor, child: line);
            }
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : spacing),
              child: line,
            );
          }),
        ),
      ),
    );
  }
}
