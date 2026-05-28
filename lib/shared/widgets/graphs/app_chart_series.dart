import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ─── Default palette ──────────────────────────────────────────────────────────

/// Colour palette used when [AppChartSeries.color] is null.
/// Cycles modulo — supports any number of series.
const kChartPalette = [
  AppColors.teal,
  AppColors.blue,
  AppColors.purple,
  AppColors.amber,
  AppColors.red,
  AppColors.green,
  AppColors.pink,
];

Color paletteColor(int index) => kChartPalette[index % kChartPalette.length];

// ─── Line series ──────────────────────────────────────────────────────────────

/// One data series for [AppLineGraph].
///
/// ```dart
/// AppChartSeries(
///   label: 'Systolic',
///   points: [FlSpot(0, 120), FlSpot(1, 118), ...],
///   color: AppColors.red,
/// )
/// ```
class AppChartSeries {
  const AppChartSeries({
    required this.points,
    this.label,
    this.color,
    this.strokeWidth = 2.5,
    this.showDots = false,
    this.filled = true,
    this.dashed = false,
    this.fillOpacity = 0.15,
  });

  /// Data points — x is typically a time index, y is the measured value.
  final List<FlSpot> points;

  /// Series name shown in the legend and touch tooltip.
  final String? label;

  /// Line colour. Null → auto-assigned from [kChartPalette].
  final Color? color;

  final double strokeWidth;
  final bool showDots;

  /// Fill the area below the line with a gradient.
  final bool filled;

  /// Render the line as dashed (useful for reference/target lines).
  final bool dashed;

  final double fillOpacity;
}

// ─── Bar series ───────────────────────────────────────────────────────────────

/// One data series for [AppBarGraph].
///
/// [values] must have the same length as the number of groups
/// (i.e. one bar per group per series).
class AppBarSeries {
  const AppBarSeries({
    required this.values,
    this.label,
    this.color,
  });

  final List<double> values;
  final String? label;
  final Color? color;
}

// ─── Donut segment ────────────────────────────────────────────────────────────

/// One segment for [AppDonutChart] or [AppPieChart].
class AppDonutSegment {
  const AppDonutSegment({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

// ─── Reference line ───────────────────────────────────────────────────────────

/// Horizontal dashed reference line on a line/bar graph (e.g. normal range).
class AppChartRefLine {
  const AppChartRefLine({
    required this.y,
    required this.label,
    this.color,
    this.dashed = true,
  });

  final double y;
  final String label;
  final Color? color;
  final bool dashed;
}
