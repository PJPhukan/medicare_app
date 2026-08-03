import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/reminder_schedule_model.dart';
import '../providers/reminders_provider.dart';

String repeatLabel(String type) => switch (type) {
      'DAILY' => AppStrings.repeatDaily,
      'WEEKDAYS' => AppStrings.repeatWeekdays,
      'WEEKENDS' => AppStrings.repeatWeekends,
      'PRN' => AppStrings.asNeeded,
      _ => AppStrings.repeatCustom,
    };

String formatScheduleTime(String hhmm) => formatTime12h(hhmm);

/// One recurring dose schedule with its on/off switch and delete action.
///
/// Shared by the Schedule screen's manage sheet and the medicine detail sheet —
/// both edit the same DoseSchedule rules, so they must behave identically.
/// Set [showMedicineName] to false where the surrounding screen already names
/// the medicine.
class ScheduleRow extends StatelessWidget {
  const ScheduleRow({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.showMedicineName = true,
  });

  final ReminderScheduleModel schedule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  /// Omit to hide the edit action (e.g. where there is nowhere to edit from).
  final VoidCallback? onEdit;
  final bool showMedicineName;

  @override
  Widget build(BuildContext context) {
    final times =
        schedule.doseTimes.map((d) => formatScheduleTime(d.scheduledTime)).join(' · ');
    final left = schedule.daysRemaining;
    final meta = [
      times.isEmpty ? '--' : times,
      repeatLabel(schedule.scheduleType),
      // Only bounded schedules say anything here; an open-ended one would
      // just be repeating "forever" on every row.
      if (left != null) left == 0 ? 'course ended' : '$left days left',
    ].join(' · ');

    return Opacity(
      // A paused schedule still exists but fires nothing — dimming says that
      // without hiding it.
      opacity: schedule.isActive ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          borderColor: schedule.isActive
              ? AppColors.teal.withValues(alpha: 0.2)
              : context.borderCol,
          effectColor: schedule.isActive ? AppColors.teal : null,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.smAll,
                ),
                child: const Icon(Icons.alarm_rounded,
                    color: AppColors.teal, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(
                      showMedicineName ? schedule.medicineName : meta,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showMedicineName) ...[
                      const SizedBox(height: 2),
                      AppText.bodyXs(meta, color: AppColors.textSecondary),
                    ] else if (schedule.doseTimes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText.bodyXs(
                        _doseSummary(schedule),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: schedule.isActive,
                onChanged: (_) => onToggle(),
                activeThumbColor: AppColors.teal,
                activeTrackColor: AppColors.teal.withValues(alpha: 0.3),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.teal),
                  tooltip: 'Edit dose',
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 19, color: AppColors.red),
                tooltip: AppStrings.deleteSchedule,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _doseSummary(ReminderScheduleModel s) {
    final first = s.doseTimes.first;
    return [first.unit, first.foodTiming]
        .where((v) => v != null && v.isNotEmpty)
        .join(' · ');
  }
}

/// Confirms, then deletes the schedule and cancels its local alarms.
/// Returns true when the delete went through.
Future<bool> confirmDeleteSchedule(
  BuildContext context,
  WidgetRef ref,
  ReminderScheduleModel schedule,
) async {
  final confirmed = await AppDialog.confirm(
    context,
    title: AppStrings.deleteSchedule,
    message: AppStrings.deleteScheduleConfirm,
    confirmLabel: AppStrings.delete,
    isDanger: true,
  );
  if (confirmed != true || !context.mounted) return false;
  try {
    await ref.read(remindersProvider.notifier).deleteSchedule(schedule.id);
    if (context.mounted) AppSnackbar.info(context, AppStrings.scheduleDeleted);
    return true;
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, e.toString());
    return false;
  }
}

/// Toggles a schedule on or off, surfacing a failure to the user.
void toggleScheduleWithFeedback(
  BuildContext context,
  WidgetRef ref,
  String id,
) {
  ref.read(remindersProvider.notifier).toggleSchedule(id).catchError((Object e) {
    if (context.mounted) AppSnackbar.error(context, e.toString());
  });
}
