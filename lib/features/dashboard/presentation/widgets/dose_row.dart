import 'package:flutter/material.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/widgets/widgets.dart';
import 'dose_view_model.dart';

/// One row in the dashboard's "Today's Medicines" card.
///
/// Each dose gets its own tinted, bordered card — the previous version was a
/// bare [AppListTile] with no boundary between rows besides a hairline
/// divider, which is what read as "not looking good" at a glance. The tint
/// carries status (teal=pending/day, amber=night or skipped, red=missed,
/// green=taken) the same way the medicines feature's cards already do, so the
/// dashboard reads as part of one visual system rather than a different one.
class DoseRow extends StatelessWidget {
  const DoseRow({
    super.key,
    required this.dose,
    required this.onTake,
    required this.onSkip,
  });

  final DashboardDose dose;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  Color get _accent => switch (dose.status) {
        DoseStatus.taken => AppColors.green,
        DoseStatus.skipped => AppColors.amber,
        DoseStatus.missed => AppColors.red,
        DoseStatus.pending =>
          isNightTime(dose.time) ? AppColors.purple : AppColors.teal,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final night = isNightTime(dose.time);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      effectColor: accent,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: Icon(
              dose.status == DoseStatus.taken
                  ? Icons.check_rounded
                  : dose.status == DoseStatus.missed
                      ? Icons.close_rounded
                      : night
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelMd(
                  dose.name,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    AppText.bodyXs(
                      formatTime12h(dose.time),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Pending keeps the quick actions; anything already resolved just
          // states its outcome — a taken dose doesn't need buttons anymore.
          // Both states use the same labelled-pill shape so "Take" / "Skip"
          // and "Taken" / "Skipped" / "Missed" read as one family.
          dose.status == DoseStatus.pending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionChip(
                      label: 'Take',
                      color: AppColors.green,
                      onTap: onTake,
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      label: 'Skip',
                      color: AppColors.amber,
                      onTap: onSkip,
                    ),
                  ],
                )
              : _StatusBadge(status: dose.status, color: accent),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final DoseStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      DoseStatus.taken => 'Taken',
      DoseStatus.skipped => 'Skipped',
      DoseStatus.missed => 'Missed',
      DoseStatus.pending => '',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// Tappable action pill — same shape as [_StatusBadge] but with an
/// [onTap], so "Take"/"Skip" (actionable) and "Taken"/"Skipped"/"Missed"
/// (resolved) read as one design language rather than two.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppBorderRadius.pill,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
