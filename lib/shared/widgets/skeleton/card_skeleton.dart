import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import 'skeleton_base.dart';

/// Skeleton for a generic content card.
///
/// Renders an optional image/banner area at the top, followed by
/// title + body lines, and an optional footer row with a pill badge + button.
///
/// ```dart
/// AppCardSkeleton()                           // standard card
/// AppCardSkeleton(showImage: true, imageHeight: 140)  // card with banner
/// AppCardSkeleton(showFooter: true)           // card with footer row
/// ```
class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({
    super.key,
    this.showImage = false,
    this.imageHeight = 120,
    this.lines = 2,
    this.showFooter = false,
    this.radius = 16,
    this.padding,
    this.width,
    this.height,
  });

  final bool showImage;
  final double imageHeight;
  final int lines;
  final bool showFooter;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cardBg  = context.cardBg;
    final border  = context.borderCol;
    final br      = BorderRadius.circular(radius);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: br,
          border: Border.all(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Banner / image ─────────────────────────────────────────
              if (showImage)
                SkeletonBox(
                  width: double.infinity,
                  height: imageHeight,
                  borderRadius: BorderRadius.zero,
                ),

              // ── Content ────────────────────────────────────────────────
              Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    SkeletonBox(
                      width: 160,
                      height: 15,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    const SizedBox(height: 10),

                    // Body lines
                    ...List.generate(lines, (i) {
                      final isLast = i == lines - 1;
                      Widget line = SkeletonBox(
                        height: 12,
                        borderRadius: BorderRadius.circular(6),
                      );
                      if (isLast) {
                        line = FractionallySizedBox(widthFactor: 0.6, child: line);
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                        child: line,
                      );
                    }),

                    // Footer
                    if (showFooter) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SkeletonBox(
                            width: 64,
                            height: 24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          const Spacer(),
                          SkeletonBox(
                            width: 80,
                            height: 32,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Horizontal card skeleton ─────────────────────────────────────────────────

/// Skeleton for a horizontal card (image left, content right).
///
/// ```dart
/// AppHorizontalCardSkeleton()
/// ```
class AppHorizontalCardSkeleton extends StatelessWidget {
  const AppHorizontalCardSkeleton({
    super.key,
    this.imageWidth = 80,
    this.height = 90,
    this.lines = 2,
    this.radius = 14,
    this.padding,
  });

  final double imageWidth;
  final double height;
  final int lines;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cardBg = context.cardBg;
    final border = context.borderCol;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppSkeleton(
        child: Row(
          children: [
            // Thumbnail
            SkeletonBox(
              width: imageWidth,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            // Content
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(lines, (i) {
                    final isLast = i == lines - 1;
                    Widget line = SkeletonBox(
                      height: isLast ? 11 : 14,
                      borderRadius: BorderRadius.circular(6),
                    );
                    if (isLast) {
                      line = FractionallySizedBox(widthFactor: 0.55, child: line);
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                      child: line,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
