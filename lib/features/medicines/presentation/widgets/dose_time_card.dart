import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../schedule/data/models/reminder_schedule_model.dart';
import '../../../schedule/presentation/widgets/schedule_row.dart';
import 'medicine_status.dart';

/// One scheduled dose time.
///
/// A DoseSchedule can hold several dose times — "twice daily" is one schedule
/// with two — and showing the schedule as a single row merged them into one
/// line. Each time is its own card here, because each is what the user
/// actually thinks about and edits.
///
/// The card is a single tap target: pause and delete live inside the edit
/// sheet rather than as competing controls on the row.
class DoseTimeCard extends StatelessWidget {
  const DoseTimeCard({
    super.key,
    required this.schedule,
    required this.doseTime,
    required this.onEdit,
  });

  final ReminderScheduleModel schedule;
  final ReminderDoseTime doseTime;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final night = isNightDose(doseTime.scheduledTime);
    // context.hintText, not AppColors.textHint directly: this feeds a raw
    // Icon color below (not an AppText), so the dark-theme constant would
    // never adapt and the paused-dose icon would wash out in light mode.
    final accent = schedule.isActive
        ? (night ? AppColors.purple : AppColors.amber)
        : context.hintText;
    final left = schedule.daysRemaining;

    final meta = [
      if (doseTime.unit != null && doseTime.unit!.isNotEmpty) doseTime.unit!,
      if (doseTime.foodTiming != null && doseTime.foodTiming!.isNotEmpty)
        formatFoodTiming(doseTime.foodTiming!),
    ].join(' · ');

    return Opacity(
      // A paused schedule still exists but fires nothing — dimming says that
      // without hiding the dose.
      opacity: schedule.isActive ? 1 : 0.55,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          onTap: onEdit,
          effectColor: schedule.isActive ? accent : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  night ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 18,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText.labelMd(
                          formatDoseTime(doseTime.scheduledTime),
                          fontWeight: FontWeight.w700,
                        ),
                        if (!schedule.isActive) ...[
                          const SizedBox(width: 8),
                          const AppBadge(
                            label: 'Paused',
                            variant: AppBadgeVariant.neutral,
                          ),
                        ],
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText.bodyXs(meta, color: AppColors.textSecondary),
                    ],
                    const SizedBox(height: 2),
                    AppText.bodyXs(
                      [
                        repeatLabel(schedule.scheduleType),
                        if (left != null)
                          left == 0 ? 'course ended' : '$left days left',
                      ].join(' · '),
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 18, color: AppColors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
