import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Compact single-series line sparkline — no axes, no labels, pure trend shape.
///
/// Used in stat cards, vital chips, and any place where a compact trend
/// is needed without full chart chrome.
///
/// ```dart
/// AppSparkline(
///   points: [120.0, 118.0, 122.0, 119.0, 115.0],
///   color: AppColors.teal,
///   height: 40,
///   filled: true,
/// )
/// ```
class AppSparkline extends StatelessWidget {
  const AppSparkline({
    super.key,
    required this.points,
    this.color,
    this.height = 36,
    this.strokeWidth = 1.8,
    this.filled = true,
    this.fillOpacity = 0.18,
    this.padding = EdgeInsets.zero,
  });

  final List<double> points;

  /// Line colour. Defaults to [AppColors.teal].
  final Color? color;

  final double height;
  final double strokeWidth;

  /// Fill the area under the line with a vertical gradient.
  final bool filled;
  final double fillOpacity;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: height);
    final c = color ?? AppColors.teal;
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _SparklinePainter(
            points: points,
            color: c,
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

    final norm = points.map((p) {
      if (range == 0) return 0.5;
      return 0.05 + 0.90 * (p - min) / range;
    }).toList();

    final step = size.width / (norm.length - 1);
    Offset pt(int i) => Offset(i * step, size.height * (1.0 - norm[i]));

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 0; i < norm.length - 1; i++) {
      final p0 = pt(i);
      final p1 = pt(i + 1);
      final cpx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
    }

    if (filled) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, size.height),
            [
              color.withValues(alpha: fillOpacity),
              color.withValues(alpha: 0),
            ],
          )
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled ||
      old.fillOpacity != fillOpacity;
}
