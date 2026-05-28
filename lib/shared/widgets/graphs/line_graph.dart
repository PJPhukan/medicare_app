import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_chart_series.dart';

/// Multi-series line graph with optional legend, touch tooltip, and reference lines.
///
/// Pass 1 series for a simple trend, or N series for comparisons like
/// systolic vs diastolic, or multiple vitals on one canvas.
///
/// ```dart
/// AppLineGraph(
///   height: 220,
///   series: [
///     AppChartSeries(
///       label: 'Systolic',
///       points: systolicSpots,
///       color: AppColors.red,
///     ),
///     AppChartSeries(
///       label: 'Diastolic',
///       points: diastolicSpots,
///       color: AppColors.blue,
///     ),
///   ],
///   labelX: (v) => days[v.toInt()],
///   labelY: (v) => '${v.toInt()}',
///   refLines: [
///     AppChartRefLine(y: 120, label: 'Normal', color: AppColors.green),
///   ],
/// )
/// ```
class AppLineGraph extends StatelessWidget {
  const AppLineGraph({
    super.key,
    required this.series,
    this.height = 200,
    this.showGrid = false,
    this.showLegend = true,
    this.minY,
    this.maxY,
    this.labelX,
    this.labelY,
    this.refLines = const [],
    this.reservedSizeLeft = 36,
    this.reservedSizeBottom = 24,
  });

  final List<AppChartSeries> series;
  final double height;
  final bool showGrid;

  /// Shows a colour-coded legend row above the chart.
  /// Auto-hidden when all series have no label.
  final bool showLegend;

  final double? minY;
  final double? maxY;
  final String Function(double)? labelX;
  final String Function(double)? labelY;

  /// Horizontal reference lines (e.g. normal/target range).
  final List<AppChartRefLine> refLines;

  final double reservedSizeLeft;
  final double reservedSizeBottom;

  bool get _hasLabels => series.any((s) => s.label != null);

  @override
  Widget build(BuildContext context) {
    final gridCol = context.borderCol;
    final labelStyle = AppTypography.bodyXs.copyWith(
      color: AppColors.textSecondary,
    );

    final barData = series.asMap().entries.map((e) {
      final i = e.key;
      final s = e.value;
      final c = s.color ?? paletteColor(i);
      return LineChartBarData(
        spots: s.points,
        isCurved: true,
        color: c,
        barWidth: s.strokeWidth,
        dashArray: s.dashed ? [6, 4] : null,
        dotData: FlDotData(
          show: s.showDots,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 4,
            color: c,
            strokeWidth: 1.5,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: s.filled,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.withValues(alpha: s.fillOpacity),
              c.withValues(alpha: 0),
            ],
          ),
        ),
      );
    }).toList();

    final extraLines = refLines.map((r) {
      final c = r.color ?? AppColors.textHint;
      return HorizontalLine(
        y: r.y,
        color: c.withValues(alpha: 0.7),
        strokeWidth: 1,
        dashArray: r.dashed ? [6, 4] : null,
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          style: AppTypography.bodyXs.copyWith(color: c),
          labelResolver: (_) => r.label,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Legend ────────────────────────────────────────────────────────────
        if (showLegend && _hasLabels) ...[
          _Legend(series: series),
          const SizedBox(height: 12),
        ],

        // ── Chart ─────────────────────────────────────────────────────────────
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: showGrid,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: gridCol,
                  strokeWidth: 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: labelY != null,
                    reservedSize: reservedSizeLeft,
                    getTitlesWidget: labelY != null
                        ? (v, _) => Text(labelY!(v), style: labelStyle)
                        : (_, __) => const SizedBox.shrink(),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: labelX != null,
                    reservedSize: reservedSizeBottom,
                    getTitlesWidget: labelX != null
                        ? (v, _) => Text(labelX!(v), style: labelStyle)
                        : (_, __) => const SizedBox.shrink(),
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: barData,
              extraLinesData: ExtraLinesData(horizontalLines: extraLines),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => context.cardBg,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final s = series[spot.barIndex];
                    final c = s.color ?? paletteColor(spot.barIndex);
                    return LineTooltipItem(
                      s.label != null
                          ? '${s.label}: ${spot.y.toStringAsFixed(1)}'
                          : spot.y.toStringAsFixed(1),
                      AppTypography.bodyXs.copyWith(
                        color: c,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Legend ───────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.series});
  final List<AppChartSeries> series;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: series.asMap().entries
          .where((e) => e.value.label != null)
          .map((e) {
        final c = e.value.color ?? paletteColor(e.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              e.value.label!,
              style: AppTypography.bodyXs.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
