import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_typography.dart';
import 'app_base_card.dart';

// ─── Trend direction ──────────────────────────────────────────────────────────

enum AppStatTrend { up, down, neutral }

// ─── Stat card ────────────────────────────────────────────────────────────────

/// Displays a single metric: icon badge + large value + label + optional trend.
///
/// ```dart
/// AppStatCard(
///   label: 'Appointments',
///   value: '24',
///   icon: Icons.calendar_today_rounded,
///   trend: AppStatTrend.up,
///   trendLabel: '+3 this week',
///   onTap: _navigate,
/// )
/// ```
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.unit,
    this.trendLabel,
    this.trend = AppStatTrend.neutral,
    this.onTap,
    this.margin,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Accent colour for icon, value, and tint. Defaults to [AppColors.teal].
  final Color? color;

  /// Optional unit shown after [value] (e.g. "kg", "bpm").
  final String? unit;

  final String? trendLabel;
  final AppStatTrend trend;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;

    return AppBaseCard(
      margin: margin,
      onTap: onTap,
      shadow: const [],
      color: c.withValues(alpha: 0.06),
      borderColor: c.withValues(alpha: 0.18),
      // Light the corner with this card's own accent — the default teal sheen
      // would muddy an amber or red stat surface.
      effectColor: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.14),
                borderRadius: AppBorderRadius.mdAll,
              ),
              child: Icon(icon, size: 18, color: c),
            ),
            const SizedBox(height: 10),
          ],

          // Value + unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.h1.copyWith(
                  color: c,
                  fontSize: 26,
                  height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    style: AppTypography.labelSm.copyWith(color: c),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
          ),

          // Trend
          if (trendLabel != null) ...[
            const SizedBox(height: 6),
            _TrendBadge(label: trendLabel!, trend: trend),
          ],
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.label, required this.trend});
  final String label;
  final AppStatTrend trend;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (trend) {
      AppStatTrend.up      => (AppColors.success, Icons.arrow_upward_rounded),
      AppStatTrend.down    => (AppColors.error,   Icons.arrow_downward_rounded),
      AppStatTrend.neutral => (AppColors.textHint, Icons.remove_rounded),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.bodyXs.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
