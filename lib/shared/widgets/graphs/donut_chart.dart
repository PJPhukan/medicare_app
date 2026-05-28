import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_chart_series.dart';

/// Donut (ring) chart supporting 1 to N segments.
///
/// ```dart
/// AppDonutChart(
///   segments: [
///     AppDonutSegment(label: 'Taken',   value: 18, color: AppColors.teal),
///     AppDonutSegment(label: 'Missed',  value: 4,  color: AppColors.red),
///     AppDonutSegment(label: 'Pending', value: 2,  color: AppColors.amber),
///   ],
///   centerLabel: 'Adherence',
///   centerValue: '75%',
/// )
/// ```
class AppDonutChart extends StatefulWidget {
  const AppDonutChart({
    super.key,
    required this.segments,
    this.size = 160,
    this.centerLabel,
    this.centerValue,
    this.showLegend = true,
    this.holeRadius = 0.55,
    this.sectionRadius = 0.18,
    this.legendPosition = AppDonutLegendPosition.bottom,
  });

  final List<AppDonutSegment> segments;
  final double size;

  /// Text in the centre hole (e.g. "75%").
  final String? centerValue;

  /// Sub-label below centre value (e.g. "Adherence").
  final String? centerLabel;

  final bool showLegend;

  /// Hole size as fraction of radius. Default 0.55.
  final double holeRadius;

  /// Section ring thickness as fraction of radius. Default 0.18.
  final double sectionRadius;

  final AppDonutLegendPosition legendPosition;

  @override
  State<AppDonutChart> createState() => _AppDonutChartState();
}

enum AppDonutLegendPosition { bottom, right, none }

class _AppDonutChartState extends State<AppDonutChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final chart = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: widget.size * widget.holeRadius / 2,
              pieTouchData: PieTouchData(
                touchCallback: (_, response) {
                  setState(() {
                    _touched = response?.touchedSection
                            ?.touchedSectionIndex ??
                        -1;
                  });
                },
              ),
              sections: widget.segments.asMap().entries.map((e) {
                final i = e.key;
                final seg = e.value;
                final c = seg.color ?? paletteColor(i);
                final isTouched = i == _touched;
                final radius =
                    widget.size * widget.sectionRadius / 2 *
                        (isTouched ? 1.1 : 1.0);
                return PieChartSectionData(
                  value: seg.value,
                  color: c,
                  radius: radius,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),

          // Centre text
          if (widget.centerValue != null || widget.centerLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.centerValue != null)
                  Text(
                    widget.centerValue!,
                    style: AppTypography.h2.copyWith(
                      fontSize: widget.size * 0.14,
                      height: 1,
                    ),
                  ),
                if (widget.centerLabel != null)
                  Text(
                    widget.centerLabel!,
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
        ],
      ),
    );

    if (!widget.showLegend ||
        widget.legendPosition == AppDonutLegendPosition.none) {
      return chart;
    }

    final legend = _DonutLegend(segments: widget.segments);

    if (widget.legendPosition == AppDonutLegendPosition.right) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [chart, const SizedBox(width: 20), legend],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [chart, const SizedBox(height: 16), legend],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({required this.segments});
  final List<AppDonutSegment> segments;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold(0.0, (s, e) => s + e.value);
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: segments.asMap().entries.map((e) {
        final c = e.value.color ?? paletteColor(e.key);
        final pct = total > 0
            ? '${(e.value.value / total * 100).round()}%'
            : '0%';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '${e.value.label} $pct',
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

// ─── Adherence ring (single-value shortcut) ───────────────────────────────────

/// Single-metric ring — a convenience wrapper around [AppDonutChart] for
/// showing one percentage value (e.g. medication adherence, goal progress).
///
/// ```dart
/// AppAdherenceRing(
///   percent: 0.78,
///   color: AppColors.teal,
///   centerLabel: 'Adherence',
/// )
/// ```
class AppAdherenceRing extends StatelessWidget {
  const AppAdherenceRing({
    super.key,
    required this.percent,
    this.size = 120,
    this.color,
    this.centerLabel,
    this.trackOpacity = 0.12,
  });

  final double percent;
  final double size;
  final Color? color;
  final String? centerLabel;
  final double trackOpacity;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final pct = percent.clamp(0.0, 1.0);

    return AppDonutChart(
      size: size,
      showLegend: false,
      centerValue: '${(pct * 100).round()}%',
      centerLabel: centerLabel,
      segments: [
        AppDonutSegment(
          label: centerLabel ?? '',
          value: pct,
          color: c,
        ),
        AppDonutSegment(
          label: '',
          value: 1 - pct,
          color: context.borderCol,
        ),
      ],
    );
  }
}
