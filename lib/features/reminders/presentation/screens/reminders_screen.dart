import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/reminder_schedule_model.dart';
import '../providers/reminders_provider.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _typeColor(String type) => switch (type) {
      'MEDICINE' => AppColors.teal,
      'APPOINTMENT' => AppColors.blue,
      'VITAL' => AppColors.red,
      _ => AppColors.amber,
    };

IconData _typeIcon(String type) => switch (type) {
      'MEDICINE' => Icons.medication_rounded,
      'APPOINTMENT' => Icons.calendar_today_rounded,
      'VITAL' => Icons.monitor_heart_rounded,
      _ => Icons.alarm_rounded,
    };

String _typeLabel(String type) => switch (type) {
      'MEDICINE' => AppStrings.reminderTypeMed,
      'APPOINTMENT' => AppStrings.reminderTypeAppt,
      'VITAL' => AppStrings.reminderTypeVital,
      _ => AppStrings.reminderTypeOther,
    };

String _repeatLabel(String type) => switch (type) {
      'DAILY' => AppStrings.repeatDaily,
      'WEEKDAYS' => AppStrings.repeatWeekdays,
      'WEEKENDS' => AppStrings.repeatWeekends,
      _ => AppStrings.repeatCustom,
    };

String _fmtTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  var h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1].padLeft(2, '0');
  final period = h < 12 ? 'AM' : 'PM';
  if (h == 0) h = 12;
  if (h > 12) h -= 12;
  return '$h:$m $period';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: AppText.h2(AppStrings.reminders),
                background: Container(color: context.bg),
              ),
              actions: [
                IconButton(
                  onPressed: () => _addReminder(context, ref),
                  icon: const Icon(Icons.add_rounded, color: AppColors.teal),
                  tooltip: AppStrings.addReminder,
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Loading state (first load)
            if (state.isLoading && state.schedules.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.teal),
                ),
              )

            // Error state
            else if (state.error != null && state.schedules.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      AppText.bodySm('Could not load reminders.',
                          color: AppColors.textSecondary),
                      const SizedBox(height: 12),
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

            // Empty state
            else if (state.schedules.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                    onAdd: () => _addReminder(context, ref)),
              )

            // List
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final s = state.schedules[i];
                      return _ReminderCard(
                        schedule: s,
                        onToggle: () => _toggle(context, ref, s.id),
                        onDelete: () => _delete(context, ref, s),
                      );
                    },
                    childCount: state.schedules.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReminder(BuildContext context, WidgetRef ref) async {
    final input = await showModalBottomSheet<_ReminderInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddReminderSheet(),
    );
    if (input == null || !context.mounted) return;

    try {
      await ref.read(remindersProvider.notifier).createSchedule(
            medicineName: input.title,
            time: input.time,
            unit: input.unit,
            foodTiming: 'AFTER',
            scheduleType: input.scheduleType,
            reminderType: input.reminderType,
          );
      if (context.mounted) {
        AppSnackbar.success(context, AppStrings.reminderSaved);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  void _toggle(BuildContext context, WidgetRef ref, String id) {
    ref.read(remindersProvider.notifier).toggleSchedule(id).catchError((e) {
      if (context.mounted) AppSnackbar.error(context, e.toString());
    });
  }

  void _delete(BuildContext context, WidgetRef ref, ReminderScheduleModel s) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: AppText.h3(AppStrings.deleteReminder),
        content: AppText.bodySm(AppStrings.deleteReminderConfirm,
            color: AppColors.textSecondary),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: AppText.bodySm(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText.bodySm(AppStrings.delete, color: AppColors.red),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ref
            .read(remindersProvider.notifier)
            .deleteSchedule(s.id)
            .then((_) {
          if (context.mounted) {
            AppSnackbar.info(context, AppStrings.reminderDeleted);
          }
        }).catchError((e) {
          if (context.mounted) AppSnackbar.error(context, e.toString());
        });
      }
    });
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final ReminderScheduleModel schedule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.schedule,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(schedule.reminderType);
    final firstTime = schedule.doseTimes.isNotEmpty
        ? _fmtTime(schedule.doseTimes.first.scheduledTime)
        : '--';

    return Opacity(
      opacity: schedule.isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: schedule.isActive
                ? color.withValues(alpha: 0.2)
                : context.borderCol,
          ),
        ),
        child: InkWell(
          onLongPress: onDelete,
          borderRadius: AppBorderRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: Icon(_typeIcon(schedule.reminderType),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyMd(
                        schedule.medicineName,
                        color: context.primaryText,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          AppText.bodyXs(firstTime,
                              color: AppColors.textSecondary),
                          if (schedule.doseTimes.length > 1) ...[
                            const SizedBox(width: 4),
                            AppText.bodyXs(
                              '+${schedule.doseTimes.length - 1} more',
                              color: AppColors.textHint,
                            ),
                          ],
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: AppBorderRadius.pill,
                            ),
                            child: Text(
                              _typeLabel(schedule.reminderType),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _repeatLabel(schedule.scheduleType),
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: schedule.isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColors.teal,
                  activeTrackColor: AppColors.teal.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.alarm_rounded, size: 36, color: AppColors.amber),
            ),
            const SizedBox(height: 20),
            const Text(AppStrings.noReminders,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AppText.bodySm(
              AppStrings.noRemindersDesc,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.lgAll),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(AppStrings.addReminder,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2)),
            ),
          ],
        ),
      );
}

// ─── Input data class ─────────────────────────────────────────────────────────

enum _ReminderType { medicine, appointment, vital, other }

class _ReminderInput {
  final String title;
  final String time;
  final String unit;
  final String reminderType;
  final String scheduleType;

  const _ReminderInput({
    required this.title,
    required this.time,
    required this.unit,
    required this.reminderType,
    required this.scheduleType,
  });
}

// ─── Add reminder sheet ───────────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: '1 tablet');
  TimeOfDay _time = TimeOfDay.now();
  _ReminderType _type = _ReminderType.medicine;
  String _repeat = AppStrings.repeatDaily;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.teal,
            surface: context.cardBg,
            onSurface: context.primaryText,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: context.cardBg,
            hourMinuteColor: context.inputBg,
            dialBackgroundColor: context.inputBg,
            dialHandColor: AppColors.teal,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String get _timeString {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _timeDisplay {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _toApiReminderType(_ReminderType t) => switch (t) {
        _ReminderType.medicine => 'MEDICINE',
        _ReminderType.appointment => 'APPOINTMENT',
        _ReminderType.vital => 'VITAL',
        _ReminderType.other => 'OTHER',
      };

  String _toApiScheduleType(String label) => switch (label) {
        AppStrings.repeatWeekdays => 'WEEKDAYS',
        AppStrings.repeatWeekends => 'WEEKENDS',
        AppStrings.repeatCustom => 'CUSTOM',
        _ => 'DAILY',
      };

  void _save() {
    final title = _titleCtrl.text.trim();
    final unit = _unitCtrl.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      _ReminderInput(
        title: title,
        time: _timeString,
        unit: unit.isEmpty ? '1 dose' : unit,
        reminderType: _toApiReminderType(_type),
        scheduleType: _toApiScheduleType(_repeat),
      ),
    );
  }

  Color _typeColor2(_ReminderType t) => switch (t) {
        _ReminderType.medicine => AppColors.teal,
        _ReminderType.appointment => AppColors.blue,
        _ReminderType.vital => AppColors.red,
        _ReminderType.other => AppColors.amber,
      };

  IconData _typeIcon2(_ReminderType t) => switch (t) {
        _ReminderType.medicine => Icons.medication_rounded,
        _ReminderType.appointment => Icons.calendar_today_rounded,
        _ReminderType.vital => Icons.monitor_heart_rounded,
        _ReminderType.other => Icons.alarm_rounded,
      };

  String _typeLabel2(_ReminderType t) => switch (t) {
        _ReminderType.medicine => AppStrings.reminderTypeMed,
        _ReminderType.appointment => AppStrings.reminderTypeAppt,
        _ReminderType.vital => AppStrings.reminderTypeVital,
        _ReminderType.other => AppStrings.reminderTypeOther,
      };

  @override
  Widget build(BuildContext context) {
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPad),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
                      color: context.borderCol,
                      borderRadius: AppBorderRadius.pill),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.addReminder,
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Title ──
              _Label(AppStrings.reminderTitle, required: true),
              const SizedBox(height: 6),
              _SheetTextField(
                  controller: _titleCtrl,
                  hint: AppStrings.reminderTitleHint),
              const SizedBox(height: 14),

              // ── Time + Unit ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppStrings.reminderTime),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: context.inputBg,
                              borderRadius: AppBorderRadius.lgAll,
                              border: Border.all(color: context.borderCol),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 15, color: AppColors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  _timeDisplay,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppStrings.doseUnit),
                        const SizedBox(height: 6),
                        _SheetTextField(
                            controller: _unitCtrl, hint: '1 tablet'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Type ──
              _Label(AppStrings.reminderType),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ReminderType.values.map((t) {
                  final selected = _type == t;
                  final color = _typeColor2(t);
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.15)
                            : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: selected
                              ? color.withValues(alpha: 0.5)
                              : context.borderCol,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon2(t),
                              size: 13,
                              color: selected ? color : AppColors.textHint),
                          const SizedBox(width: 5),
                          Text(
                            _typeLabel2(t),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: 0.5,
                              color: selected
                                  ? color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ── Repeat ──
              _Label(AppStrings.reminderRepeat),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStrings.repeatDaily,
                  AppStrings.repeatWeekdays,
                  AppStrings.repeatWeekends,
                  AppStrings.repeatCustom,
                ].map((r) {
                  final selected = _repeat == r;
                  return GestureDetector(
                    onTap: () => setState(() => _repeat = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.teal.withValues(alpha: 0.15)
                            : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: selected
                              ? AppColors.teal.withValues(alpha: 0.5)
                              : context.borderCol,
                        ),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.5,
                          color: selected
                              ? AppColors.teal
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Save button ──
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleCtrl,
                builder: (_, val, __) {
                  final canSave = val.text.trim().isNotEmpty;
                  return SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: canSave ? _save : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: canSave ? AppColors.teal : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.reminderSaved,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color:
                                canSave ? Colors.white : AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared form helpers ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          AppText.bodyXs(text,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*',
                style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ],
      );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SheetTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: context.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 14, color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      );
}
