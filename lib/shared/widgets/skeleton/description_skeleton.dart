import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Multi-line description / body-text skeleton block.
///
/// Renders a heading line followed by paragraph lines, simulating
/// a typical detail screen description section.
///
/// ```dart
/// AppDescriptionSkeleton()                    // heading + 3 lines
/// AppDescriptionSkeleton(showHeading: false, lines: 5)
/// ```
class AppDescriptionSkeleton extends StatelessWidget {
  const AppDescriptionSkeleton({
    super.key,
    this.showHeading = true,
    this.lines = 3,
    this.headingWidth = 180,
    this.lineHeight = 13,
    this.headingHeight = 16,
    this.spacing = 8,
    this.lastLineFactor = 0.55,
    this.padding,
  });

  final bool showHeading;
  final int lines;
  final double headingWidth;
  final double lineHeight;
  final double headingHeight;
  final double spacing;

  /// Width of the final paragraph line as a fraction of parent width.
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
          children: [
            // ── Heading ───────────────────────────────────────────────────
            if (showHeading) ...[
              SkeletonBox(
                width: headingWidth,
                height: headingHeight,
                borderRadius: BorderRadius.circular(7),
              ),
              SizedBox(height: spacing + 4),
            ],

            // ── Paragraph lines ───────────────────────────────────────────
            ...List.generate(lines, (i) {
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
          ],
        ),
      ),
    );
  }
}
