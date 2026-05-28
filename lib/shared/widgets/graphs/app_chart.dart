import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

// ─── Line chart ───────────────────────────────────────────────────────────────

class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.spots,
    this.color,
    this.height = 160,
    this.showDots = false,
    this.showGrid = false,
    this.minY,
    this.maxY,
    this.labelX,
    this.labelY,
    this.gradient = true,
  });

  final List<FlSpot> spots;
  final Color? color;
  final double height;
  final bool showDots;
  final bool showGrid;
  final double? minY;
  final double? maxY;
  final String Function(double)? labelX;
  final String Function(double)? labelY;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labelY != null,
                reservedSize: 36,
                getTitlesWidget: labelY != null
                    ? (v, _) => Text(labelY!(v), style: AppTypography.bodyXs)
                    : (_, __) => const SizedBox.shrink(),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labelX != null,
                reservedSize: 24,
                getTitlesWidget: labelX != null
                    ? (v, _) => Text(labelX!(v), style: AppTypography.bodyXs)
                    : (_, __) => const SizedBox.shrink(),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: c,
              barWidth: 2.5,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.withValues(alpha: 0.2), c.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.groups,
    this.color,
    this.height = 160,
    this.showGrid = false,
    this.labelX,
    this.maxY,
  });

  final List<BarChartGroupData> groups;
  final Color? color;
  final double height;
  final bool showGrid;
  final String Function(double)? labelX;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: groups,
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labelX != null,
                reservedSize: 24,
                getTitlesWidget: labelX != null
                    ? (v, _) => Text(labelX!(v), style: AppTypography.bodyXs)
                    : (_, __) => const SizedBox.shrink(),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }
}

// ─── Adherence ring ───────────────────────────────────────────────────────────

class AppAdherenceRing extends StatelessWidget {
  const AppAdherenceRing({
    super.key,
    required this.percent,
    this.size = 100,
    this.color,
    this.label,
  });

  final double percent;
  final double size;
  final Color? color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final pct = percent.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.34,
              sections: [
                PieChartSectionData(
                  value: pct,
                  color: c,
                  radius: size * 0.16,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 1 - pct,
                  color: context.borderCol,
                  radius: size * 0.16,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(

                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  color: c,
                ),
              ),
              if (label != null)
                Text(label!, style: AppTypography.bodyXs, textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat row ─────────────────────────────────────────────────────────────────

class AppStatRow extends StatelessWidget {
  const AppStatRow({super.key, required this.stats});
  final List<({String label, String value, Color? color})> stats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: stats.asMap().entries.expand((e) {
          final isLast = e.key == stats.length - 1;
          final s = e.value;
          return [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      s.value,
                      style: TextStyle(

                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: s.color ?? context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(s.label, style: AppTypography.labelXs, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 36, color: context.dividerCol),
          ];
        }).toList(),
      ),
    );
  }
}
