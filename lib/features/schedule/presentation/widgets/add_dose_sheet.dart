import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Public data class returned by this sheet ─────────────────────────────────

enum DoseFoodTiming { before, with_, after }

class DoseInput {
  final String name;
  final String time; // "HH:MM"
  final String unit;
  final DoseFoodTiming foodTiming;
  final String repeat;

  /// Length of a fixed course in days, counting today. Null = ongoing.
  final int? durationDays;

  const DoseInput({
    required this.name,
    required this.time,
    required this.unit,
    required this.foodTiming,
    required this.repeat,
    this.durationDays,
  });

  /// Inclusive last day of the course; the backend's endDate covers that whole
  /// local day, so an N-day course ends N-1 days from today.
  DateTime? get endDate {
    if (durationDays == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: durationDays! - 1));
  }
}

// ─── Show helper ──────────────────────────────────────────────────────────────

/// [medicineName] pre-fills and locks the name field — pass it when the caller
/// already knows which medicine the dose belongs to (e.g. the medicine detail
/// sheet), so the user can't retype it into a second cabinet entry.
/// [onDelete] and [onToggleActive] are the destructive/state actions for an
/// existing dose. They live here rather than on the list row so the row stays
/// a single tap target — the row only opens this sheet.
Future<DoseInput?> showAddDoseSheet(
  BuildContext context, {
  String? medicineName,
  DoseInput? initial,
  VoidCallback? onDelete,
  ValueChanged<bool>? onToggleActive,
  bool isActive = true,
}) {
  final title = medicineName ?? (initial != null ? 'Edit dose' : AppStrings.addDose);
  return AppBottomSheet.show<DoseInput>(
    context,
    title: title,
    child: _AddDoseSheet(
      medicineName: medicineName,
      initial: initial,
      onDelete: onDelete,
      onToggleActive: onToggleActive,
      isActive: isActive,
    ),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _AddDoseSheet extends StatefulWidget {
  const _AddDoseSheet({
    this.medicineName,
    this.initial,
    this.onDelete,
    this.onToggleActive,
    this.isActive = true,
  });

  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleActive;
  final bool isActive;

  /// When set, the name is fixed and its field is not shown.
  final String? medicineName;

  /// Existing values to edit. Null means this is a create.
  final DoseInput? initial;

  @override
  State<_AddDoseSheet> createState() => _AddDoseSheetState();
}

class _AddDoseSheetState extends State<_AddDoseSheet> {
  late final _nameCtrl = TextEditingController(
      text: widget.medicineName ?? widget.initial?.name ?? '');

  bool get _nameLocked => widget.medicineName != null;
  bool get _isEdit => widget.initial != null;

  late final _unitCtrl = TextEditingController(text: widget.initial?.unit ?? '');
  late TimeOfDay _time = _parseTime(widget.initial?.time) ?? TimeOfDay.now();
  late DoseFoodTiming _foodTiming =
      widget.initial?.foodTiming ?? DoseFoodTiming.after;
  late String _repeat = widget.initial?.repeat ?? AppStrings.repeatDaily;
  late int? _durationDays = widget.initial?.durationDays;
  late bool _active = widget.isActive;

  static TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static const _durationOptions = <int?>[null, 3, 5, 7, 14, 30];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  String get _timeString {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final unit = _unitCtrl.text.trim();
    if (name.isEmpty || unit.isEmpty) return;
    context.pop(
      DoseInput(
        name: name,
        time: _timeString,
        unit: unit,
        foodTiming: _foodTiming,
        repeat: _repeat,
        durationDays: _durationDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medicine name — omitted when the caller already fixed it.
        if (!_nameLocked) ...[
          _Label(AppStrings.medicineName, required: true),
          const SizedBox(height: 6),
          AppSearchTextVoiceInput(
            controller: _nameCtrl,
            hint: AppStrings.doseNameHint,
            backgroundColor: context.inputBg,
            borderColor: context.borderCol,
          ),
          const SizedBox(height: 14),
        ],

              // Time + Dosage row
              Row(
                children: [
                  Expanded(
                    child: AppTimePickerInput(
                      value: _time,
                      label: AppStrings.doseTime,
                      onChanged: (t) => setState(() => _time = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppStrings.doseUnit, required: true),
                        const SizedBox(height: 6),
                        AppTextField(controller: _unitCtrl, hint: '1 tablet'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Food timing
              _Label(AppStrings.foodTiming),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TimingChip(
                    label: AppStrings.beforeFood,
                    icon: Icons.arrow_upward_rounded,
                    selected: _foodTiming == DoseFoodTiming.before,
                    color: AppColors.blue,
                    onTap: () => setState(() => _foodTiming = DoseFoodTiming.before),
                  ),
                  const SizedBox(width: 8),
                  _TimingChip(
                    label: AppStrings.withFood,
                    icon: Icons.restaurant_rounded,
                    selected: _foodTiming == DoseFoodTiming.with_,
                    color: AppColors.green,
                    onTap: () => setState(() => _foodTiming = DoseFoodTiming.with_),
                  ),
                  const SizedBox(width: 8),
                  _TimingChip(
                    label: AppStrings.afterFood,
                    icon: Icons.arrow_downward_rounded,
                    selected: _foodTiming == DoseFoodTiming.after,
                    color: AppColors.amber,
                    onTap: () => setState(() => _foodTiming = DoseFoodTiming.after),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Repeat
              _Label(AppStrings.repeatOptions),
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
                  return AppFilterChip(
                    label: r,
                    selected: _repeat == r,
                    onTap: () => setState(() => _repeat = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Duration — ongoing by default, which is how every schedule
              // behaved before courses were supported.
              _Label('Duration'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durationOptions.map((days) {
                  return AppFilterChip(
                    label: days == null ? 'Ongoing' : '$days days',
                    selected: _durationDays == days,
                    onTap: () => setState(() => _durationDays = days),
                  );
                }).toList(),
              ),
              // Pause / delete for an existing dose. Moved off the list row so
              // the row is a single tap target instead of three.
              if (widget.onToggleActive != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Reminders'),
                          const SizedBox(height: 2),
                          AppText.bodyXs(
                            _active
                                ? 'This dose will remind you'
                                : 'Paused — no reminders will fire',
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _active,
                      onChanged: (v) {
                        setState(() => _active = v);
                        widget.onToggleActive!(v);
                      },
                      activeThumbColor: AppColors.teal,
                      activeTrackColor: AppColors.teal.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Save button
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nameCtrl,
                builder: (_, nameVal, __) => ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _unitCtrl,
                  builder: (_, unitVal, __) {
                    final canSave = nameVal.text.trim().isNotEmpty && unitVal.text.trim().isNotEmpty;
                    return AppButton(
                      label: _isEdit ? 'Save changes' : AppStrings.saveDose,
                      leading: const Icon(Icons.check_rounded, size: 16),
                      isFullWidth: true,
                      onPressed: canSave ? _save : null,
                    );
                  },
                ),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 10),
                AppButton(
                  variant: AppButtonVariant.danger,
                  label: 'Delete dose',
                  leading: const Icon(Icons.delete_outline_rounded, size: 18),
                  isFullWidth: true,
                  onPressed: () {
                    // Close first: the caller owns the confirm dialog, and
                    // stacking it over this sheet buries it.
                    context.pop();
                    widget.onDelete!();
                  },
                ),
              ],
            ],
          );
  }
}

// ─── Food timing chip ─────────────────────────────────────────────────────────

class _TimingChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TimingChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.12) : context.inputBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(
                color: selected ? color.withValues(alpha: 0.4) : context.borderCol,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(icon, size: 16, color: selected ? color : AppColors.textHint),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.8,
                    color: selected ? color : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

// ─── Shared form helpers ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          AppText.bodyXs(text, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ],
      );
}


