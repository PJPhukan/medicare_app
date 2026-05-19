import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton placeholder for a bar chart.
///
/// Renders a row of bars at randomised heights to simulate real chart data.
///
/// ```dart
/// AppBarChartSkeleton()
/// AppBarChartSkeleton(barCount: 7, height: 140)
/// ```
class AppBarChartSkeleton extends StatelessWidget {
  const AppBarChartSkeleton({
    super.key,
    this.barCount = 7,
    this.height = 120,
    this.showXLabels = true,
    this.showYAxis = true,
    this.padding,
  });

  final int barCount;
  final double height;
  final bool showXLabels;
  final bool showYAxis;
  final EdgeInsetsGeometry? padding;

  static final _heights = [0.5, 0.8, 0.6, 1.0, 0.7, 0.45, 0.85,
                            0.55, 0.9, 0.65, 0.75, 0.4];

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis stub
                if (showYAxis) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        SkeletonBox(
                          width: 22,
                          height: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        SizedBox(height: (height - 30) / 3),
                      ],
                    ],
                  ),
                  const SizedBox(width: 10),
                ],

                // Bars
                Expanded(
                  child: SizedBox(
                    height: height,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(barCount, (i) {
                        final fraction = _heights[i % _heights.length];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: SkeletonBox(
                              height: height * fraction,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),

            // X-axis labels
            if (showXLabels) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (showYAxis) const SizedBox(width: 32),
                  ...List.generate(barCount, (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: SkeletonBox(
                        height: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Line chart skeleton ──────────────────────────────────────────────────────

/// Skeleton placeholder for a line chart with a wavy path.
///
/// ```dart
/// AppLineChartSkeleton()
/// AppLineChartSkeleton(height: 160, showDots: true)
/// ```
class AppLineChartSkeleton extends StatelessWidget {
  const AppLineChartSkeleton({
    super.key,
    this.height = 120,
    this.showDots = true,
    this.pointCount = 6,
    this.padding,
  });

  final double height;
  final bool showDots;
  final int pointCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              pointCount: pointCount,
              showDots: showDots,
              context: context,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.pointCount,
    required this.showDots,
    required this.context,
  });

  final int pointCount;
  final bool showDots;
  final BuildContext context;

  static const _yFactors = [0.65, 0.35, 0.55, 0.2, 0.45, 0.3, 0.5, 0.25];

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = isDark
        ? const Color(0xFF2A3A4E)   // dark500
        : const Color(0xFFCBD5E1);  // light400

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = List.generate(pointCount, (i) {
      final x = i * size.width / (pointCount - 1);
      final y = size.height * _yFactors[i % _yFactors.length];
      return Offset(x, y);
    });

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cx1 = prev.dx + (curr.dx - prev.dx) / 2;
      path.cubicTo(cx1, prev.dy, cx1, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, paint);

    if (showDots) {
      final dotPaint = Paint()..color = color ..style = PaintingStyle.fill;
      for (final p in points) {
        canvas.drawCircle(p, 4, dotPaint);
      }
    }

    // Faded fill below the line
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = color.withValues(alpha: 0.15) ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => false;
}
