import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_chart_series.dart';

/// Multi-series grouped bar graph.
///
/// Each [AppBarSeries] provides one bar per group. All series must have the
/// same [values] length (= [groupCount]).
///
/// ```dart
/// AppBarGraph(
///   groupCount: 7,
///   xLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
///   series: [
///     AppBarSeries(label: 'Steps', values: [...], color: AppColors.teal),
///     AppBarSeries(label: 'Goal',  values: [...], color: AppColors.blue),
///   ],
/// )
/// ```
class AppBarGraph extends StatelessWidget {
  const AppBarGraph({
    super.key,
    required this.series,
    required this.groupCount,
    this.xLabels,
    this.height = 200,
    this.showGrid = false,
    this.showLegend = true,
    this.maxY,
    this.barWidth,
    this.groupSpacing = 14,
    this.barSpacing = 4,
    this.barRadius = 4,
  });

  final List<AppBarSeries> series;

  /// Number of groups along the X axis (= values.length per series).
  final int groupCount;

  /// Optional X-axis labels. Length must match [groupCount].
  final List<String>? xLabels;

  final double height;
  final bool showGrid;
  final bool showLegend;
  final double? maxY;

  /// Width of each individual bar. Auto-calculated when null.
  final double? barWidth;

  /// Gap between groups.
  final double groupSpacing;

  /// Gap between bars within a group.
  final double barSpacing;

  final double barRadius;

  bool get _hasLabels => series.any((s) => s.label != null);

  @override
  Widget build(BuildContext context) {
    final gridCol = context.borderCol;
    final labelStyle = AppTypography.bodyXs.copyWith(
      color: AppColors.textSecondary,
    );

    final bw = barWidth ?? (series.length == 1 ? 14.0 : 10.0);

    final groups = List.generate(groupCount, (gi) {
      return BarChartGroupData(
        x: gi,
        groupVertically: false,
        barRods: series.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final c = s.color ?? paletteColor(i);
          final value = gi < s.values.length ? s.values[gi] : 0.0;
          return BarChartRodData(
            toY: value,
            color: c,
            width: bw,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barRadius),
              topRight: Radius.circular(barRadius),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY ?? _computeMax(),
              color: c.withValues(alpha: 0.08),
            ),
          );
        }).toList(),
        barsSpace: barSpacing,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Legend ────────────────────────────────────────────────────────────
        if (showLegend && _hasLabels) ...[
          _BarLegend(series: series),
          const SizedBox(height: 12),
        ],

        // ── Chart ─────────────────────────────────────────────────────────────
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: maxY ?? _computeMax(),
              barGroups: groups,
              groupsSpace: groupSpacing,
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
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: xLabels != null,
                    reservedSize: 24,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (xLabels == null || idx >= xLabels!.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(xLabels![idx], style: labelStyle),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.cardBg,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final s = series[rodIndex];
                    final c = s.color ?? paletteColor(rodIndex);
                    return BarTooltipItem(
                      s.label != null
                          ? '${s.label}: ${rod.toY.toStringAsFixed(1)}'
                          : rod.toY.toStringAsFixed(1),
                      AppTypography.bodyXs.copyWith(
                        color: c,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _computeMax() {
    double m = 0;
    for (final s in series) {
      for (final v in s.values) {
        if (v > m) m = v;
      }
    }
    return (m * 1.2).ceilToDouble();
  }
}

class _BarLegend extends StatelessWidget {
  const _BarLegend({required this.series});
  final List<AppBarSeries> series;

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
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(3),
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
