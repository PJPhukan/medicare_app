import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _ReminderType { medicine, appointment, vital, other }

class _Reminder {
  final String id;
  final String title;
  final TimeOfDay time;
  final _ReminderType type;
  final String repeat;
  bool enabled;

  _Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    required this.repeat,
    this.enabled = true,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

List<_Reminder> _buildMockReminders() => [
      _Reminder(
        id: 'r1',
        title: 'Take Metformin 500mg',
        time: const TimeOfDay(hour: 8, minute: 0),
        type: _ReminderType.medicine,
        repeat: AppStrings.repeatDaily,
      ),
      _Reminder(
        id: 'r2',
        title: 'Blood Pressure Check',
        time: const TimeOfDay(hour: 9, minute: 30),
        type: _ReminderType.vital,
        repeat: AppStrings.repeatDaily,
      ),
      _Reminder(
        id: 'r3',
        title: 'Cardiology Appointment',
        time: const TimeOfDay(hour: 11, minute: 0),
        type: _ReminderType.appointment,
        repeat: AppStrings.repeatCustom,
        enabled: false,
      ),
      _Reminder(
        id: 'r4',
        title: 'Evening Insulin Dose',
        time: const TimeOfDay(hour: 19, minute: 0),
        type: _ReminderType.medicine,
        repeat: AppStrings.repeatDaily,
      ),
      _Reminder(
        id: 'r5',
        title: 'Weekly Weight Log',
        time: const TimeOfDay(hour: 7, minute: 0),
        type: _ReminderType.vital,
        repeat: AppStrings.repeatWeekends,
      ),
    ];

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _typeColor(_ReminderType t) => switch (t) {
      _ReminderType.medicine    => AppColors.teal,
      _ReminderType.appointment => AppColors.blue,
      _ReminderType.vital       => AppColors.red,
      _ReminderType.other       => AppColors.amber,
    };

IconData _typeIcon(_ReminderType t) => switch (t) {
      _ReminderType.medicine    => Icons.medication_rounded,
      _ReminderType.appointment => Icons.calendar_today_rounded,
      _ReminderType.vital       => Icons.monitor_heart_rounded,
      _ReminderType.other       => Icons.alarm_rounded,
    };

String _typeLabel(_ReminderType t) => switch (t) {
      _ReminderType.medicine    => AppStrings.reminderTypeMed,
      _ReminderType.appointment => AppStrings.reminderTypeAppt,
      _ReminderType.vital       => AppStrings.reminderTypeVital,
      _ReminderType.other       => AppStrings.reminderTypeOther,
    };

String _fmt(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final p = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $p';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late List<_Reminder> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = _buildMockReminders();
  }

  Future<void> _addReminder() async {
    final result = await showModalBottomSheet<_Reminder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(),
    );
    if (result != null) {
      setState(() => _reminders.insert(0, result));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.reminderSaved, style: AppTypography.bodySm)),
        );
      }
    }
  }

  void _toggleEnabled(_Reminder r) {
    setState(() => r.enabled = !r.enabled);
  }

  void _deleteReminder(_Reminder r) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.deleteReminder, style: AppTypography.h3),
        content: Text(AppStrings.deleteReminderConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() => _reminders.remove(r));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.reminderDeleted, style: AppTypography.bodySm)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text(AppStrings.reminders, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
              actions: [
                IconButton(
                  onPressed: _addReminder,
                  icon: const Icon(Icons.add_rounded, color: AppColors.teal),
                  tooltip: AppStrings.addReminder,
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (_reminders.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(onAdd: _addReminder),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ReminderCard(
                      reminder: _reminders[i],
                      onToggle: () => _toggleEnabled(_reminders[i]),
                      onDelete: () => _deleteReminder(_reminders[i]),
                    ),
                    childCount: _reminders.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final _Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  _ReminderCard({required this.reminder, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(reminder.type);
    final dimmed = !reminder.enabled;
    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: reminder.enabled ? color.withValues(alpha: 0.2) : context.borderCol),
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
                  child: Icon(_typeIcon(reminder.type), color: color, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(_fmt(reminder.time), style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: AppBorderRadius.pill,
                            ),
                            child: Text(
                              _typeLabel(reminder.type),
                              style: AppTypography.bodyXs.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(reminder.repeat, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: reminder.enabled,
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
              child: const Icon(Icons.alarm_rounded, size: 36, color: AppColors.amber),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.noReminders, style: AppTypography.h3.copyWith(fontSize: 17)),
            const SizedBox(height: 8),
            Text(
              AppStrings.noRemindersDesc,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: context.bg,
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(AppStrings.addReminder, style: AppTypography.buttonMd),
            ),
          ],
        ),
      );
}

// ─── Add reminder sheet ───────────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleCtrl = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  _ReminderType _type = _ReminderType.medicine;
  String _repeat = AppStrings.repeatDaily;

  @override
  void dispose() {
    _titleCtrl.dispose();
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

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      _Reminder(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        time: _time,
        type: _type,
        repeat: _repeat,
      ),
    );
  }

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.addReminder, style: AppTypography.h3.copyWith(fontSize: 17)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _Label(AppStrings.reminderTitle, required: true),
              const SizedBox(height: 6),
              _SheetTextField(controller: _titleCtrl, hint: AppStrings.reminderTitleHint),
              SizedBox(height: 14),

              _Label(AppStrings.reminderTime),
              SizedBox(height: 6),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: AppColors.teal),
                      const SizedBox(width: 8),
                      Text(_fmt(_time), style: AppTypography.labelSm.copyWith(color: context.primaryText)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _Label(AppStrings.reminderType),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ReminderType.values.map((t) {
                  final selected = _type == t;
                  final color = _typeColor(t);
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 160),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.15) : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: selected ? color.withValues(alpha: 0.5) : context.borderCol),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon(t), size: 13, color: selected ? color : AppColors.textHint),
                          const SizedBox(width: 5),
                          Text(
                            _typeLabel(t),
                            style: AppTypography.labelSm.copyWith(
                              color: selected ? color : AppColors.textSecondary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

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
                      duration: Duration(milliseconds: 160),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal.withValues(alpha: 0.15) : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: selected ? AppColors.teal.withValues(alpha: 0.5) : context.borderCol,
                        ),
                      ),
                      child: Text(
                        r,
                        style: AppTypography.labelSm.copyWith(
                          color: selected ? AppColors.teal : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleCtrl,
                builder: (_, val, __) {
                  final canSave = val.text.trim().isNotEmpty;
                  return SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: canSave ? _save : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: canSave ? AppColors.teal : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.reminderSaved,
                          style: AppTypography.buttonMd.copyWith(
                            color: canSave ? context.bg : AppColors.textHint,
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
          Text(text, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ],
      );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  _SheetTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: TextField(
          controller: controller,
          style: AppTypography.bodyMd.copyWith(color: context.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      );
}
