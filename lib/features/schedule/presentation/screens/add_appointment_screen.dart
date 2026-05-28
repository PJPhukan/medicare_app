import 'package:flutter/material.dart';
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

  const DoseInput({
    required this.name,
    required this.time,
    required this.unit,
    required this.foodTiming,
    required this.repeat,
  });
}

// ─── Show helper ──────────────────────────────────────────────────────────────

Future<DoseInput?> showAddDoseSheet(BuildContext context) {
  return showModalBottomSheet<DoseInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddDoseSheet(),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _AddDoseSheet extends StatefulWidget {
  const _AddDoseSheet();

  @override
  State<_AddDoseSheet> createState() => _AddDoseSheetState();
}

class _AddDoseSheetState extends State<_AddDoseSheet> {
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  DoseFoodTiming _foodTiming = DoseFoodTiming.after;
  String _repeat = AppStrings.repeatDaily;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            hourMinuteTextColor: context.primaryText,
            dialBackgroundColor: context.inputBg,
            dialHandColor: AppColors.teal,
            dialTextColor: context.primaryText,
            entryModeIconColor: AppColors.teal,
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

  void _save() {
    final name = _nameCtrl.text.trim();
    final unit = _unitCtrl.text.trim();
    if (name.isEmpty || unit.isEmpty) return;
    Navigator.pop(
      context,
      DoseInput(
        name: name,
        time: _timeString,
        unit: unit,
        foodTiming: _foodTiming,
        repeat: _repeat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;

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
              // Handle + header
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.addDose, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Medicine name
              _Label(AppStrings.medicineName, required: true),
              const SizedBox(height: 6),
              _TextField(controller: _nameCtrl, hint: AppStrings.doseNameHint),
              const SizedBox(height: 14),

              // Time + Dosage row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppStrings.doseTime),
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
                                SizedBox(width: 8),
                                Text(
                                  _timeDisplay,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: context.primaryText),
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
                        _Label(AppStrings.doseUnit, required: true),
                        const SizedBox(height: 6),
                        _TextField(controller: _unitCtrl, hint: '1 tablet'),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.5,
                          color: selected ? AppColors.teal : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save button
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nameCtrl,
                builder: (_, nameVal, __) => ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _unitCtrl,
                  builder: (_, unitVal, __) {
                    final canSave = nameVal.text.trim().isNotEmpty && unitVal.text.trim().isNotEmpty;
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: canSave ? context.bg : AppColors.textHint,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.saveDose,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: canSave ? context.bg : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  _TextField({required this.controller, required this.hint});

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
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
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
