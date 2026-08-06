import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/reminder_schedule_model.dart';
import '../providers/reminders_provider.dart';
import 'add_dose_sheet.dart';
import 'schedule_row.dart';

/// Recurring dose-schedule management, folded into the Schedule screen.
///
/// The Schedule screen shows dose *instances* for a day (DoseLogs); this sheet
/// is the only place that edits the *rules* behind them (DoseSchedule +
/// DoseTime), so toggling or deleting here is what stops future doses and
/// cancels the local alarms.
Future<void> showManageSchedulesSheet(BuildContext context) => AppBottomSheet.show<void>(
      context,
      title: AppStrings.manageSchedules,
      subtitle: AppStrings.manageSchedulesDesc,
      child: const _ManageSchedulesSheet(),
    );

class _ManageSchedulesSheet extends ConsumerWidget {
  const _ManageSchedulesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);

    if (state.isLoading && state.schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: AppLoadingSpinner(size: 32, strokeWidth: 2.5)),
      );
    }

    if (state.error != null && state.schedules.isEmpty) {
      return AppErrorState(
        message: AppStrings.schedulesLoadFailed,
        onRetry: () => ref.read(remindersProvider.notifier).load(),
      );
    }

    if (state.schedules.isEmpty) {
      return const AppEmptyState(
        icon: Icons.alarm_off_rounded,
        title: AppStrings.noSchedulesYet,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: state.schedules.length,
      itemBuilder: (_, i) {
        final s = state.schedules[i];
        return ScheduleRow(
          schedule: s,
          onToggle: () => toggleScheduleWithFeedback(context, ref, s.id),
          onDelete: () => confirmDeleteSchedule(context, ref, s),
          onEdit: () => _editSchedule(context, ref, s),
        );
      },
    );
  }
}

/// Opens the edit sheet for a schedule's first dose time — schedules created
/// from this sheet's own "+" always hold exactly one; multi-time schedules
/// (from the Add Medicine wizard) still open here since editing the overall
/// time/food/repeat/duration is the point, not per-time granularity.
///
/// The PATCH replaces the whole dose-time list, so untouched times are sent
/// back unchanged or the server would treat them as removed.
Future<void> _editSchedule(
  BuildContext context,
  WidgetRef ref,
  ReminderScheduleModel schedule,
) async {
  final doseTime = schedule.doseTimes.first;
  final input = await showAddDoseSheet(
    context,
    medicineName: schedule.medicineName,
    isActive: schedule.isActive,
    onToggleActive: (_) => toggleScheduleWithFeedback(context, ref, schedule.id),
    onDelete: () => confirmDeleteSchedule(context, ref, schedule),
    initial: DoseInput(
      name: schedule.medicineName,
      time: doseTime.scheduledTime,
      unit: doseTime.unit ?? '',
      foodTiming: switch (doseTime.foodTiming?.toUpperCase()) {
        'BEFORE' => DoseFoodTiming.before,
        'WITH' => DoseFoodTiming.with_,
        _ => DoseFoodTiming.after,
      },
      repeat: repeatLabel(schedule.scheduleType),
      durationDays: schedule.daysRemaining,
    ),
  );
  if (input == null || !context.mounted) return;

  final dose = parseDoseAmount(input.unit);
  final edited = [
    for (final dt in schedule.doseTimes)
      dt.id == doseTime.id
          ? DoseTimeEdit.from(dt).copyWith(
              scheduledTime: input.time,
              quantity: dose.quantity ?? 1,
              unit: dose.unit ?? input.unit,
              foodTiming: switch (input.foodTiming) {
                DoseFoodTiming.before => 'BEFORE',
                DoseFoodTiming.with_ => 'WITH',
                DoseFoodTiming.after => 'AFTER',
              },
            )
          : DoseTimeEdit.from(dt),
  ];

  try {
    await ref.read(remindersProvider.notifier).updateSchedule(
          id: schedule.id,
          doseTimes: edited,
          scheduleType: apiScheduleType(input.repeat),
          endDate: input.endDate,
          clearEndDate: input.durationDays == null,
        );
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Dose updated');
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, e.toString());
  }
}
