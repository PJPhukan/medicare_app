import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/reminders_provider.dart';
import 'schedule_row.dart';

/// Recurring dose-schedule management, folded into the Schedule screen.
///
/// The Schedule screen shows dose *instances* for a day (DoseLogs); this sheet
/// is the only place that edits the *rules* behind them (DoseSchedule +
/// DoseTime), so toggling or deleting here is what stops future doses and
/// cancels the local alarms.
Future<void> showManageSchedulesSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManageSchedulesSheet(),
    );

class _ManageSchedulesSheet extends ConsumerWidget {
  const _ManageSchedulesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.manageSchedules,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textHint, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText.bodyXs(AppStrings.manageSchedulesDesc,
              color: AppColors.textSecondary),
          const SizedBox(height: 16),

          if (state.isLoading && state.schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.teal),
              ),
            )
          else if (state.error != null && state.schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 40, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    AppText.bodySm(AppStrings.schedulesLoadFailed,
                        color: AppColors.textSecondary),
                    TextButton(
                      onPressed: () =>
                          ref.read(remindersProvider.notifier).load(),
                      child: const Text('Retry',
                          style: TextStyle(color: AppColors.teal)),
                    ),
                  ],
                ),
              ),
            )
          else if (state.schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.alarm_off_rounded,
                        size: 40, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    AppText.bodySm(AppStrings.noSchedulesYet,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.schedules.length,
                itemBuilder: (_, i) {
                  final s = state.schedules[i];
                  return ScheduleRow(
                    schedule: s,
                    onToggle: () => toggleScheduleWithFeedback(context, ref, s.id),
                    onDelete: () => confirmDeleteSchedule(context, ref, s),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

}
