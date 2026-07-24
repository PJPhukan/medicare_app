import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';

/// Large numeric stat block used for vitals, adherence %, and summary cards.
///
/// ```dart
/// AppStatText(
///   value: '98',
///   unit: '%',
///   label: 'Adherence',
///   trend: AppStatTrend.up,
///   trendValue: '+3%',
///   accentColor: AppColors.teal,
/// )
/// ```
class AppStatText extends StatelessWidget {
  const AppStatText({
    super.key,
    required this.value,
    this.unit,
    required this.label,
    this.sublabel,
    this.trend,
    this.trendValue,
    this.accentColor,
    this.size = AppStatSize.md,
    this.icon,
    this.padding,
    this.alignment = CrossAxisAlignment.start,
  });

  /// Primary numeric value shown large (e.g. "98", "120/80", "7.5k").
  final String value;

  /// Unit appended as a smaller superscript (e.g. "%", "bpm", "kg").
  final String? unit;

  /// Descriptive label below the value (e.g. "Adherence", "Heart Rate").
  final String label;

  /// Even smaller secondary label (e.g. "Last 7 days").
  final String? sublabel;

  final AppStatTrend? trend;

  /// Text to display next to the trend arrow (e.g. "+3%", "−2 bpm").
  final String? trendValue;

  final Color? accentColor;
  final AppStatSize size;

  /// Optional icon shown above the value.
  final IconData? icon;

  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.teal;

    final valueStyle = switch (size) {
      AppStatSize.xl => AppTypography.statXl,
      AppStatSize.lg => AppTypography.statLg,
      AppStatSize.md => AppTypography.statMd,
      AppStatSize.sm => AppTypography.h2,
    };

    final unitFontSize = switch (size) {
      AppStatSize.xl => 18.0,
      AppStatSize.lg => 15.0,
      AppStatSize.md => 13.0,
      AppStatSize.sm => 11.0,
    };

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon ──────────────────────────────────────────────────────────
          if (icon != null) ...[
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 6),
          ],

          // ── Value + unit ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: valueStyle.copyWith(color: accent),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit!,
                    style: AppTypography.labelMd.copyWith(
                      color: accent.withValues(alpha: 0.75),
                      fontSize: unitFontSize,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 3),

          // ── Label ─────────────────────────────────────────────────────────
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: context.secondaryText,
              letterSpacing: 0.2,
            ),
          ),

          // ── Sublabel ──────────────────────────────────────────────────────
          if (sublabel != null) ...[
            const SizedBox(height: 1),
            Text(
              sublabel!,
              style: AppTypography.bodyXs.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],

          // ── Trend ─────────────────────────────────────────────────────────
          if (trend != null) ...[
            const SizedBox(height: 6),
            _TrendChip(trend: trend!, value: trendValue),
          ],
        ],
      ),
    );
  }
}

// ─── Trend chip ───────────────────────────────────────────────────────────────

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.trend, this.value});
  final AppStatTrend trend;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      AppStatTrend.up    => (Icons.trending_up_rounded,   AppColors.success),
      AppStatTrend.down  => (Icons.trending_down_rounded, AppColors.error),
      AppStatTrend.flat  => (Icons.trending_flat_rounded, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          if (value != null) ...[
            const SizedBox(width: 3),
            Text(
              value!,
              style: AppTypography.labelXs.copyWith(
                color: color,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Enums ────────────────────────────────────────────────────────────────────

enum AppStatTrend { up, down, flat }

enum AppStatSize { xl, lg, md, sm }

// ─── Stat row ─────────────────────────────────────────────────────────────────

/// Evenly-spaced row of [AppStatText] blocks, separated by a vertical divider.
///
/// ```dart
/// AppStatRow(stats: [
///   AppStatText(value: '120', unit: 'mmHg', label: 'Systolic'),
///   AppStatText(value: '80',  unit: 'mmHg', label: 'Diastolic'),
///   AppStatText(value: '72',  unit: 'bpm',  label: 'Pulse'),
/// ])
/// ```
class AppStatRow extends StatelessWidget {
  const AppStatRow({
    super.key,
    required this.stats,
    this.padding,
  });

  final List<AppStatText> stats;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.borderCol;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(stats.length * 2 - 1, (i) {
            if (i.isOdd) {
              return VerticalDivider(
                width: 32,
                thickness: 1,
                color: dividerColor,
              );
            }
            return Expanded(
              child: stats[i ~/ 2],
            );
          }),
        ),
      ),
    );
  }
}
