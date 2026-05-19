import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ─── Mini Sparkline ───────────────────────────────────────────────────────────
// Reusable small line chart — pass in data points and a color.
// Used in vital chips, stat cards, and anywhere a compact trend is needed.

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    super.key,
    required this.points,
    required this.color,
    this.height = 32,
    this.strokeWidth = 1.6,
    this.filled = true,
    this.fillOpacity = 0.18,
    this.padding = EdgeInsets.zero,
  });

  final List<double> points;
  final Color color;
  final double height;
  final double strokeWidth;
  final bool filled;
  final double fillOpacity;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: height);
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _SparklinePainter(
            points: points,
            color: color,
            strokeWidth: strokeWidth,
            filled: filled,
            fillOpacity: fillOpacity,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.filled,
    required this.fillOpacity,
  });

  final List<double> points;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width == 0 || size.height == 0) return;

    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();

    // Normalize to [0.05, 0.95] so the line never touches edges
    List<double> norm = points.map((p) {
      if (range == 0) return 0.5;
      return 0.05 + 0.90 * (p - min) / range;
    }).toList();

    final step = size.width / (norm.length - 1);

    Offset pt(int i) => Offset(i * step, size.height * (1.0 - norm[i]));

    final path = Path();
    path.moveTo(pt(0).dx, pt(0).dy);

    for (int i = 0; i < norm.length - 1; i++) {
      final p0 = pt(i);
      final p1 = pt(i + 1);
      final cpx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
    }

    // Filled area with gradient
    if (filled) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [
            color.withValues(alpha: fillOpacity),
            color.withValues(alpha: 0.0),
          ],
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled;
}

// ─── Mini Bar Chart ───────────────────────────────────────────────────────────
// 7-bar weekly chart. Used in adherence summary cards.

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 36,
    this.barRadius = 3,
    this.spacing = 4,
    this.dimOpacity = 0.2,
  });

  final List<double> values;   // 0.0 – 1.0 normalized fill ratios
  final Color color;
  final double height;
  final double barRadius;
  final double spacing;
  final double dimOpacity;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final ratio = values[i].clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < values.length - 1 ? spacing : 0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background track
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: dimOpacity),
                      borderRadius: BorderRadius.circular(barRadius),
                    ),
                  ),
                  // Filled bar
                  FractionallySizedBox(
                    heightFactor: ratio == 0 ? 0.06 : ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(barRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
